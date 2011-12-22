From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Thu, 22 Dec 2011 17:07:26 +1100
Message-ID: <20111222170726.b16565ef7d1434cc4ec170d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__22_Dec_2011_17_07_26_+1100_zPnZRsnIu7nYL/Zw"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus <torvalds@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__22_Dec_2011_17_07_26_+1100_zPnZRsnIu7nYL/Zw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (sparc32 defconfig)
failed like this:

net/ipv4/route.c: In function 'rt_check_expire':
net/ipv4/route.c:873:4: error: implicit declaration of function 'prefetch' =
[-Werror=3Dimplicit-function-declaration]

Caused by commit 9f28a2fc0bd7 ("ipv4: reintroduce route cache garbage
collector").

Linus, that commit is in the latest pull request you have from Dave ...

I applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 22 Dec 2011 17:03:29 +1100
Subject: [PATCH] ipv4: using prefetch requires including prefetch.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/ipv4/route.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7460483..9c01f56 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -91,6 +91,7 @@
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <linux/slab.h>
+#include <linux/prefetch.h>
 #include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
--=20
1.7.8.197.g73c6b

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__22_Dec_2011_17_07_26_+1100_zPnZRsnIu7nYL/Zw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO8skeAAoJEECxmPOUX5FEpJ8P/3COL4qJAgYd0aYdIKIrngj1
+r2N4UZypMKg1hYcR4RCETeb/qyotgppdTwX93GNF+nXQ2if/2ql0B2cUWkB4a6F
s1IvsLRQLBcEtqkPtElJZuUa3geEfGVF7x2GxQ+7TpSKF/1mgVs9dUMZa18yOsxL
31IcVV9Rb15trJuWVQM3Rk+1SC/zlPdyMjLAnI2mnEIy2I1HGCKwi4WQTJQjE26N
2AStPiDoEzin6tMfbKp17TVBVLYAZs0SkIwvzxh2J3Vlp3MNIR+rybOZTRQJsvtZ
p0IUKPk4Kh4xiXtLJZ562fAOkli7YRYYf4uVq26CZuHKvpejUnfy9jHJuqoVEpwn
AsrM9G8NAFFgTBWLKDj/ha2Gr1IAuUy5R2NLahi8YPWe9aZAWOcn31097V62T8XL
tStFOSrFupUWVE7bfD0ZKdrvuZpUKpyfUhQpWapt56JLucCchcVSQawTjSluIS21
8f+14EyI4TOR3Z5OfT1+EaIRHxCyYFhUEojSHPsYcmFl0GXkSzn823EVc5yh4fpb
UjNqUzJwqrJQYxQiJWWf/W9CW37xoZyOy9IIof+xOcC5E3wftjE+gTZdMBqXLYhe
NhBzDpP7qzQrYMZZKAGHYCv/hAL4je1quDv5RseHW1cq6Sry5QB96e6So9OPIv3P
fVc9q7kRE5i0IbcuQ9Qg
=A/m7
-----END PGP SIGNATURE-----

--Signature=_Thu__22_Dec_2011_17_07_26_+1100_zPnZRsnIu7nYL/Zw--
