From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Thu, 26 Jun 2014 11:28:36 +0200
Message-ID: <53ABE7C4.8070105@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com> <53AAA3E9.6030409@pengutronix.de> <536c077e2e8b4dfabb4c07f696753a3c@BN1PR03MB220.namprd03.prod.outlook.com> <53AAAD84.1010400@pengutronix.de> <28c405ed255b42d09307274fccbec41e@BN1PR03MB220.namprd03.prod.outlook.com> <53AB1C3C.8@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="MOKc7f7Ph5c6HaMAmS7cpmOmAo7lERmrK"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53AB1C3C.8@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MOKc7f7Ph5c6HaMAmS7cpmOmAo7lERmrK
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/25/2014 09:00 PM, Marc Kleine-Budde wrote:
>> How does this look (a bit messed up, so I am open for comments):
>=20
> What about:
>=20
> static u32 flexcan_read_le(void __iomem *addr)
> {
> 	return ioread32(addr);
> }
>=20
> static u32 flexcan_read_be(void __iomem *addr)
> {
> 	return ioread32be(addr);
> }
>=20
> flexcan_probe ()
> {
> 	bool core_is_little =3D true;
>=20
> 	/* or #ifdef __BIG_ENDIAN ... #endif instead of IS_ENABLED() */
> 	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) ||
> 	    of_property_read_bool(dev->dev.of_node, "big-endian"))
> 		core_is_little =3D false;

 	if (of_property_read_bool(dev->dev.of_node, "little-endian"))
		core_is_little =3D true;

> 	if (core_is_little)
> 		priv->read =3D flexcan_read_le;
> 	else
> 		priv->read =3D flexcan_read_be;
>=20
> }

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--MOKc7f7Ph5c6HaMAmS7cpmOmAo7lERmrK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOr58QACgkQjTAFq1RaXHPiYQCglXqPedW8zSZi6l702C2S1JbV
0kgAn1aOprklXh301fT3n3xJ8YSIoTPF
=ZQjO
-----END PGP SIGNATURE-----

--MOKc7f7Ph5c6HaMAmS7cpmOmAo7lERmrK--
