From: Lukasz Stelmach <stlman@poczta.fm>
Subject: Re: [patch] ipv6 source address selection in addrconf.c (2.6.17)
Date: Wed, 21 Jun 2006 18:05:43 +0200
Message-ID: <44996E57.8010705@poczta.fm>
References: <44986AE6.6090102@poczta.fm>	<44994CB3.6070302@poczta.fm> <20060622.001235.96410192.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?xYF1a2FzeiBTdGVsbWFjaA==?= <steelman@post.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.poczta.interia.pl ([80.48.65.8]:28312 "EHLO
	smtp.poczta.interia.pl") by vger.kernel.org with ESMTP
	id S1750757AbWFUQFn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 12:05:43 -0400
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060622.001235.96410192.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


- --- linux/net/ipv6/addrconf.c.orig	2006-06-21 11:41:22.000000000 +020=
0
+++ linux/net/ipv6/addrconf.c	2006-06-21 17:18:56.000000000 +0200
@@ -862,6 +862,8 @@ static int inline ipv6_saddr_label(const
   * 	2002::/16		2
   * 	::/96			3
   * 	::ffff:0:0/96		4
+  *	fc00::/7		5
+  * 	2001::/32		6
   */
 	if (type & IPV6_ADDR_LOOPBACK)
 		return 0;
@@ -869,8 +871,12 @@ static int inline ipv6_saddr_label(const
 		return 3;
 	else if (type & IPV6_ADDR_MAPPED)
 		return 4;
+	else if (addr->s6_addr32[0] =3D=3D htonl(0x20010000))
+		return 6;
 	else if (addr->s6_addr16[0] =3D=3D htons(0x2002))
 		return 2;
+	else if ((addr->s6_addr[0] & 0xfe) =3D=3D 0xfc)
+		return 5;
 	return 1;
 }

Two additional labels (RFC 3484, sec. 10.3) for IPv6 addreses
are defined to make a distinction between global unicast
addresses and Unique Local Addresses (fc00::/7, RFC 4193) and
Teredo (2001::/32, RFC 4380). It is necessary to avoid attempts
of connection that would either fail (eg. fec0:: to 2001:feed::)
or be sub-optimal (2001:0:: to 2001:feed::).

	Signed-off-by: =C5=81ukasz Stelmach <stlman@poczta.fm>
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD4DBQFEmW0LNdzY8sm9K9wRAjVGAKCOS1MVIro3bJ6szHzuAzaXXNaq/gCY4jfO
timfJc6SmrygMer36Tdqzg=3D=3D
=3DQzch
-----END PGP SIGNATURE-----

--=20
By=C5=82o mi bardzo mi=C5=82o.                    Czwarta pospolita kl=C4=
=99ska, [...]
>=C5=81ukasz<                      Ju=C5=BC nie katolicka lecz z=C5=82o=
dziejska.  (c)PP


----------------------------------------------------------------------
Zobacz nowosci salonu moto w Madrycie >>> http://link.interia.pl/f1961

