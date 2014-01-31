From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 6/6] can: sja1000: of: add reg-io-width property for
 8, 16 and 32-bit register access
Date: Fri, 31 Jan 2014 13:28:42 +0100
Message-ID: <52EB96FA.7090606@pengutronix.de>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-7-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KSnc30Glsvc8sVonLaerTfiAV4j4AhI0V"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-7-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KSnc30Glsvc8sVonLaerTfiAV4j4AhI0V
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 11:35 AM, Florian Vaussard wrote:
> Add the 'reg-io-width' property for 8, 16 and 32-bit access, like
> what is currently done with IORESOURCE_MEM_{8,16,32}BIT for non-OF
> boot.
>=20
> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
> ---
>  drivers/net/can/sja1000/sja1000_platform.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index 96a92a1..62ebc3d 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -103,8 +103,17 @@ static void sp_populate_of(struct sja1000_priv *pr=
iv, struct device_node *of)
>  	int err;
>  	u32 prop;
> =20
> -	priv->read_reg =3D sp_read_reg8;
> -	priv->write_reg =3D sp_write_reg8;
> +	of_property_read_u32(of, "reg-io-width", &prop);

The new property might not be available in the DT, please check the
return value of of_property_read_u32(). Use 8 bit wide as default.

> +	if (prop =3D=3D 4) {
> +		priv->read_reg =3D sp_read_reg32;
> +		priv->write_reg =3D sp_write_reg32;
> +	} else if (prop =3D=3D 2) {
> +		priv->read_reg =3D sp_read_reg16;
> +		priv->write_reg =3D sp_write_reg16;
> +	} else {
> +		priv->read_reg =3D sp_read_reg8;
> +		priv->write_reg =3D sp_write_reg8;
> +	}
> =20
>  	err =3D of_property_read_u32(of, "nxp,external-clock-frequency", &pro=
p);
>  	if (!err)
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KSnc30Glsvc8sVonLaerTfiAV4j4AhI0V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLrlvoACgkQjTAFq1RaXHMZqQCghYLBRrpJsLfzPeLallNa1tSi
OfYAn1psO5Sq+VEAUesIp0imEmagTV2y
=pWW0
-----END PGP SIGNATURE-----

--KSnc30Glsvc8sVonLaerTfiAV4j4AhI0V--
