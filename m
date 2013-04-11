From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: sja1000: fix endian on arm
Date: Thu, 11 Apr 2013 21:21:34 +0200
Message-ID: <51670D3E.1020808@pengutronix.de>
References: <1365428932.5760.52.camel@lovely>  <5162CCB5.3000605@pengutronix.de> <1365705884.4136.5.camel@mars>  <51670532.5060101@pengutronix.de>  <1365706413.4136.15.camel@mars> <1365707697.4136.26.camel@mars>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2OFNKTEVIGRQRMBNHKFNI"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Andreas Larsson <andreas@gaisler.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bill Pemberton <wfp5p@virginia.edu>, linux-can@vger.kernel.org,
	Daniel Mack <daniel@zonque.org>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57336 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab3DKTVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 15:21:50 -0400
In-Reply-To: <1365707697.4136.26.camel@mars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2OFNKTEVIGRQRMBNHKFNI
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/11/2013 09:14 PM, Christoph Fritz wrote:
> To get correct endian on arm cpus while reading device tree properties,=

> this patch replaces of_get_property() with of_property_read_u32().
>=20
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>

[...]

> -	prop =3D of_get_property(np, "nxp,clock-out-frequency", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)) && *prop) {
> -		u32 divider =3D priv->can.clock.freq * 2 / *prop;
> +	err =3D of_property_read_u32(np, "nxp,clock-out-frequency", &prop);
> +	if (!err) {

What about checking for "prop !=3D 0" as the original code does?

> +		u32 divider =3D priv->can.clock.freq * 2 / prop;

To prevent a potential div-by-zero here?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2OFNKTEVIGRQRMBNHKFNI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFnDUEACgkQjTAFq1RaXHN+bgCfWVoZZUKV7bDypfW8wv5JdtHv
1CYAn20p33FGt+ctS5Euro0AnhxetyHs
=Jtm6
-----END PGP SIGNATURE-----

------enig2OFNKTEVIGRQRMBNHKFNI--
