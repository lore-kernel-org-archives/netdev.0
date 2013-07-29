From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
 (netnext-tree related)
Date: Mon, 29 Jul 2013 16:25:44 +1000
Message-ID: <20130729162544.574e4d7ffccf0f6bff5ba4c4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__29_Jul_2013_16_25_44_+1000_0/6U+c3SRkyad=HA"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Jul_2013_16_25_44_+1000_0/6U+c3SRkyad=HA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/core/pktgen.c: In function 'fill_packet_ipv6':
net/core/pktgen.c:2906:3: error: implicit declaration of function 'csum_ipv=
6_magic' [-Werror=3Dimplicit-function-declaration]
   udph->check =3D ~csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPRO=
TO_UDP, 0);
   ^

Caused by commit c26bf4a51308 ("pktgen: Add UDPCSUM flag to support UDP che=
cksums") from the net-next tree.

I added this commit:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 29 Jul 2013 16:21:26 +1000
Subject: [PATCH] pktgen: add needed include file

Fixes this on PowerPC (at least):

net/core/pktgen.c: In function 'fill_packet_ipv6':
net/core/pktgen.c:2906:3: error: implicit declaration of function 'csum_ipv=
6_magic' [-Werror=3Dimplicit-function-declaration]
   udph->check =3D ~csum_ipv6_magic(&iph->saddr, &iph->daddr, udplen, IPPRO=
TO_UDP, 0);
   ^

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/pktgen.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2dec6f1..261357a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -161,6 +161,7 @@
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
+#include <net/ip6_checksum.h>
 #include <net/addrconf.h>
 #ifdef CONFIG_XFRM
 #include <net/xfrm.h>
--=20
1.8.4.rc0

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__29_Jul_2013_16_25_44_+1000_0/6U+c3SRkyad=HA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR9grsAAoJEECxmPOUX5FEwhUP/1p4B/Ql355Tqwo8FRg+n3JP
GEN5MGSBENs9WtIv88KhHniMagGbRfvqOBeanLXiXt3v4GHJKk8/8ZE0w+vpIzFA
lNSdoG7sYIV6ta8fRWdngsX78VkdQ0mkw9DR2fIixHECDfkUpKo2IvYfy0NJHtdi
iJ93fKZQ6PrI+sDOx2CwdCFjof3iC0BSnp/Fdo9KnW23cAdi5HGP09F+SkvdnVTb
XMMQkLa1leYsEXzmUDP322s1XR5ZJsgX1v13b7wnLoeaeuLUddulTx5Z5wJhhJjT
jO08/Sl+hzD+dEVKcau8lgRQmrXdJMVFgjrrcj/Em2pxt7n7VQcIf3TGB4aSzCcY
zRJgR/gjxIoqOnR7o62g+gkkWg9ZUVedn7pd8dSoO5ddRSlRgTnHXxSrB8yi9nsN
CMX0TMr6CYekZV61UOGOJWfeqtVKeyjwDG2ekrEh8TC2Rof2Gdva5ndpLWn23M10
RSRP7TqumUzd54r5NKwMrmD1kfoeyJiDLQ/WYN7vCcM9fsGJ8HueX+y0Nn4wnl25
NdGHV7VFxX+n1tzLeUYvB2to3vFelbG5t1gUzyI/qLBQtgY8TxeGtTBFHRPh2b9w
zgplolod4mwoXD0ccqMf598K8e8PmTHeQ8btHPUz/eQ0EQlVDx6d/SFCiSSBhkhT
LuZ7Ea9XjxqnRKJOIMxQ
=8tmQ
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Jul_2013_16_25_44_+1000_0/6U+c3SRkyad=HA--
