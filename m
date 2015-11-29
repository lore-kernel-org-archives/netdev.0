From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 19:38:05 +0100
Message-ID: <565B460D.9080002@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="IVwxEukI8Bhr1cSQVa7TwAWbnCq476H2w"
Cc: pebolle@tiscali.nl, isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:44428 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbbK2SiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 13:38:19 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 527D42097F
	for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 13:38:18 -0500 (EST)
In-Reply-To: <565B4256.6080101@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IVwxEukI8Bhr1cSQVa7TwAWbnCq476H2w
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 29.11.2015 um 19:22 schrieb Peter Hurley:
> On 11/29/2015 10:30 AM, Tilman Schmidt wrote:
>>
>> Judging from the backtrace below this must be the call
>>
>>         kfree(cs->hw.ser);
>>
>> in drivers/isdn/gigaset/ser-gigaset.c line 375.
>> cs->hw.ser is of type struct ser_cardstate *.
>> struct ser_cardstate consists of a struct platform_device, a struct
>> completion, an atomic_t and a pointer. No timer_list.
[...]
>=20
> The platform_device embedded in struct ser_cardstate hasn't been releas=
ed when
> you kfree() the memory it's in.

How so? The kfree() call quoted above is immediately preceded by:

        platform_device_unregister(&cs->hw.ser->dev);

Thanks,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--IVwxEukI8Bhr1cSQVa7TwAWbnCq476H2w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWW0YYAAoJEFPuqx0v+F+q/PgIALRbCX3jbhydRL2izb1IEDmW
+96TdoaHqMmA+qksHKPgkTox/DC+cjm/o9UjakGWAZFR/4//G7TJTUsX0fSwVtAi
SUXvUHf1Ja7crbExA9j+y84Izgaq+1LpkidzgFHGgn1Vo62xBOZ/4f6Yp1GJQmVw
q6MJjzguSIucPKW/WXN6Uy/jkfY9KxeWjY5W13mCukCu954LHpVVWm6tBQf4KrPt
b3CQw11t10jiuPpDXiq+zn64ZPOORanLRnagRUmaqE+Upn3uU7cveZyIZapicSmD
/wEiLdqIcKrlXd+bDKnb9tnBUWt4Kz5I58lIXsCkG3ciwo6OUDfpRPeDuymVsA0=
=wiF7
-----END PGP SIGNATURE-----

--IVwxEukI8Bhr1cSQVa7TwAWbnCq476H2w--
