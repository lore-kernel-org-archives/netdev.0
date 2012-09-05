From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 5 Sep 2012 15:39:32 +1000
Message-ID: <20120905153932.eebf343364800678aecc98f2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__5_Sep_2012_15_39_32_+1000_9N60VTutzsfX4tGD"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__5_Sep_2012_15_39_32_+1000_9N60VTutzsfX4tGD
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/ipv6/netfilter/nf_nat_l3proto_ipv6.c: In function 'nf_nat_ipv6_csum_rec=
alc':
net/ipv6/netfilter/nf_nat_l3proto_ipv6.c:144:4: error: implicit declaration=
 of function 'csum_ipv6_magic' [-Werror=3Dimplicit-function-declaration]

Caused by commit 58a317f1061c ("netfilter: ipv6: add IPv6 NAT support").

(I always thought IPv6 NAT was a bad idea ;-))

I have applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 5 Sep 2012 15:34:58 +1000
Subject: [PATCH] netfilter: ipv6: using csum_ipv6_magic requires
 net/ip6_checksum.h

Fixes this build error:

net/ipv6/netfilter/nf_nat_l3proto_ipv6.c: In function 'nf_nat_ipv6_csum_rec=
alc':
net/ipv6/netfilter/nf_nat_l3proto_ipv6.c:144:4: error: implicit declaration=
 of function 'csum_ipv6_magic' [-Werror=3Dimplicit-function-declaration]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/=
nf_nat_l3proto_ipv6.c
index 81a2d1c..abfe75a 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -15,6 +15,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/secure_seq.h>
 #include <net/checksum.h>
+#include <net/ip6_checksum.h>
 #include <net/ip6_route.h>
 #include <net/ipv6.h>
=20
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__5_Sep_2012_15_39_32_+1000_9N60VTutzsfX4tGD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQRuWUAAoJEECxmPOUX5FEA7QP/2RIMOVFb2d5GBPQ9B32E+Tt
QR9je4HxVwxqQKbUnB99dRE1BWbmguCQjaOSdHeFESwnt2VpSXgAAeqYc9KiC1NC
aQsLRoDAVQyAaflIcrX6O76nQrPOUhoYcepnu+A+WkBUuwCYw1xNcymnpHSnNxn5
LGDOoPO/xkMXG3H5UMESvMIsNo6t2yvaiDHXlLcgBuQiU6sDM4/+dkbfxO8eYeVx
2M7wA9Xh5WRcXBQhbCBKKgqN0BDqbcqB894miiT3hKmxVqxOLVIw04TCf1ftbTee
qx7KgGIzOLAvL1UC+ZjllUS3iyTBRNxrlRYwu6bOpk+POYsfg0UsIleNA+p6Ezrf
pexMNRhyG7NPDwMEjUxG89A5HxDNnC8KRnZWHXccUpoInC2W2rfqSzeT2yk7mdIb
Tqd4MmG2JpIrhpQ73UX1+P+8RooqHGvGkS0Rn0Hvzw5gG75Xhw7e29P/7cOx5W+g
nZwCt4wwkw00Yn2FGfSrWkS9ZpcTcTdBtF5Y0lKxw9oECl7oL4HDtLIQ1b1FEe5C
TfDn5xSpwJpiaLy7yyQ/4Qp3aYM8d4JVG3Qh/iF3wOAyWn/aHV2cUc9652l4xDV9
hbon5U8KFIfyBrj+2ZmGI69QqZWl9NB9DFNnJEQK4szxTTLBj7OOyz7S2x8P2N3n
L2obNMSLwKg63hmKPqih
=2EfU
-----END PGP SIGNATURE-----

--Signature=_Wed__5_Sep_2012_15_39_32_+1000_9N60VTutzsfX4tGD--
