From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Thu, 26 Jun 2014 11:35:13 +0200
Message-ID: <53ABE951.8060800@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com> <53AAA3E9.6030409@pengutronix.de> <536c077e2e8b4dfabb4c07f696753a3c@BN1PR03MB220.namprd03.prod.outlook.com> <53AAAD84.1010400@pengutronix.de> <28c405ed255b42d09307274fccbec41e@BN1PR03MB220.namprd03.prod.outlook.com> <53AB1C3C.8@pengutronix.de> <53ABE7C4.8070105@pengutronix.de> <c02d4c6ac71d432bb99a547e3e17d027@BN1PR03MB220.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KrRvFQOAh0KBcjFuoHR2G1IesVaKtl4qC"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44017 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321AbaFZJfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 05:35:24 -0400
In-Reply-To: <c02d4c6ac71d432bb99a547e3e17d027@BN1PR03MB220.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KrRvFQOAh0KBcjFuoHR2G1IesVaKtl4qC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/26/2014 11:30 AM, bhupesh.sharma@freescale.com wrote:
>=20
>=20
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Thursday, June 26, 2014 2:59 PM
>> To: Sharma Bhupesh-B45370; linux-can@vger.kernel.org
>> Cc: wg@grandegger.com; netdev@vger.kernel.org
>> Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write API=
s
>> for BE instances
>>
>> On 06/25/2014 09:00 PM, Marc Kleine-Budde wrote:
>>>> How does this look (a bit messed up, so I am open for comments):
>>>
>>> What about:
>>>
>>> static u32 flexcan_read_le(void __iomem *addr) {
>>> 	return ioread32(addr);
>>> }
>>>
>>> static u32 flexcan_read_be(void __iomem *addr) {
>>> 	return ioread32be(addr);
>>> }
>>>
>>> flexcan_probe ()
>>> {
>>> 	bool core_is_little =3D true;
>>>
>>> 	/* or #ifdef __BIG_ENDIAN ... #endif instead of IS_ENABLED() */
>>> 	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) ||
>>> 	    of_property_read_bool(dev->dev.of_node, "big-endian"))
>>> 		core_is_little =3D false;
>>
>>  	if (of_property_read_bool(dev->dev.of_node, "little-endian"))
>> 		core_is_little =3D true;
>=20
> Seems better :)
>=20
> Let me try to spin a patch and test it at my end.

Totally untested this is :)

BTW: Please make an update to the DT bindings as a separate patch. This
patch should be the first one. Once the dust is settled, add the device
tree discussion mailing list on CC.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KrRvFQOAh0KBcjFuoHR2G1IesVaKtl4qC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOr6VEACgkQjTAFq1RaXHPB1gCbBlawoYVR5vgJZ2SCnQRWSN1p
GNEAnivvpUZrb6blxjaCswKlasqkLYNd
=OPHI
-----END PGP SIGNATURE-----

--KrRvFQOAh0KBcjFuoHR2G1IesVaKtl4qC--
