From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] can: fix SJA1000 dlc for RTR packets
Date: Mon, 02 May 2011 17:15:41 +0200
Message-ID: <4DBECA9D.5030209@pengutronix.de>
References: <20110502145048.GF338@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7058310326373846318=="
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110502145048.GF338-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7058310326373846318==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD31B618BFCFC6FAF79293880"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD31B618BFCFC6FAF79293880
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/02/2011 04:50 PM, Kurt Van Dijck wrote:
> RTR frames do have a valid data length code on CAN.
> The driver for SJA1000 did not handle that situation properly.

Looks good!
>=20
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  drivers/net/can/sja1000/sja1000.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja100=
0/sja1000.c
> index a358ea9..f501bba 100644
> --- a/drivers/net/can/sja1000/sja1000.c
> +++ b/drivers/net/can/sja1000/sja1000.c
> @@ -346,10 +346,10 @@ static void sja1000_rx(struct net_device *dev)
>  		    | (priv->read_reg(priv, REG_ID2) >> 5);
>  	}
> =20
> +	cf->can_dlc =3D get_can_dlc(fi & 0x0F);
>  	if (fi & FI_RTR) {
>  		id |=3D CAN_RTR_FLAG;
>  	} else {
> -		cf->can_dlc =3D get_can_dlc(fi & 0x0F);
>  		for (i =3D 0; i < cf->can_dlc; i++)
>  			cf->data[i] =3D priv->read_reg(priv, dreg++);
>  	}
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> https://lists.berlios.de/mailman/listinfo/socketcan-core


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD31B618BFCFC6FAF79293880
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2+yp8ACgkQjTAFq1RaXHPYdACfT+gTeW1/6y1cBtDNAWiwIZmx
UE8AoJgs/XWJ7NSM+oG8PWMfLth/B7MM
=6EHx
-----END PGP SIGNATURE-----

--------------enigD31B618BFCFC6FAF79293880--

--===============7058310326373846318==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7058310326373846318==--
