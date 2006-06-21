From: Lukasz Stelmach <stlman@poczta.fm>
Subject: [patch]  ipv6 source address selection in addrconf.c (2.6.17)
Date: Wed, 21 Jun 2006 15:42:11 +0200
Message-ID: <44994CB3.6070302@poczta.fm>
References: <44986AE6.6090102@poczta.fm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig52008EDE3C4726AB3B76E752"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.poczta.interia.pl ([80.48.65.8]:65093 "EHLO
	smtp.poczta.interia.pl") by vger.kernel.org with ESMTP
	id S932157AbWFUNmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 09:42:44 -0400
Received: from poczta.interia.pl (mi04.poczta.interia.pl [10.217.12.4])
	by smtp.poczta.interia.pl (INTERIA.PL) with ESMTP id 4D9C927102D
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 15:42:28 +0200 (CEST)
To: Lukasz Stelmach <stlman@poczta.fm>
In-Reply-To: <44986AE6.6090102@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig52008EDE3C4726AB3B76E752
Content-Type: multipart/mixed;
 boundary="------------040509030408060909030206"

This is a multi-part message in MIME format.
--------------040509030408060909030206
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Lukasz Stelmach wrote:

> I found it when I was trying to figure out why when trying to connect t=
o
>=20
> 2001:200:0:8002:203:47ff:fea5:3085 (www.kame.net)
>=20
> with two global addresses assigned to the ethernet card
>=20
> fd24:6f44:46bd:face::254
> 2002:531f:d667:face::254
>=20
> rule 8 does not work and the first address is chosen.

The answer is that fc00::/7 matches 2001:: better because it gets the sam=
e
label (ipv6_saddr_label()). Although fc00::/7 addresses are defined as gl=
obal
unicast IMHO they should be treated *slightly* different. This is the pat=
ch.
Since 6to4 has its own label I have decided to assign one to Teredo too.

However, I still haven't found any clue in referneces to unassigned value=
 of
hiscore.addr_type.

--=20
By=C5=82o mi bardzo mi=C5=82o.                    Czwarta pospolita kl=C4=
=99ska, [...]
>=C5=81ukasz<                      Ju=C5=BC nie katolicka lecz z=C5=82odz=
iejska.  (c)PP


----------------------------------------------------------------------
Zobacz nowosci salonu moto w Madrycie >>> http://link.interia.pl/f1961

--------------040509030408060909030206
Content-Type: text/x-patch;
 name="addrconf.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="addrconf.diff"

--- /usr/src/linux/net/ipv6/addrconf.c~	2006-06-21 11:41:22.000000000 +02=
00
+++ /usr/src/linux/net/ipv6/addrconf.c	2006-06-21 15:33:26.000000000 +020=
0
@@ -862,6 +862,8 @@
   * 	2002::/16		2
   * 	::/96			3
   * 	::ffff:0:0/96		4
+  *	fc00::/7		5
+  * 	2001::/32		6
   */
 	if (type & IPV6_ADDR_LOOPBACK)
 		return 0;
@@ -871,6 +873,10 @@
 		return 4;
 	else if (addr->s6_addr16[0] =3D=3D htons(0x2002))
 		return 2;
+	else if ((addr->s6_addr[0] & 0xfe) =3D=3D 0xfc)
+		return 5;
+	else if (addr->s6_addr32[0] =3D=3D htonl(0x20010000))
+		return 6;
 	return 1;
 }
=20

--------------040509030408060909030206--

--------------enig52008EDE3C4726AB3B76E752
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEmUzBNdzY8sm9K9wRAg7qAJ95DzlBjqdyRJZUPU/Ukkqs6HOHPwCeKhEp
zVsSv/sozE+/wGkXVxECUSs=
=iRUZ
-----END PGP SIGNATURE-----

--------------enig52008EDE3C4726AB3B76E752--
