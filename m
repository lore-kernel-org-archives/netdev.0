From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Wed, 05 Nov 2014 14:24:33 +0100
Message-ID: <545A2511.2090205@pengutronix.de>
References: <1415096461-25576-1-git-send-email-rogerq@ti.com> <1415096461-25576-7-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="LCJsswbljj7cCvWPpckPnN823uLErUlKB"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415096461-25576-7-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LCJsswbljj7cCvWPpckPnN823uLErUlKB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2014 11:20 AM, Roger Quadros wrote:
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

Can you factor this into a common function? Which is used like this:

c_can_pinctrl_select_state(priv, PINCTRL_STATE_DEFAULT)

Otherwise looks god.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--LCJsswbljj7cCvWPpckPnN823uLErUlKB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWiURAAoJECte4hHFiupUeSMP/1vHpqjx3qIZnfsKqy4AHm/0
heuyB7tH9vaaKF3NE2OjPIWifJHeCUXnLzKAKd9tumDLZG0YnIJ7x+ocM9/aghkq
qCms4QWaORRr7IcDTGoOQonlzv6xmcGIvrI0+IHk/gkjLYk28zkkj1FA8+XCtIAV
8B7+kpb5g6J8p8/S5+pLJ/1dSVCXC7yOHBUAENM8YI4ykOHzut7NwxUXKQXARtyX
RLlYSVqV3+FWJSDhAtwNxOLEa74ZMcaV0HMn1KfWR66mf6jE0EHInqYdX0Avu+x9
pE0vPe1i/jyvgWvcNmTar2Z6I9J5mku2yeGM4E0ZEh/UAI1f1U5CSysL+ittJbfb
/6Rj5K8VBlzDqVI701xqv5MjhTS89W1940Und1cPcXRd+hpM+uGjP0b4D6ixKtOj
8G1J2WXL+2Uw5yho4ulmcUK83cGK+MkKda0uUO36RxuxCc4xUs0QMcaa4Gde0k6n
KGRKO9wZH4Zt9z0IZitKznk8bH6Ltk9LJdoH3NRPSx/gTuTyzCkxNfNuuis6ciet
k/U8AZ5Jpd8lRq5eTRUoDx/ZaugODdaASnBhcRjwrhpi11dHUvF439p6lI5s9mH5
iB9be4ARTY0iLc3VcYxVmXomuhnsLHmJyf6ruXsrWo92nHstIVKYVIr5o0ouxq2N
lOKUYpDoHFBxJMOepKGw
=MUP3
-----END PGP SIGNATURE-----

--LCJsswbljj7cCvWPpckPnN823uLErUlKB--
