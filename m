From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Thu, 19 Apr 2012 16:28:59 +1000
Message-ID: <20120419162859.904574e2518c5a904802efbc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__19_Apr_2012_16_28_59_+1000_+ND=i_BVMY_QzusZ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	majianpeng <majianpeng@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__19_Apr_2012_16_28_59_+1000_+ND=i_BVMY_QzusZ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (sparc64 defconfig)
failed like this:

net/ipv4/route.c: In function 'ip_static_sysctl_init':
net/ipv4/route.c:3517:2: error: implicit declaration of function 'kmemleak_=
not_leak' [-Werror=3Dimplicit-function-declaration]

Caused by commit 7f5938810890 ("net/ipv4:Remove two memleak reports by
kmemleak_not_leak").

net/core/sysctl_net_core.c: In function 'sysctl_core_init':
net/core/sysctl_net_core.c:259:2: error: implicit declaration of function '=
kmemleak_not_leak' [-Werror=3Dimplicit-function-declaration]

Caused by commit 798ec84d4575 ("net/core:Remove memleak reports by
kmemleak_not_leak").

I added this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 19 Apr 2012 16:25:16 +1000
Subject: [PATCH] net: using kmemleak_not_leak requires including kmemleak.h

fixes these build errors:

net/ipv4/route.c: In function 'ip_static_sysctl_init':
net/ipv4/route.c:3517:2: error: implicit declaration of function 'kmemleak_=
not_leak' [-Werror=3Dimplicit-function-declaration]
net/core/sysctl_net_core.c: In function 'sysctl_core_init':
net/core/sysctl_net_core.c:259:2: error: implicit declaration of function '=
kmemleak_not_leak' [-Werror=3Dimplicit-function-declaration]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/sysctl_net_core.c |    1 +
 net/ipv4/route.c           |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cee5991..247c69b 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -14,6 +14,7 @@
 #include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/kmemleak.h>
=20
 #include <net/ip.h>
 #include <net/sock.h>
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcd4744..dcb4205 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -93,6 +93,7 @@
 #include <linux/times.h>
 #include <linux/slab.h>
 #include <linux/prefetch.h>
+#include <linux/kmemleak.h>
 #include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
--=20
1.7.10.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__19_Apr_2012_16_28_59_+1000_+ND=i_BVMY_QzusZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPj7CrAAoJEECxmPOUX5FEFxEP/1r6QprImkxH88071MmYWJ05
ktOAZBeeBSklibTVcjGoIxzy7uxaaWS8fkcsiC+I6a7mCgAlwyVrhWelM/d8DzrQ
arqfaHGqW8LOnDs3G893Ny2X/sX3+YKQVdiKWeJ3YuP+qYYYdKJWzj7mu5i/3p9N
Kw/y3qIk4ZWw44mATd6Sa1w/VmbK6OXDHlwiZeEWeedXqOkthL6cMD0/lPzsH8QQ
TBWKgto9sU59DE2pytRBjfWFArj0smyV2WSNoTJlUS9nJMVyAz8w0DrZ08P3paWz
DZlsELnPQxQ7aP3fPsrbDkGnPik6MdlvbFa3Wv4mG7iqhoCc2n6CHXwe9upONh2R
5nfw52+X9M/+sOfQIaUwzZ8NRWsnDIX6vbc7r6o7OK3EbWgxAhl5DmBXT4aurJxW
wUOvjd2X7MSrVKFfuZsy/7Q1XMLjsy7hNhKlYNXMELcAgGJtX2brkHVkrhJTcbty
LicZ+d2928NfEIik9CYemhhFdOJ3CYcoFxCmTbcQ2RD7pIyNUpM4Y7NFHznbjpow
pzfACltqh+FPoHZhj9ZBc3PRkr8DRxV4kKRKM+mkaFaa9pa9rim+UGigRoG3qAGP
fneHxKWvSE4DNjsuIpc5VyocGJw8BqDJkNJuLZW4sF1kyrHhPIrcdYy2nJt6Af43
tyA31jiQ1fK4Ri2cS093
=MFQ2
-----END PGP SIGNATURE-----

--Signature=_Thu__19_Apr_2012_16_28_59_+1000_+ND=i_BVMY_QzusZ--
