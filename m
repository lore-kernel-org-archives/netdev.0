From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] wcn36xx: Fix logging macro with unnecessary semicolon
Date: Tue, 05 Nov 2013 12:40:00 -0800
Message-ID: <1383684000.4387.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The wcn36xx_err macro should not end in a semicolon as
there are 2 consecutive semicolons in the preprocessed
output.

Remove it.

Neaten the logging macros to use a more common style.
Convert to use pr_debug to enable dynamic debug.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 58b6383..d157bb7 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -53,22 +53,20 @@ enum wcn36xx_debug_mask {
 	WCN36XX_DBG_ANY		= 0xffffffff,
 };
 
-#define wcn36xx_err(fmt, arg...)				\
-	printk(KERN_ERR pr_fmt("ERROR " fmt), ##arg);
-
-#define wcn36xx_warn(fmt, arg...)				\
-	printk(KERN_WARNING pr_fmt("WARNING " fmt), ##arg)
-
-#define wcn36xx_info(fmt, arg...)		\
-	printk(KERN_INFO pr_fmt(fmt), ##arg)
-
-#define wcn36xx_dbg(mask, fmt, arg...) do {			\
-	if (wcn36xx_dbg_mask & mask)					\
-		printk(KERN_DEBUG pr_fmt(fmt), ##arg);	\
+#define wcn36xx_err(fmt, ...)					\
+	pr_err("ERROR " fmt, ##__VA_ARGS__)
+#define wcn36xx_warn(fmt, ...)					\
+	pr_warn("WARNING " fmt, ##__VA_ARGS__)
+#define wcn36xx_info(fmt, ...)					\
+	pr_info(fmt, ##__VA_ARGS__)
+#define wcn36xx_dbg(mask, fmt, ...)				\
+do {								\
+	if (wcn36xx_dbg_mask & mask)				\
+		pr_debug(fmt, ##__VA_ARGS__);			\
 } while (0)
