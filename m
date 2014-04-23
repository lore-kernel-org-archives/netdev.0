From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH] smc91x: improve definition of debug macros
Date: Tue, 22 Apr 2014 20:04:42 -0700
Message-ID: <1398222282-8926-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Redefine some macros that were conditioned upon SMC_DEBUG level.

By allowing compiler to verify parameters used by these macros
unconditionally, we can flag compilation failures.

Compiler will still optimize out the unused code path depending on
SMC_DEBUG, so this is a net gain.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
Note: This patch is based on suggestion by Joe Perches.
I added his Signed-off-by as well since I didn't receive an objection.

 drivers/net/ethernet/smsc/smc91x.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 597909f..bcaa41a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -147,18 +147,19 @@ MODULE_ALIAS("platform:smc91x");
  */
 #define MII_DELAY		1
 
-#if SMC_DEBUG > 0
-#define DBG(n, dev, args...)				\
-	do {						\
-		if (SMC_DEBUG >= (n))			\
-			netdev_dbg(dev, args);		\
+#define DBG(n, dev, fmt, ...)					\
+	do {							\
+		if (SMC_DEBUG >= (n))				\
+			netdev_dbg(dev, fmt, ##__VA_ARGS__);	\
 	} while (0)
 
-#define PRINTK(dev, args...)   netdev_info(dev, args)
-#else
-#define DBG(n, dev, args...)   do { } while (0)
-#define PRINTK(dev, args...)   netdev_dbg(dev, args)
-#endif
+#define PRINTK(dev, fmt, ...)					\
+	do {							\
+		if (SMC_DEBUG > 0)				\
+			netdev_info(dev, fmt, ##__VA_ARGS__);	\
+		else						\
+			netdev_dbg(dev, fmt, ##__VA_ARGS__);	\
+	} while (0)
 
 #if SMC_DEBUG > 3
 static void PRINT_PKT(u_char *buf, int length)
@@ -191,7 +192,7 @@ static void PRINT_PKT(u_char *buf, int length)
 	pr_cont("\n");
 }
 #else
-#define PRINT_PKT(x...)  do { } while (0)
+static inline void PRINT_PKT(u_char *buf, int length) { }
 #endif
 
 
-- 
1.9.1
