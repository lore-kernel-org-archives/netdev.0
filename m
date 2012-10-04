From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Thu, 4 Oct 2012 10:18:33 +1000
Message-ID: <20121004101833.019598b7e474c7b74e67ff20@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__4_Oct_2012_10_18_33_+1000_D+lzKzoQLdrrT6QI"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:36135 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932965Ab2JDASm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 20:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__4_Oct_2012_10_18_33_+1000_D+lzKzoQLdrrT6QI
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function 't4_memory_rw':
drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:420:2: error: implicit declarati=
on of function 'vmalloc' [-Werror=3Dimplicit-function-declaration]
drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:420:7: warning: assignment makes=
 pointer from integer without a cast [enabled by default]
drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:487:2: error: implicit declarati=
on of function 'vfree' [-Werror=3Dimplicit-function-declaration]
drivers/net/ethernet/chelsio/cxgb4/t4_hw.c: In function 'get_vpd_params':
drivers/net/ethernet/chelsio/cxgb4/t4_hw.c:530:6: warning: assignment makes=
 pointer from integer without a cast [enabled by default]

Caused by commit 8c357ebd5693 ("cxgb4: Dynamically allocate memory in
t4_memory_rw() and get_vpd_params()").  Missing include of
linux/vmalloc.h.

I have used the net tree from next-20121003 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__4_Oct_2012_10_18_33_+1000_D+lzKzoQLdrrT6QI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQbNXZAAoJEECxmPOUX5FEL1gQAIM7QsGAGZP4CwOnCDqxGZOX
G+DKMU4RdlmvoK9QxLgs91V1CBQYUe8sZwSryA61pVB812LVfe9ojEsE1DvnRyR1
Ts35KDoAdJxbymPYH7Cl0w2b/MlLzOIf7PHB5UhkZg7RPsFmxpZ635E31B023B20
iUYHU6ycU8zp9QjQHuSRfauqtJbTkmR/7roq9ahq+5t8UGMmV334//SiNz4EDN+N
TveGlrqzpz1V1suPFlw6kd9MTEp6PM0+Osln8C0Vu4GhyZx97Y5r0eHRJIxxVnKF
A3SF1Nv3wnBWvNp/OYCCVbu3cgg9WqNHmRe9NJabki7S1gDisxWqZBSTSq8tJcMs
Xww6o7X5DEY+MzkHliSbMRcASXpGf50SF6RstivK/wg0pBhxGHDm+u15Uv9WpP9M
ETvE52vvuPqGhT+0itT98emsCcS8b2TNgWf3zzwGTKFetBzoPjvndW6daoackvKx
c5rvd6I2KohaqT99yKFOuvXUaB4HnjaMiTEPyGgPvSJ37JTNlOQ7Qc+nvjrVQPxM
+znwswQ6FUD3seeEitrPQo8DDIz9mtMJeSiD0GlHEAYcFe8UwoA6cPf8/SsTrCTI
zdwVVI37MjYApeOLaA2nlMfrr79Pme+Em4xb8EaT6hFAkaWc4LKXHbB69GUbQPKo
buinWcCG3JthOMSxTNbN
=Pmg2
-----END PGP SIGNATURE-----

--Signature=_Thu__4_Oct_2012_10_18_33_+1000_D+lzKzoQLdrrT6QI--
