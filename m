From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 08/33] arcnet: Neaten BUGMSG macro defines
Date: Tue, 22 Sep 2015 11:01:49 +0200
Message-ID: <1442912534-10821-9-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46327 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

These macros are actually printk and pr_cont uses with a flag.

Add a new BUGLVL_TEST macro which is just the "should use" test
and not an odd "if (<foo>)" macro to simplify uses in a new patch.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 include/linux/arcdevice.h | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index 7868788..ad61020 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -78,14 +78,24 @@
 #endif
 extern int arcnet_debug;
 
+#define BUGLVL_TEST(x)	((x) & ARCNET_DEBUG_MAX & arcnet_debug)
+#define BUGLVL(x)	if (BUGLVL_TEST(x))
+
 /* macros to simplify debug checking */
-#define BUGLVL(x) if ((ARCNET_DEBUG_MAX) & arcnet_debug & (x))
-#define BUGMSG2(x, msg, args...) do { BUGLVL(x) printk(msg, ## args); } while (0)
-#define BUGMSG(x, msg, args...)						\
-	BUGMSG2(x, "%s%6s: " msg,					\
-		x == D_NORMAL	? KERN_WARNING				\
-		: x < D_DURING ? KERN_INFO : KERN_DEBUG,		\
-		dev->name, ## args)
+#define BUGMSG(x, fmt, ...)						\
+do {									\
+	if (BUGLVL_TEST(x))						\
+		printk("%s%6s: " fmt,					\
+		       (x) == D_NORMAL	? KERN_WARNING :		\
+		       (x) < D_DURING ? KERN_INFO : KERN_DEBUG,		\
+		       dev->name, ##__VA_ARGS__);			\
+} while (0)
+
+#define BUGMSG2(x, fmt, ...)						\
+do {									\
+	if (BUGLVL_TEST(x))						\
+		printk(fmt, ##__VA_ARGS__);				\
+} while (0)
 
 /* see how long a function call takes to run, expressed in CPU cycles */
 #define TIME(name, bytes, call) BUGLVL(D_TIMING) {			\
-- 
2.5.1
