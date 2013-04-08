From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: sja1000: use cpu endian
Date: Mon, 08 Apr 2013 15:57:09 +0200
Message-ID: <5162CCB5.3000605@pengutronix.de>
References: <1365428932.5760.52.camel@lovely>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2AUCABWFTIWROVVNMBFVF"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Andreas Larsson <andreas@gaisler.com>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>, Daniel Mack <daniel@zonque.org>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55229 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935482Ab3DHN5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 09:57:25 -0400
In-Reply-To: <1365428932.5760.52.camel@lovely>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2AUCABWFTIWROVVNMBFVF
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/08/2013 03:48 PM, Christoph Fritz wrote:

Please add a patch description to the patch, as some subsystem
maintainers don't take patches without it.

What about using of_property_read_u32, instead of open coding it?

Marc

> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> ---
>  drivers/net/can/sja1000/sja1000_of_platform.c |   26 ++++++++++++-----=
-------
>  1 files changed, 13 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/ne=
t/can/sja1000/sja1000_of_platform.c
> index 6433b81..83a13d2 100644
> --- a/drivers/net/can/sja1000/sja1000_of_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_of_platform.c
> @@ -97,7 +97,7 @@ static int sja1000_ofp_probe(struct platform_device *=
ofdev)
>  	struct sja1000_priv *priv;
>  	struct resource res;
>  	const u32 *prop;
> -	int err, irq, res_size, prop_size;
> +	int err, irq, res_size;
>  	void __iomem *base;
> =20
>  	err =3D of_address_to_resource(np, 0, &res);
> @@ -138,27 +138,27 @@ static int sja1000_ofp_probe(struct platform_devi=
ce *ofdev)
>  	priv->read_reg =3D sja1000_ofp_read_reg;
>  	priv->write_reg =3D sja1000_ofp_write_reg;
> =20
> -	prop =3D of_get_property(np, "nxp,external-clock-frequency", &prop_si=
ze);
> -	if (prop && (prop_size =3D=3D  sizeof(u32)))
> -		priv->can.clock.freq =3D *prop / 2;
> +	prop =3D of_get_property(np, "nxp,external-clock-frequency", NULL);
> +	if (prop)
> +		priv->can.clock.freq =3D be32_to_cpup(prop) / 2;
>  	else
>  		priv->can.clock.freq =3D SJA1000_OFP_CAN_CLOCK; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,tx-output-mode", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)))
> -		priv->ocr |=3D *prop & OCR_MODE_MASK;
> +	prop =3D of_get_property(np, "nxp,tx-output-mode", NULL);
> +	if (prop)
> +		priv->ocr |=3D be32_to_cpup(prop) & OCR_MODE_MASK;
>  	else
>  		priv->ocr |=3D OCR_MODE_NORMAL; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,tx-output-config", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)))
> -		priv->ocr |=3D (*prop << OCR_TX_SHIFT) & OCR_TX_MASK;
> +	prop =3D of_get_property(np, "nxp,tx-output-config", NULL);
> +	if (prop)
> +		priv->ocr |=3D (be32_to_cpup(prop) << OCR_TX_SHIFT) & OCR_TX_MASK;
>  	else
>  		priv->ocr |=3D OCR_TX0_PULLDOWN; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,clock-out-frequency", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)) && *prop) {
> -		u32 divider =3D priv->can.clock.freq * 2 / *prop;
> +	prop =3D of_get_property(np, "nxp,clock-out-frequency", NULL);
> +	if (prop) {
> +		u32 divider =3D priv->can.clock.freq * 2 / be32_to_cpup(prop);
> =20
>  		if (divider > 1)
>  			priv->cdr |=3D divider / 2 - 1;
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2AUCABWFTIWROVVNMBFVF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFizLkACgkQjTAFq1RaXHPeJgCdHI2fzq6zLHXp7rQr4rxgyMk7
ypEAoIGTdouXRW14qRFjc1SYmJdd+Y/T
=nuQM
-----END PGP SIGNATURE-----

------enig2AUCABWFTIWROVVNMBFVF--
