From: Christophe Saout <christophe@saout.de>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up
	IPSec with IPCOMP]
Date: Fri, 02 Jul 2004 23:35:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088804159.763.5.camel@leto.cs.pocnet.net>
References: <40E5A1B3.2020202@us.ibm.com>  <40E5D326.5000509@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mH+Ux6i7NwWDf3I2Zdzn"
Cc: James Morris <jmorris@intercode.com.au>, akpm@osdl.org,
        netdev <netdev@oss.sgi.com>, mjbligh@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40E5D326.5000509@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-mH+Ux6i7NwWDf3I2Zdzn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Am Fr, den 02.07.2004 um 14:27 Uhr -0700 schrieb Nivedita Singhvi:

> We are grabbing dst->xfrm lock in ipcomp_output(),
> and have it held when we call ipcomp_compress().
>=20
> Is that the issue? I don't have the crypto module
> code, but in_atomic() will be true.

Yes. But the code might also be called from softirq context, when a
packed from the NIC gets handled or when a slot in the queue becomes
free. (I've also got warnings from those two cases in my logs)

The compress/decompress calls should be able to be run from softirq
(atomic) context just like encrypt/decrypt.

I'm just wondering, why does deflate_compress call deflate_comp_init
when it is called the first time, but deflate_init is a noop? Shouldn't
the deflate_comp_init call just be moved to deflate_init?


--=-mH+Ux6i7NwWDf3I2Zdzn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Dies ist ein digital signierter Nachrichtenteil

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA5dU/ZCYBcts5dM0RAvu+AJ9uPlqwuUTSSMKvhKJwdBqCrZGkcACeMPpJ
y9HkduGM/pLuGamH56kM7KQ=
=7Vct
-----END PGP SIGNATURE-----

--=-mH+Ux6i7NwWDf3I2Zdzn--
