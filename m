From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 04/16] c_can: fix receive buffer configuration
Date: Mon, 09 Sep 2013 12:51:04 +0200
Message-ID: <522DA818.1020802@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-5-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="6er5p5pG68BfWwmJxbv7FdpxIQhVxwkEk"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-5-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6er5p5pG68BfWwmJxbv7FdpxIQhVxwkEk
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The former implementation lacks some initialization of receive buffer.
> First the maximal buffer length was 0. The Buffer direction was not set=

> and the mask register a reserverd flag was cleared.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index bdb7bcd..886163f 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -116,6 +116,11 @@
>  				IF_COMM_CONTROL | IF_COMM_TXRQST | \
>  				IF_COMM_DATAA | IF_COMM_DATAB)
> =20
> +/* IFx mask */
> +#define IF_MASK_MXTD		BIT(31)
> +#define IF_MASK_MDIR		BIT(30)
> +#define IF_MASK_RES		BIT(29)
> +
>  /* IFx arbitration */
>  #define IF_ARB_MSGVAL		BIT(31)
>  #define IF_ARB_MSGXTD		BIT(30)
> @@ -653,11 +658,15 @@ static void c_can_configure_msg_objects(struct ne=
t_device *dev)
> =20
>  	/* setup receive message objects */
>  	for (i =3D C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
> -		c_can_setup_receive_object(dev, 0, i, 0, 0,
> -			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
> -
> -	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
> -			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
> +		c_can_setup_receive_object(dev, 0, i,
> +					   IF_MASK_MDIR | IF_MASK_RES, 0,
> +					   IF_MCONT_UMASK | IF_MCONT_RXIE |
> +					   IF_MCONT_DLC_MAX);

DLC_MAX should be added in this patch. not in 3.

> +
> +	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST,
> +				   IF_MASK_MDIR | IF_MASK_RES, 0,
> +				   IF_MCONT_UMASK | IF_MCONT_EOB |
> +				   IF_MCONT_RXIE | IF_MCONT_DLC_MAX);
>  }
> =20
>  /*
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6er5p5pG68BfWwmJxbv7FdpxIQhVxwkEk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItqBkACgkQjTAFq1RaXHMPWQCeMYQlUVG3BiJhhKRyW59/tJN/
WbQAn3PSh3qGJT5fuYrY2HQlWcvsbBAM
=0sTP
-----END PGP SIGNATURE-----

--6er5p5pG68BfWwmJxbv7FdpxIQhVxwkEk--
