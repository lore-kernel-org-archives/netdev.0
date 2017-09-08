From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Fri, 8 Sep 2017 09:25:38 +0200
Message-ID: <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2liiw4h4lfwu7u37"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170908071156.5115-6-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2liiw4h4lfwu7u37
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 08, 2017 at 09:11:51AM +0200, Corentin Labbe wrote:
> This patch add documentation about the MDIO switch used on sun8i-h3-emac
> for integrated PHY.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  .../devicetree/bindings/net/dwmac-sun8i.txt        | 127 +++++++++++++++=
++++--
>  1 file changed, 120 insertions(+), 7 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Docu=
mentation/devicetree/bindings/net/dwmac-sun8i.txt
> index 725f3b187886..3fa0e54825ea 100644
> --- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> @@ -39,7 +39,7 @@ Optional properties for the following compatibles:
>  - allwinner,leds-active-low: EPHY LEDs are active low
> =20
>  Required child node of emac:
> -- mdio bus node: should be named mdio
> +- mdio bus node: should be labelled mdio

labels do not end up in the final DT (while the names do) so why are
you making this change?

> =20
>  Required properties of the mdio node:
>  - #address-cells: shall be 1
> @@ -48,14 +48,28 @@ Required properties of the mdio node:
>  The device node referenced by "phy" or "phy-handle" should be a child no=
de
>  of the mdio node. See phy.txt for the generic PHY bindings.
> =20
> -Required properties of the phy node with the following compatibles:
> +The following compatibles require an mdio-mux node called "mdio-mux":
> +  - "allwinner,sun8i-h3-emac"
> +  - "allwinner,sun8i-v3s-emac":
> +Required properties for the mdio-mux node:
> +  - compatible =3D "mdio-mux"
> +  - one child mdio for the integrated mdio
> +  - one child mdio for the external mdio if present (V3s have none)
> +Required properties for the mdio-mux children node:
> +  - reg: 0 for internal MDIO bus, 1 for external MDIO bus
> +
> +The following compatibles require a PHY node representing the integrated
> +PHY, under the integrated MDIO bus node if an mdio-mux node is used:
>    - "allwinner,sun8i-h3-emac",
>    - "allwinner,sun8i-v3s-emac":
> +
> +Required properties of the integrated phy node:
>  - clocks: a phandle to the reference clock for the EPHY
>  - resets: a phandle to the reset control for the EPHY
> +- phy-is-integrated
> +- Should be a child of the integrated mdio

I'm not sure what you mean by that, you ask that it should (so not
required?) be a child of the integrated mdio...

