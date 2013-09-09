From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 13/16] c_can: flexcard: add ioctl to reset FIFO message
 object
Date: Mon, 09 Sep 2013 12:24:10 +0200
Message-ID: <522DA1CA.3040100@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-14-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="aWaIwQBixW7PiGUqxALfOorT6pwnncp04"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-14-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aWaIwQBixW7PiGUqxALfOorT6pwnncp04
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The FlexCard FIFO reset implementation did not reset the FIFO message o=
bject.
> Since the FIFO configuration is done from userspace a function to reset=
 the
> FIFO message object is needed. Add an ioctl to reset the FIFO message o=
bject
> from userspace.

Can you elaborate this a bit.

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
>
> ---
>  drivers/net/can/c_can/c_can.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 51ca2a6..670a6b1 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -1447,7 +1447,21 @@ void free_c_can_dev(struct net_device *dev)
>  }
>  EXPORT_SYMBOL_GPL(free_c_can_dev);
> =20
> +static int c_can_ioctl(struct net_device *dev, struct ifreq *ifr, int =
cmd)
> +{
> +	switch (cmd) {
> +	case SIOCDEVPRIVATE:
> +		c_can_inval_msg_object(dev, 0, FC_TXFIFO_MO);
> +		break;

What happens if you call this ioctl on non flexcard HW?

> +	default:
> +		return -ENOIOCTLCMD;
> +	}
> +
> +	return 0;
> +}
> +
>  static const struct net_device_ops c_can_netdev_ops =3D {
> +	.ndo_do_ioctl =3D c_can_ioctl,
>  	.ndo_open =3D c_can_open,
>  	.ndo_stop =3D c_can_close,
>  	.ndo_start_xmit =3D c_can_start_xmit,
>=20

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--aWaIwQBixW7PiGUqxALfOorT6pwnncp04
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItocoACgkQjTAFq1RaXHO6uQCfVS3BqNnQdvgjPbyDV/+sOG2t
I/oAoIJ11vxpfYXigt0w27APawEJclQh
=rac9
-----END PGP SIGNATURE-----

--aWaIwQBixW7PiGUqxALfOorT6pwnncp04--
