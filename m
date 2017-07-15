From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] jhash: fix -Wimplicit-fallthrough warnings
Date: Fri, 14 Jul 2017 23:03:49 -0700
Message-ID: <20170715060349.2464-1-jakub.kicinski@netronome.com>
Cc: linux-kernel@vger.kernel.org, kadlec@blackhole.kfki.hu,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GCC 7 added a new -Wimplicit-fallthrough warning.  It's only enabled
with W=1, but since linux/jhash.h is included in over hundred places
(including other global headers) it seems worthwhile fixing this
warning.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
If it looks good, would it be OK to take it via the net tree?

 include/linux/jhash.h | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index 348c6f47e4cc..8037850f3104 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -85,19 +85,18 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
 		k += 12;
 	}
 	/* Last block: affect all 32 bits of (c) */
-	/* All the case statements fall through */
 	switch (length) {
-	case 12: c += (u32)k[11]<<24;
-	case 11: c += (u32)k[10]<<16;
-	case 10: c += (u32)k[9]<<8;
-	case 9:  c += k[8];
-	case 8:  b += (u32)k[7]<<24;
-	case 7:  b += (u32)k[6]<<16;
-	case 6:  b += (u32)k[5]<<8;
-	case 5:  b += k[4];
-	case 4:  a += (u32)k[3]<<24;
-	case 3:  a += (u32)k[2]<<16;
-	case 2:  a += (u32)k[1]<<8;
+	case 12: c += (u32)k[11]<<24;	/* fall through */
+	case 11: c += (u32)k[10]<<16;	/* fall through */
+	case 10: c += (u32)k[9]<<8;	/* fall through */
+	case 9:  c += k[8];		/* fall through */
+	case 8:  b += (u32)k[7]<<24;	/* fall through */
+	case 7:  b += (u32)k[6]<<16;	/* fall through */
+	case 6:  b += (u32)k[5]<<8;	/* fall through */
+	case 5:  b += k[4];		/* fall through */
+	case 4:  a += (u32)k[3]<<24;	/* fall through */
+	case 3:  a += (u32)k[2]<<16;	/* fall through */
+	case 2:  a += (u32)k[1]<<8;	/* fall through */
 	case 1:  a += k[0];
 		 __jhash_final(a, b, c);
 	case 0: /* Nothing left to add */
@@ -131,10 +130,10 @@ static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
 		k += 3;
 	}
 
-	/* Handle the last 3 u32's: all the case statements fall through */
+	/* Handle the last 3 u32's */
 	switch (length) {
-	case 3: c += k[2];
-	case 2: b += k[1];
+	case 3: c += k[2];	/* fall through */
+	case 2: b += k[1];	/* fall through */
 	case 1: a += k[0];
 		__jhash_final(a, b, c);
 	case 0:	/* Nothing left to add */
-- 
2.11.0
