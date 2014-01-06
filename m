From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Disable broken flexcan driver build for big
 endian CPU on ARM
Date: Mon, 06 Jan 2014 10:00:35 +0100
Message-ID: <52CA70B3.5020004@pengutronix.de>
References: <1388944283-29990-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KLRVP1ajhAdnpIXU12PQGGVjt9qLKNMg2"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1388944283-29990-1-git-send-email-linux@roeck-us.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KLRVP1ajhAdnpIXU12PQGGVjt9qLKNMg2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/05/2014 06:51 PM, Guenter Roeck wrote:
> Building arm:allmodconfig fails with
>=20
> flexcan.c: In function 'flexcan_read':
> flexcan.c:243:2: error: implicit declaration of function 'in_be32'
> flexcan.c: In function 'flexcan_write':
> flexcan.c:248:2: error: implicit declaration of function 'out_be32'
>=20
> in_be32 and out_be32 do not (or no longer) exist for ARM targets.
> Mark the build for arm on big endian CPUs as broken.

I think there isn't any ARM with this CAN core that supports BE (at
least on Linux).

> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> If there is a better solution, please let me know and I'll be happy
> to provide a patch.
>=20
>  drivers/net/can/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 3c06947..8d202f4 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -104,7 +104,7 @@ config CAN_JANZ_ICAN3
> =20
>  config CAN_FLEXCAN
>  	tristate "Support for Freescale FLEXCAN based chips"
> -	depends on ARM || PPC
> +	depends on (ARM || PPC) && (BROKEN || !ARM || CPU_LITTLE_ENDIAN)

Why not make it:

	depends on (ARM && CPU_LITTLE_ENDIAN) || PPC

>  	---help---
>  	  Say Y here if you want to support for Freescale FlexCAN.
> =20
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KLRVP1ajhAdnpIXU12PQGGVjt9qLKNMg2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLKcLMACgkQjTAFq1RaXHOjMgCfaoiOijjMdGb7W7JGoUb/rxqR
NtEAn2BXIkcFk5/5fkKkGaaliQHVGjix
=bgyR
-----END PGP SIGNATURE-----

--KLRVP1ajhAdnpIXU12PQGGVjt9qLKNMg2--
