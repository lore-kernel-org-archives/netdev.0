From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net/can/mscan: add listen only mode
Date: Wed, 09 Nov 2011 16:52:38 +0100
Message-ID: <4EBAA1C6.8080503@pengutronix.de>
References: <1320325243-24907-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2A6E78DCF64837CF4E47A09B"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1320325243-24907-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2A6E78DCF64837CF4E47A09B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/03/2011 02:00 PM, Marc Kleine-Budde wrote:
> This patch adds listen only mode to the mscan controller.
>=20
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

ping, any comments?

Marc
> ---
>=20
> ...can be pulled via:
>=20
> The following changes since commit 8b3408f8ee994973869d8ba32c5bf482bc4d=
dca4:
>=20
>   dp83640: free packet queues on remove (2011-10-24 19:14:50 -0400)
>=20
> are available in the git repository at:
>   git://git.pengutronix.de/git/mkl/linux-2.6.git can/mscan-listen-only-=
for-net-next
>=20
> Marc Kleine-Budde (1):
>       net/can/mscan: add listen only mode
>=20
>  drivers/net/can/mscan/mscan.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/msca=
n.c
> index ec4a311..74f3b18 100644
> --- a/drivers/net/can/mscan/mscan.c
> +++ b/drivers/net/can/mscan/mscan.c
> @@ -581,7 +581,10 @@ static int mscan_open(struct net_device *dev)
> =20
>  	priv->open_time =3D jiffies;
> =20
> -	clrbits8(&regs->canctl1, MSCAN_LISTEN);
> +	if (ctrlmode.flags & CAN_CTRLMODE_LISTENONLY)
> +		setbits8(&regs->canctl1, MSCAN_LISTEN);
> +	else
> +		clrbits8(&regs->canctl1, MSCAN_LISTEN);
> =20
>  	ret =3D mscan_start(dev);
>  	if (ret)
> @@ -690,7 +693,8 @@ struct net_device *alloc_mscandev(void)
>  	priv->can.bittiming_const =3D &mscan_bittiming_const;
>  	priv->can.do_set_bittiming =3D mscan_do_set_bittiming;
>  	priv->can.do_set_mode =3D mscan_do_set_mode;
> -	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES |
> +		CAN_CTRLMODE_LISTENONLY;
> =20
>  	for (i =3D 0; i < TX_QUEUE_SIZE; i++) {
>  		priv->tx_queue[i].id =3D i;


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2A6E78DCF64837CF4E47A09B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk66ockACgkQjTAFq1RaXHMSdwCfeh9UdWainC7pA8gunknIJ7/E
nAsAnRBJRvd9F/OawVtSTtwgAwP0Xyl5
=GxXu
-----END PGP SIGNATURE-----

--------------enig2A6E78DCF64837CF4E47A09B--
