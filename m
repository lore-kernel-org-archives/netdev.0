From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] rcar_can: add device tree support
Date: Wed, 02 Jul 2014 00:50:45 +0200
Message-ID: <53B33B45.1060205@pengutronix.de>
References: <201407020227.04235.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Jux4XWldmuaXqkRp0m2Hwquw5cnrSP1Ei"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com, rdunlap@infradead.org,
	linux-doc@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, grant.likely@linaro.org,
	devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <201407020227.04235.sergei.shtylyov@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Jux4XWldmuaXqkRp0m2Hwquw5cnrSP1Ei
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/02/2014 12:27 AM, Sergei Shtylyov wrote:
> Add support of the device tree probing for the Renesas R-Car CAN contro=
llers
> documenting the device tree bindings as necessary.

Please put the DT documentation into a separate patch, make it the first
one. When reposting, please put the device tree mailing list on Cc.

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against the Dave Miller's 'net-next.git' repo ('linux-can-=
next.git'
> repo still doesn't have the R-Car CAN driver for some reason).

Should be fixed now :)

>=20
>  Documentation/devicetree/bindings/net/can/rcar_can.txt |   40 ++++++++=
+++++++++
>  drivers/net/can/rcar_can.c                             |   28 ++++++++=
+--
>  2 files changed, 63 insertions(+), 5 deletions(-)
>=20
> Index: net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
> @@ -0,0 +1,40 @@
> +Renesas R-Car CAN controller Device Tree Bindings
> +-------------------------------------------------
> +
> +Required properties:
> +- compatible: "renesas,can-r8a7778" if CAN controller is a part of R8A=
7778 SoC.
> +	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 So=
C.
> +	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 So=
C.
> +	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 So=
C.

AFAIK we usually specify the first SoC with this core as the only
compatible.

> +- reg: physical base address and size of the R-Car CAN register map.
> +- interrupts: interrupt specifier for the sole interrupt.
> +- clocks: phandle and clock specifier for the R-Car CAN clock input.
> +- pinctrl-0: pin control group to be used for this controller.
> +- pinctrl-names: must be "default".
> +
> +Optional properties:
> +- clock-select: R-Car CAN Clock Source Select. Valid values are:
> +		<0x0> (default) : Peripheral clock (clkp1)
> +		<0x1> : Peripheral clock (clkp2)
> +		<0x3> : Externally input clock
> +
> +Example
> +-------
> +
> +SoC common .dtsi file:
> +
> +	can0: can@e6e80000 {
> +		compatible =3D "renesas,can-r8a7791";
> +		reg =3D <0 0xe6e80000 0 0x1000>;
> +		interrupts =3D <0 186 IRQ_TYPE_LEVEL_HIGH>;
> +		clocks =3D <&mstp9_clks R8A7791_CLK_RCAN0>;
> +		status =3D "disabled";
> +	};
> +
> +Board specific .dts file:
> +
> +&can0 {
> +	pinctrl-0 =3D <&can0_pins>;
> +	pinctrl-names =3D "default";
> +	status =3D "okay";
> +};
> Index: net-next/drivers/net/can/rcar_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/can/rcar_can.c
> +++ net-next/drivers/net/can/rcar_can.c
> @@ -20,6 +20,7 @@
>  #include <linux/can/dev.h>
>  #include <linux/clk.h>
>  #include <linux/can/platform/rcar_can.h>
> +#include <linux/of.h>
> =20
>  #define RCAR_CAN_DRV_NAME	"rcar_can"
> =20
> @@ -722,13 +723,20 @@ static int rcar_can_probe(struct platfor
>  	struct net_device *ndev;
>  	struct resource *mem;
>  	void __iomem *addr;
> +	u32 clock_select =3D 0;
>  	int err =3D -ENODEV;
>  	int irq;
> =20
> -	pdata =3D dev_get_platdata(&pdev->dev);
> -	if (!pdata) {
> -		dev_err(&pdev->dev, "No platform data provided!\n");
> -		goto fail;
> +	if (!pdev->dev.of_node) {

nitpick: please make it positive logic.

> +		pdata =3D dev_get_platdata(&pdev->dev);
> +		if (!pdata) {
> +			dev_err(&pdev->dev, "No platform data provided!\n");
> +			goto fail;
> +		}
> +		clock_select =3D pdata->clock_select;
> +	} else {
> +		of_property_read_u32(pdev->dev.of_node, "clock-select",
> +				     &clock_select);
>  	}
> =20
>  	irq =3D platform_get_irq(pdev, 0);
> @@ -765,7 +773,7 @@ static int rcar_can_probe(struct platfor
>  	ndev->flags |=3D IFF_ECHO;
>  	priv->ndev =3D ndev;
>  	priv->regs =3D addr;
> -	priv->clock_select =3D pdata->clock_select;
> +	priv->clock_select =3D clock_select;
>  	priv->can.clock.freq =3D clk_get_rate(priv->clk);
>  	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
>  	priv->can.do_set_mode =3D rcar_can_do_set_mode;
> @@ -858,10 +866,20 @@ static int __maybe_unused rcar_can_resum
> =20
>  static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_r=
esume);
> =20
> +static const struct of_device_id rcar_can_of_table[] __maybe_unused =3D=
 {
> +	{ .compatible =3D "renesas,can-r8a7778" },
> +	{ .compatible =3D "renesas,can-r8a7779" },
> +	{ .compatible =3D "renesas,can-r8a7790" },
> +	{ .compatible =3D "renesas,can-r8a7791" },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, rcar_can_of_table);
> +
>  static struct platform_driver rcar_can_driver =3D {
>  	.driver =3D {
>  		.name =3D RCAR_CAN_DRV_NAME,
>  		.owner =3D THIS_MODULE,
> +		.of_match_table =3D of_match_ptr(rcar_can_of_table),
>  		.pm =3D &rcar_can_pm_ops,
>  	},
>  	.probe =3D rcar_can_probe,
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Jux4XWldmuaXqkRp0m2Hwquw5cnrSP1Ei
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOzO0UACgkQjTAFq1RaXHNc5ACcDvlJPiXfzmtee7wqICQVLf39
i0MAn1zrarh5I6OiLo1D0RVgCEuvck5Z
=Il/0
-----END PGP SIGNATURE-----

--Jux4XWldmuaXqkRp0m2Hwquw5cnrSP1Ei--
