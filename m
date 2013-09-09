From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 12/16] c_can: Add flag to disable automatic retransmission
 of CAN frames
Date: Mon, 09 Sep 2013 12:21:57 +0200
Message-ID: <522DA145.9090507@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-13-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KUrniXjuUUnHOShfRfh1bb9a0l4sLkqDe"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-13-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KUrniXjuUUnHOShfRfh1bb9a0l4sLkqDe
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The C_CAN/D_CAN controler can automatic retransmit CAN after arbitratio=
n loss.
> Add a flag to CAN ctrlmode set the appropiate behaivior of this feature=
=2E

We already have this flag, it's called CAN_CTRLMODE_ONE_SHOT.

Marc

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c    | 16 +++++++++-------
>  include/uapi/linux/can/netlink.h |  2 ++
>  2 files changed, 11 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 02f7c89..51ca2a6 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -785,33 +785,35 @@ static void c_can_configure_msg_objects(struct ne=
t_device *dev, int invalidate)
>  static int c_can_chip_config(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u16 reg;
>  	int ret;
> =20
> -	/* enable automatic retransmission */
> -	priv->write_reg(priv, C_CAN_CTRL_REG,
> -			CONTROL_ENABLE_AR);
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_DAR)
> +		reg =3D CONTROL_DISABLE_AR;
> +	else
> +		reg =3D CONTROL_ENABLE_AR;
> =20
>  	if ((priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) &&
>  	    (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)) {
>  		/* loopback + silent mode : useful for hot self-test */
>  		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
> -				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
>  		priv->write_reg(priv, C_CAN_TEST_REG,
>  				TEST_LBACK | TEST_SILENT);
>  	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>  		/* loopback mode : useful for self-test function */
>  		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
> -				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
>  		priv->write_reg(priv, C_CAN_TEST_REG, TEST_LBACK);
>  	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
>  		/* silent mode : bus-monitoring mode */
>  		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
> -				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
>  		priv->write_reg(priv, C_CAN_TEST_REG, TEST_SILENT);
>  	} else
>  		/* normal mode*/
>  		priv->write_reg(priv, C_CAN_CTRL_REG,
> -				CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
> +				reg | CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
> =20
>  	/* configure message objects */
>  	c_can_configure_msg_objects(dev, 1);
> diff --git a/include/uapi/linux/can/netlink.h b/include/uapi/linux/can/=
netlink.h
> index 14966dd..fdce5af 100644
> --- a/include/uapi/linux/can/netlink.h
> +++ b/include/uapi/linux/can/netlink.h
> @@ -88,6 +88,8 @@ struct can_ctrlmode {
>  #define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
>  #define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
>  #define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
> +#define CAN_CTRLMODE_DAR		0x20	/* Disable Automatic
> +						 * Retransmission */
> =20
>  /*
>   * CAN device statistics
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KUrniXjuUUnHOShfRfh1bb9a0l4sLkqDe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItoUUACgkQjTAFq1RaXHNFjwCaA4rFMuuWNZNAJ/gUXPLFEB3v
njIAn2TXIWZnFknPx9HB50LJNTmR+TYg
=9kke
-----END PGP SIGNATURE-----

--KUrniXjuUUnHOShfRfh1bb9a0l4sLkqDe--
