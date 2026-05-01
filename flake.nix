{
  description = "A basic flake with a shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;
      pkgsFor = lib.genAttrs systems (system: import nixpkgs { inherit system; });
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    {
      packages = forEachSystem (pkgs: {
        default = pkgs.writeShellApplication {
          name = "gen";
          runtimeInputs = with pkgs; [
            chromium
            curl
            pup
            qpdf
          ];
          text = builtins.readFile ./gen;
        };
      });

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            chromium
            curl
            nixfmt
            pup
            qpdf
          ];
        };
      });
    };
}
