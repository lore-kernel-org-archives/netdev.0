From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/8] [PKTGEN]: Kill dead static inlines
Date: Sat, 12 Jan 2008 11:40:16 +0200
Message-ID: <1200130817467-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308172525-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53008 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761157AbYALJkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:20 -0500
In-Reply-To: <12001308172525-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/pktgen.c |   94 ---------------------------------------------=
--------
 1 files changed, 0 insertions(+), 94 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ede1fea..ebfb126 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -397,62 +397,6 @@ struct pktgen_thread {
 #define REMOVE 1
 #define FIND   0
=20
-/*  This code works around the fact that do_div cannot handle two 64-b=
it
-    numbers, and regular 64-bit division doesn't work on x86 kernels.
-    --Ben
-*/
-
-#define PG_DIV 0
-
-/* This was emailed to LMKL by: Chris Caputo <ccaputo@alt.net>
- * Function copied/adapted/optimized from:
- *
- *  nemesis.sourceforge.net/browse/lib/static/intmath/ix86/intmath.c.h=
tml
- *
- * Copyright 1994, University of Cambridge Computer Laboratory
- * All Rights Reserved.
- *
- */
-static inline s64 divremdi3(s64 x, s64 y, int type)
-{
-	u64 a =3D (x < 0) ? -x : x;
-	u64 b =3D (y < 0) ? -y : y;
-	u64 res =3D 0, d =3D 1;
-
-	if (b > 0) {
-		while (b < a) {
-			b <<=3D 1;
-			d <<=3D 1;
-		}
-	}
-
-	do {
-		if (a >=3D b) {
-			a -=3D b;
-			res +=3D d;
-		}
-		b >>=3D 1;
-		d >>=3D 1;
-	}
-	while (d);
-
-	if (PG_DIV =3D=3D type) {
-		return (((x ^ y) & (1ll << 63)) =3D=3D 0) ? res : -(s64) res;
-	} else {
-		return ((x & (1ll << 63)) =3D=3D 0) ? a : -(s64) a;
-	}
-}
-
-/* End of hacks to deal with 64-bit math on x86 */
-
-/** Convert to milliseconds */
-static inline __u64 tv_to_ms(const struct timeval *tv)
-{
-	__u64 ms =3D tv->tv_usec / 1000;
-	ms +=3D (__u64) tv->tv_sec * (__u64) 1000;
-	return ms;
-}
-
 /** Convert to micro-seconds */
 static inline __u64 tv_to_us(const struct timeval *tv)
 {
@@ -461,39 +405,6 @@ static inline __u64 tv_to_us(const struct timeval =
*tv)
 	return us;
 }
=20
-static inline __u64 pg_div(__u64 n, __u32 base)
-{
-	__u64 tmp =3D n;
-	do_div(tmp, base);
-	/* printk("pktgen: pg_div, n: %llu  base: %d  rv: %llu\n",
-	   n, base, tmp); */
-	return tmp;
-}
-
-static inline __u64 pg_div64(__u64 n, __u64 base)
-{
-	__u64 tmp =3D n;
-/*
- * How do we know if the architecture we are running on
- * supports division with 64 bit base?
- *
- */
-#if defined(__sparc_v9__) || defined(__powerpc64__) || defined(__alpha=
__) || defined(__x86_64__) || defined(__ia64__)
-
-	do_div(tmp, base);
-#else
-	tmp =3D divremdi3(n, base, PG_DIV);
-#endif
-	return tmp;
-}
-
-static inline __u64 getCurMs(void)
-{
-	struct timeval tv;
-	do_gettimeofday(&tv);
-	return tv_to_ms(&tv);
-}
-
 static inline __u64 getCurUs(void)
 {
 	struct timeval tv;
@@ -501,11 +412,6 @@ static inline __u64 getCurUs(void)
 	return tv_to_us(&tv);
 }
=20
-static inline __u64 tv_diff(const struct timeval *a, const struct time=
val *b)
-{
-	return tv_to_us(a) - tv_to_us(b);
-}
-
 /* old include end */
=20
 static char version[] __initdata =3D VERSION;
--=20
1.5.0.6

