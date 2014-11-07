From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Fri, 07 Nov 2014 15:54:40 +0100
Message-ID: <545CDD30.2070508@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="JIEXut5CEgL14Db53IjmwlMefxI7x8tkP"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-7-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JIEXut5CEgL14Db53IjmwlMefxI7x8tkP
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> DRA7 CAN IP suffers from a problem which causes it to be prevented
> from fully turning OFF (i.e. stuck in transition) if the module was
> disabled while there was traffic on the CAN_RX line.
>=20
> To work around this issue we select the SLEEP pin state by default
> on probe and use the DEFAULT pin state on CAN up and back to the
> SLEEP pin state on CAN down.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/can/c_can/c_can.c          | 20 ++++++++++++++++++++
>  drivers/net/can/c_can/c_can.h          |  1 +
>  drivers/net/can/c_can/c_can_platform.c | 20 ++++++++++++++++++++
>  3 files changed, 41 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 8e78bb4..4dfc3ce 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -35,6 +35,7 @@
>  #include <linux/list.h>
>  #include <linux/io.h>
>  #include <linux/pm_runtime.h>
> +#include <linux/pinctrl/consumer.h>
> =20
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> @@ -603,6 +604,15 @@ static int c_can_start(struct net_device *dev)
> =20
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
> +	/* activate pins */
> +	if (!IS_ERR(priv->pinctrl)) {
> +		struct pinctrl_state *s;
> +
> +		s =3D pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_DEFAULT);
> +		if (!IS_ERR(s))
> +			pinctrl_select_state(priv->pinctrl, s);
> +	}

Please put this common code into a seperate function.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--JIEXut5CEgL14Db53IjmwlMefxI7x8tkP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUXN0wAAoJECte4hHFiupUtRwP/iy2x1woPjJNK9bvzSiWua4J
wZzR9YL+VuikdWWB/Vjl54JZt6akXZV+t8EinX4oVn+O/UpiXDbuA/8bdzR7t3JG
qegUG6yJmFsuEeM8YU9aRmUmYdIGva978kLVsoBXKcHe1pasBn3k1avg8DnzJTtq
1pjZt0n+0ni+I2GEc1AUHMt4YbqV8piZQvjdoYoxWJtCwnZexr1rA22BM4j0DcRW
dxRru6wj9bNYz31U7dPWQXJ+XWen2a3bALETCLIjU5TPZT0I6TTZYGgMYfRpTVLf
Yk9enGCsSHScDdtV/FG2BXjIx5mXYZ5K+8jI/IuQdj3u9P0xHAwLVxiIhevGWr0V
zYfB4xqDQUhWmWxBGlHgM3SgcQ3FANsIlTK5zf+GdTcIna4U1gaZsdAOa7sX8cvr
aL4QlG5YFka8CG+8LUdnYAyItZIUW5G9cg/PaDSyBX91xZ+YU1fBKhPQoVYy2Inc
JnwNsElMoS4G96wdg/KxjJRXfsJHUfmgEELvvQZJNhvjHF2F9+OyBloJrBBhwpE5
JyRNz7cyFkrir67EBtHQsPxPobo2VNlG3U6oZhr9mV3P3MB0CQo6oLw97WNR0Ruc
rT09uuwvfWms2uA/a718zAh/UpYzEAq4v/8QFDsQx7p49DaIoNflMQdEy91BKhS/
WETbtUa6D8+5FOcKG2pm
=PqsI
-----END PGP SIGNATURE-----

--JIEXut5CEgL14Db53IjmwlMefxI7x8tkP--
