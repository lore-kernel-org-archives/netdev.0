From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 5 Mar 2015 13:42:47 +1100
Message-ID: <20150305134247.5a55e4db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/hmfJc680P+W=FCwCO._W9.J"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/hmfJc680P+W=FCwCO._W9.J
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/mpls/af_mpls.c: In function 'resize_platform_label_table':
net/mpls/af_mpls.c:767:4: error: implicit declaration of function 'vzalloc'=
 [-Werror=3Dimplicit-function-declaration]
    labels =3D vzalloc(size);
    ^

Caused by commit 7720c01f3f59 ("mpls: Add a sysctl to control the size
of the mpls label table").

I have added this commit for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 5 Mar 2015 13:37:05 +1100
Subject: [PATCH] mpls: using vzalloc requires including vmalloc.h

Fixes this build error:

net/mpls/af_mpls.c: In function 'resize_platform_label_table':
net/mpls/af_mpls.c:767:4: error: implicit declaration of function 'vzalloc'=
 [-Werror=3Dimplicit-function-declaration]
    labels =3D vzalloc(size);
    ^

Fixes: 7720c01f3f59 ("mpls: Add a sysctl to control the size of the mpls la=
bel table")
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/mpls/af_mpls.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 23e51d13b0ff..20cf48a8593d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -7,6 +7,7 @@
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/mpls.h>
+#include <linux/vmalloc.h>
 #include <net/ip.h>
 #include <net/dst.h>
 #include <net/sock.h>
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/hmfJc680P+W=FCwCO._W9.J
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU98KrAAoJEMDTa8Ir7ZwVRHUQAIVfev8pyheQhKyEENlJCh58
MmJmNTPYyreggvj3nd0NsRFy0vnqm/BQZholsbjwHpLI0TBi6d0mFTxmJLVkiKDZ
LPCqb0Vl4gEjxS4ZuQoQoi94tcjRSVekQAvKjMkD2fr6ODnPAb/ZqTwk98fKU2Ci
kubunh4FPpWNtV5tNgS4vTpSXYCahmLLNmk+G4uJYUZRMj1fJ7mRUnYoLb/O1Yei
meLvCp0kW/z0y8zZCCo5sp/wrUFc43am9+FeMMmnrg2XBFrkCZCRuiYHpzWKjt5c
Xr0K1G4KGPEEskFDLKpUozw2MYlEw1dUDXeUOKFGi55oEm43C4LppvXhjMYASZce
GgWSXEGXzSNcK2hOJu8SkScSBT9MQtp3I9EkUihYr1Qin2r7L6sdHexqQO9bMMgB
22DGHh4wf0oPTdeU2kIlCCCnD1NYrJV/mXFAUFZci9qBxNVs9HsSvy3PNpdpi4lW
yQKjCmx8aPH65yXG62CklueLnS8UiNQh7SLFADX8WOpCnlpm2GWxEkjeAzfkdjZ6
OnVkK8+NfUjEfDhbSukDfGVIiR+sw6b7NiyHXz83dkcdYx4Cjmj2YSuHPgVEWmHE
Rftgy5IxW0cQG/PpEf0dLKDqiW5AIyZX1Onzyq3ORR9VQK0lwGfyq3WPjSo4S6S8
y4iE4FDndUesvq7d1GDv
=/Fyg
-----END PGP SIGNATURE-----

--Sig_/hmfJc680P+W=FCwCO._W9.J--
