From: Joe Perches <joe@perches.com>
Subject: [PATCH] Use random32() in net/ipv4/multipath
Date: Thu, 15 Feb 2007 15:46:44 -0800
Message-ID: <1171583205.29021.44.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1613 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932861AbXBOXqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 18:46:38 -0500
Received: from [192.168.1.128] ([192.168.1.128])
	by Perches.com (8.9.3/8.9.3) with ESMTP id PAA20238
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 15:05:50 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Einar Lueck's email addresses bounce
<elueck@de.ibm.com><lkml@einar-lueck.de>

Removed local random number generator function

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/ipv4/multipath_random.c b/net/ipv4/multipath_random.c
index b8c289f..6448e6c 100644
--- a/net/ipv4/multipath_random.c
+++ b/net/ipv4/multipath_random.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/mroute.h>
 #include <linux/init.h>
+#include <linux/random.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -49,21 +50,6 @@
 
 #define MULTIPATH_MAX_CANDIDATES 40
 
-/* interface to random number generation */
-static unsigned int RANDOM_SEED = 93186752;
-
-static inline unsigned int random(unsigned int ubound)
-{
-	static unsigned int a = 1588635695,
-		q = 2,
-		r = 1117695901;
-
-	RANDOM_SEED = a*(RANDOM_SEED % q) - r*(RANDOM_SEED / q);
-
-	return RANDOM_SEED % ubound;
-}
-
-
 static void random_select_route(const struct flowi *flp,
 				struct rtable *first,
 				struct rtable **rp)
@@ -85,7 +71,7 @@ static void random_select_route(const struct flowi *flp,
 	if (candidate_count > 1) {
 		unsigned char i = 0;
 		unsigned char candidate_no = (unsigned char)
-			random(candidate_count);
+			(random32() % candidate_count);
 
 		/* find chosen candidate and adjust GC data for all candidates
 		 * to ensure they stay in cache
diff --git a/net/ipv4/multipath_wrandom.c b/net/ipv4/multipath_wrandom.c
index 92b0482..d6115a3 100644
--- a/net/ipv4/multipath_wrandom.c
+++ b/net/ipv4/multipath_wrandom.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/mroute.h>
 #include <linux/init.h>
+#include <linux/random.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <linux/skbuff.h>
@@ -85,18 +86,6 @@ struct multipath_route {
 /* state: primarily weight per route information */
 static struct multipath_bucket state[MULTIPATH_STATE_SIZE];
 
-/* interface to random number generation */
-static unsigned int RANDOM_SEED = 93186752;
-
-static inline unsigned int random(unsigned int ubound)
-{
-	static unsigned int a = 1588635695,
-		q = 2,
-		r = 1117695901;
-	RANDOM_SEED = a*(RANDOM_SEED % q) - r*(RANDOM_SEED / q);
-	return RANDOM_SEED % ubound;
-}
-
 static unsigned char __multipath_lookup_weight(const struct flowi *fl,
 					       const struct rtable *rt)
 {
@@ -194,7 +183,7 @@ static void wrandom_select_route(const struct flowi *flp,
 
 	/* choose a weighted random candidate */
 	decision = first;
-	selector = random(power);
+	selector = random32() % power;
 	last_power = 0;
 
 	/* select candidate, adjust GC data and cleanup local state */


