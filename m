From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 21:00:12 +0200
Message-ID: <53AB1C3C.8@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com> <53AAA3E9.6030409@pengutronix.de> <536c077e2e8b4dfabb4c07f696753a3c@BN1PR03MB220.namprd03.prod.outlook.com> <53AAAD84.1010400@pengutronix.de> <28c405ed255b42d09307274fccbec41e@BN1PR03MB220.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9JDoRAv5VFOt5sMuGbt7M1vtXMPoIO2Jd"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <28c405ed255b42d09307274fccbec41e@BN1PR03MB220.namprd03.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9JDoRAv5VFOt5sMuGbt7M1vtXMPoIO2Jd
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/25/2014 04:16 PM, bhupesh.sharma@freescale.com wrote:
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Wednesday, June 25, 2014 4:38 PM
>> To: Sharma Bhupesh-B45370; linux-can@vger.kernel.org
>> Cc: wg@grandegger.com; netdev@vger.kernel.org
>> Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write API=
s
>> for BE instances
>>
>> On 06/25/2014 01:01 PM, bhupesh.sharma@freescale.com wrote:
>>>> What about function pointers in the priv? So that flexcan_read()
>>>> becomes
>>>> priv->read().
>>
>>> That's what I propose (similar to what I did for C_CAN driver for
>>> 16-bit and 32-bit reg interfaces using platform data):
>>
>> Yes...but...
>>
>>> bool module_is_be =3D false;
>>
>> ...module_is_be is not that simple, on PPC true must be the default to=
 be
>> compatible with existing dts.
>=20
> How does this look (a bit messed up, so I am open for comments):

What about:

static u32 flexcan_read_le(void __iomem *addr)
{
	return ioread32(addr);
}

static u32 flexcan_read_be(void __iomem *addr)
{
	return ioread32be(addr);
}

flexcan_probe ()
{
	bool core_is_little =3D true;

	/* or #ifdef __BIG_ENDIAN ... #endif instead of IS_ENABLED() */
	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN) ||
	    of_property_read_bool(dev->dev.of_node, "big-endian"))
		core_is_little =3D false;

	if (core_is_little)
		priv->read =3D flexcan_read_le;
	else
		priv->read =3D flexcan_read_be;

}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--9JDoRAv5VFOt5sMuGbt7M1vtXMPoIO2Jd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOrHEEACgkQjTAFq1RaXHO7BgCdEMM1Bl5uQ6OUOkHAOS0yX6bT
h2MAoJnNZtIzYgCurBiI9WtikH6Y5ha5
=Zjn8
-----END PGP SIGNATURE-----

--9JDoRAv5VFOt5sMuGbt7M1vtXMPoIO2Jd--