> =20
> -Example:
> -
> +Example with integrated PHY:
>  emac: ethernet@1c0b000 {
>  	compatible =3D "allwinner,sun8i-h3-emac";
>  	syscon =3D <&syscon>;
> @@ -72,13 +86,112 @@ emac: ethernet@1c0b000 {
>  	phy-handle =3D <&int_mii_phy>;
>  	phy-mode =3D "mii";
>  	allwinner,leds-active-low;
> +
> +	mdio0: mdio {

(You don't label it mdio here, unlike what was asked before)

> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +		compatible =3D "snps,dwmac-mdio";
> +	};

I think Rob wanted that node gone?

> +	mdio-mux {
> +		compatible =3D "mdio-mux";
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +
> +		int_mdio: mdio@1 {
> +			reg =3D <0>;
> +			#address-cells =3D <1>;
> +			#size-cells =3D <0>;
> +			int_mii_phy: ethernet-phy@1 {
> +				reg =3D <1>;
> +				clocks =3D <&ccu CLK_BUS_EPHY>;
> +				resets =3D <&ccu RST_BUS_EPHY>;
> +				phy-is-integrated
> +			};
> +		};

=2E.. And in your example it's a child of the mdio mux?

> +		ext_mdio: mdio@0 {
> +			reg =3D <1>;
> +			#address-cells =3D <1>;
> +			#size-cells =3D <0>;
> +		};
> +	};
> +};
> +
> +Example with external PHY:
> +emac: ethernet@1c0b000 {
> +	compatible =3D "allwinner,sun8i-h3-emac";
> +	syscon =3D <&syscon>;
> +	reg =3D <0x01c0b000 0x104>;
> +	interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +	interrupt-names =3D "macirq";
> +	resets =3D <&ccu RST_BUS_EMAC>;
> +	reset-names =3D "stmmaceth";
> +	clocks =3D <&ccu CLK_BUS_EMAC>;
> +	clock-names =3D "stmmaceth";
> +	#address-cells =3D <1>;
> +	#size-cells =3D <0>;
> +
> +	phy-handle =3D <&ext_rgmii_phy>;
> +	phy-mode =3D "rgmii";
> +	allwinner,leds-active-low;
> +
> +	mdio0: mdio {
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +		compatible =3D "snps,dwmac-mdio";
> +	};
> +
> +	mdio-mux {
> +		compatible =3D "mdio-mux";
> +		#address-cells =3D <1>;
> +		#size-cells =3D <0>;
> +
> +		int_mdio: mdio@1 {
> +			reg =3D <0>;
> +			#address-cells =3D <1>;
> +			#size-cells =3D <0>;
> +			int_mii_phy: ethernet-phy@1 {
> +				reg =3D <1>;
> +				clocks =3D <&ccu CLK_BUS_EPHY>;
> +				resets =3D <&ccu RST_BUS_EPHY>;
> +				phy-is-integrated
> +			};
> +		};
> +		ext_mdio: mdio@0 {
> +			reg =3D <1>;
> +			#address-cells =3D <1>;
> +			#size-cells =3D <0>;
> +			ext_rgmii_phy: ethernet-phy@1 {
> +				reg =3D <1>;
> +			};
> +		};
> +	};
> +};
> +
> +Example with SoC without integrated PHY
> +
> +emac: ethernet@1c0b000 {
> +	compatible =3D "allwinner,sun8i-a83t-emac";
> +	syscon =3D <&syscon>;
> +	reg =3D <0x01c0b000 0x104>;
> +	interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +	interrupt-names =3D "macirq";
> +	resets =3D <&ccu RST_BUS_EMAC>;
> +	reset-names =3D "stmmaceth";
> +	clocks =3D <&ccu CLK_BUS_EMAC>;
> +	clock-names =3D "stmmaceth";
> +	#address-cells =3D <1>;
> +	#size-cells =3D <0>;
> +
> +	phy-handle =3D <&ext_rgmii_phy>;
> +	phy-mode =3D "rgmii";
> +
>  	mdio: mdio {
> +		compatible =3D "snps,dwmac-mdio";
>  		#address-cells =3D <1>;
>  		#size-cells =3D <0>;
> -		int_mii_phy: ethernet-phy@1 {
> +		ext_rgmii_phy: ethernet-phy@1 {
>  			reg =3D <1>;
> -			clocks =3D <&ccu CLK_BUS_EPHY>;
> -			resets =3D <&ccu RST_BUS_EPHY>;
>  		};
>  	};
>  };
> --=20
> 2.13.5
>=20

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--2liiw4h4lfwu7u37
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZskXyAAoJEBx+YmzsjxAgwd0P/A06KyrhQYV1gHlUEWzQq308
Euz192INSAkGxkEevYa2kmbWp1GU8rknHeWVvvOBrydAB9COWFGIeAuOSiKrKEVb
xUR4pJv7sXUfroIMQiRboJ98JA5qIRUpjaVr0rEBkPaJtcq4LeRJ4G61BSmPHi2Q
55cBurJrkTbx77okzZO4xuZGvyWvahNF8Nqiyuo0mjgkFlqFe1vpW0bGpoVmmXaY
rxH9k1fAkLNDNMHc2NAYy5knf02qVmabzm4DgWk1nm5JbPJguzRiCgVbwWc6x9jk
9EolMRl/BQqA9QS3x44imM8/9uL++fH/Wpy8y9q0P8BDJWWS6UjQF/hr64p8uOQl
qZbPtF5LHcG7EnjZF5bYeUC/mEYg7zVcUQl2HIwNA/W/2QO5u4jwP9eAvwZSvM2R
bKuMz2qPsz4nvasDwCTQwDiujttO2CqFU9ovHdK1mZqHrXS4feFH5/5+o8DSDdy2
2eeyqxwGU7YkWXSHOzMYTw7ZkfbThi9X9Brz3t/GvzPwLlCDV0QkLHkQybFlmug+
zczOUhRPj9cjhFM/kJyq43UIQ8xQzADFmdeNeOqs9IqVbLF4b9oMLjQi1p+QpG2V
DNX5H6aiOLryNl85CzWhvTVAtA29hbVdxSwzc+7l2I4B+b7J7IOqeKdbz696TMgn
SCSXeoSz6uO7OYSbrfHe
=gfgd
-----END PGP SIGNATURE-----

--2liiw4h4lfwu7u37--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
