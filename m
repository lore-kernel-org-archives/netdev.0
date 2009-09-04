From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: net tree build warning
Date: Fri, 4 Sep 2009 14:28:46 +1000
Message-ID: <20090904142846.02ad1b23.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_Sep_2009_14_28_46_+1000_k=Gr3D+JS9pqL6dV"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	roel kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:38310 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbZIDE3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Sep 2009 00:29:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__4_Sep_2009_14_28_46_+1000_k=Gr3D+JS9pqL6dV
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Today's linux-next build (x86_64 allmodconfig gcc-4.4.0) produced this
warning:

drivers/net/wan/dscc4.c: In function 'dscc4_rx_skb':
drivers/net/wan/dscc4.c:670: warning: suggest parentheses around comparison=
 in operand of '|'

which actually points out a bug, I think.  It is doing
	(x & (y | z)) !=3D y | z
when it probably means
	(x & (y | z)) !=3D (y | z)

Introduced by commit 5de3fcab91b0e1809eec030355d15801daf25083 ("WAN: bit
and/or confusion").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__4_Sep_2009_14_28_46_+1000_k=Gr3D+JS9pqL6dV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqgl34ACgkQjjKRsyhoI8x4wACfZTYdnGYFchBtfV/VlKmNOOej
smMAnAgnt07SP14IcWp4e6R4kEHr+fHB
=CF/f
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Sep_2009_14_28_46_+1000_k=Gr3D+JS9pqL6dV--
