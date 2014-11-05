From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 7/8] net: can: c_can: Add support for TI DRA7 DCAN
Date: Wed, 05 Nov 2014 14:30:33 +0100
Message-ID: <545A2679.2000905@pengutronix.de>
References: <1415096461-25576-1-git-send-email-rogerq@ti.com> <1415096461-25576-8-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="11UF7eAP3WIuVI5gFog5TRx1cKb7Sp0GD"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415096461-25576-8-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--11UF7eAP3WIuVI5gFog5TRx1cKb7Sp0GD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2014 11:21 AM, Roger Quadros wrote:
> DRA7 SoC has 2 CAN IPs. Provide compatible IDs and RAMINIT
> register data for both.

My understanding of the discussion with Wolfram was:
- We should put the number of the Interface into to DT as a regmap
  parameter.
- We put the method how to find the correct bits into the DT, via the
  compatible.

So for both CAN instances on the DRA7 we have a single compatible
"ti,dra7-d_can" and in the driver a mechanism that translates the number
of the instance into the needed bit offsets, e.g. via two arrays.

Same comments for patch 8/8.

Marc

>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  Documentation/devicetree/bindings/net/can/c_can.txt |  1 +
>  drivers/net/can/c_can/c_can_platform.c              | 16 +++++++++++++=
+++
>  2 files changed, 17 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Docu=
mentation/devicetree/bindings/net/can/c_can.txt
> index 917ac0e..746cc07 100644
> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
> @@ -4,6 +4,7 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
>  Required properties:
>  - compatible		: Should be "bosch,c_can" for C_CAN controllers and
>  			  "bosch,d_can" for D_CAN controllers.
> +			  Can be "ti,dra7-d_can1" or "ti,dra7-d_can2".
>  - reg			: physical base address and size of the C_CAN/D_CAN
>  			  registers map
>  - interrupts		: property with a value describing the interrupt
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index d058820..dc618ce 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -195,6 +195,20 @@ static struct c_can_driver_data d_can_drvdata =3D =
{
>  	.id =3D BOSCH_D_CAN,
>  };
> =20
> +static struct c_can_driver_data dra7_dcan1_drvdata =3D {
> +	.id =3D BOSCH_D_CAN,
> +	.raminit_start_bit =3D 3,
> +	.raminit_done_bit =3D 1,
> +	.raminit_pulse =3D true,
> +};
> +
> +static struct c_can_driver_data dra7_dcan2_drvdata =3D {
> +	.id =3D BOSCH_D_CAN,
> +	.raminit_start_bit =3D 5,
> +	.raminit_done_bit =3D 2,
> +	.raminit_pulse =3D true,
> +};
> +
>  static struct platform_device_id c_can_id_table[] =3D {
>  	{
>  		.name =3D KBUILD_MODNAME,
> @@ -215,6 +229,8 @@ MODULE_DEVICE_TABLE(platform, c_can_id_table);
>  static const struct of_device_id c_can_of_table[] =3D {
>  	{ .compatible =3D "bosch,c_can", .data =3D &c_can_drvdata },
>  	{ .compatible =3D "bosch,d_can", .data =3D &d_can_drvdata },
> +	{ .compatible =3D "ti,dra7-d_can1", .data =3D &dra7_dcan1_drvdata },
> +	{ .compatible =3D "ti,dra7-d_can2", .data =3D &dra7_dcan2_drvdata },
>  	{ /* sentinel */ },
>  };
>  MODULE_DEVICE_TABLE(of, c_can_of_table);
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--11UF7eAP3WIuVI5gFog5TRx1cKb7Sp0GD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWiZ5AAoJECte4hHFiupU39IQAKWxWKGllKMegWl2rhD8Bm/8
qKmGYWt2rI/GX4xSI3Y2NYya+5Hjfo/i9DXTUnNE+cWa+mAehIVw3TyreAYYkuNS
ui+eS31KWEn5EDliuHLLY32K5A08PZImDaL3f1V/OW+Es6rvKrkudasUvqQtBV99
hrjOf0AenYu8nLAKFu3ZAM689XtLFnlzt75tWAxBKGnOS3nNMdaoQzMdrq/wYTml
CD9e6NyLZbLY0HDNJL1zAJvEcAV9ZW/ZsFaDbi+Mr03veSvDX1MIqHpgDD8P8AX8
e84cAjBBPao7Y/odAY0HnytUOi0evrvTGeBiacpck5YSRGCKUenqXneCuM/DXHVt
GHMTNpmdWFYi+4BTSwGg38Xh2XFcVwYOwjBPPfdbY1reXkFFr5eLAPKM31Apt7G4
Wn8Nhu5OvpOp8ysONsFc1mk67N/YGS4QSr0MyUFepUfmInN6NeGN2LXKkxn/r+j4
ztkC4IvDUusmnxNHq92gljxjlMByejiXb6+iH5nRIWMGY3Q+DTHh9sLlmFhG79wy
rcBUC8FJO0u5Vp6BmKkSTJJ4FmOBWvRT0eDA6pa2wsXy/69VlrA/zpp0rsheVXuF
UbIr5Xk5pgDC9RLopj9aPHpd9dsR41XtB+S463SSjcI2l+sgJOI/ZMsXEkQ0J+wH
jzIktKEPOIrh7PXYTqDu
=678D
-----END PGP SIGNATURE-----

--11UF7eAP3WIuVI5gFog5TRx1cKb7Sp0GD--
