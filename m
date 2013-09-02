From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Mon, 2 Sep 2013 19:11:20 +1000
Message-ID: <20130902191120.645dab701e2a68bb2ac6ba33@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__2_Sep_2013_19_11_20_+1000_6C8R8lGtzEmq_WU/"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cong Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:40508 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757452Ab3IBJLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 05:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__2_Sep_2013_19_11_20_+1000_6C8R8lGtzEmq_WU/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/vxlan.c: In function 'vxlan6_xmit_skb':
drivers/net/vxlan.c:1441:3: error: implicit declaration of function 'csum_i=
pv6_magic' [-Werror=3Dimplicit-function-declaration]
   uh->check =3D csum_ipv6_magic(saddr, daddr, skb->len,
   ^

Caused by commit e4c7ed415387 ("vxlan: add ipv6 support").

Please read Rule 1 in Documentation/SubmitChecklist.

I added the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 2 Sep 2013 19:04:51 +1000
Subject: [PATCH] vxlan: include the file that declares csum_ipv6_magic

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3ffb22d..35c78b3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -44,6 +44,7 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
 #endif
=20
 #define VXLAN_VERSION	"0.1"
--=20
1.8.4.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__2_Sep_2013_19_11_20_+1000_6C8R8lGtzEmq_WU/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSJFY4AAoJEECxmPOUX5FEsQoP/ivHGLtqVNgi1PRd7WIuSvZS
0BbO4i+L8c/rN7oHzelDk2/V6AZG585Crf8e3LMxQ9TotJ7iZQKNm7oA9KiWyxd1
FYuXBOnf5VmglAdQxInIYYZOWSttCKsuQegohHlYHNowP/orGfhmdKbf9XfWpMb7
AePqgsbYYhmr8uf2yB9NNsqgZMacRNuWPs621mqr4BV0IF5bQHgwLPwU8RTYz419
hiCH6tsJR0dvGG/nGCQAOyiqOWqUMJkXI8PaeGgEYxzODPE6IXqGIVR3rYEf5wJh
GkoVPznJOSoDJwkxClaowlWsd5VM3Kxho/JRyJ9olJz86XtIXnEYgzL2OeSPzBla
VO6xMzalSZjLNxJJqPZntU2++oVNctcQJ9zTsKIDwXNor1sKv4KIl/c2lm974p8A
wms4iVCj3Cp9OM067MCvckrNyIC/qVBqbZ3HGMf6NMBcBJkIyC2GQn29HH/HRM7S
QBxPqvnl1TBfz9DgqTQqaQFFiNxO4PO6JJV5FmiO3oPCxi0GvCaLGBiCrAp7YssO
ULHO1p/LMAgHiORJLUvbhBLprV8mJJOK4guxprde9h0Ofp3icI7wv1JYPBnpMcG2
vG6RV2tcYCzx3MwZlKE71nBxb2JAYwA1JJjqh55XlCeG/RMlpduBOKcfCHLQinob
ZF/v+4rMaDe/r2BTTWjH
=hJpj
-----END PGP SIGNATURE-----

--Signature=_Mon__2_Sep_2013_19_11_20_+1000_6C8R8lGtzEmq_WU/--
