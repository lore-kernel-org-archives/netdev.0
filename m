From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 06/20] b43legacy: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:46 -0700
Message-ID: <2440160df6fe1e91d7bcb074290d0a18a9d84147.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43legacy/b43legacy.h |   14 ++++++--------
 drivers/net/wireless/b43legacy/debugfs.c   |    4 +++-
 drivers/net/wireless/b43legacy/dma.c       |    2 ++
 drivers/net/wireless/b43legacy/main.c      |   16 +++++++++-------
 drivers/net/wireless/b43legacy/phy.c       |    2 ++
 drivers/net/wireless/b43legacy/radio.c     |    5 +++--
 drivers/net/wireless/b43legacy/xmit.c      |    2 ++
 7 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/b43legacy/b43legacy.h
index a29da67..e77083e 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -325,20 +325,18 @@ enum {
 #define B43legacy_SBIMSTATE_IB_ERROR		0x20000
 #define B43legacy_SBIMSTATE_TIMEOUT		0x40000
 
-#define PFX		KBUILD_MODNAME ": "
 #ifdef assert
 # undef assert
 #endif
 #ifdef CONFIG_B43LEGACY_DEBUG
 # define B43legacy_WARN_ON(x)	WARN_ON(x)
 # define B43legacy_BUG_ON(expr)						\
-	do {								\
-		if (unlikely((expr))) {					\
-			printk(KERN_INFO PFX "Test (%s) failed\n",	\
-					      #expr);			\
-			BUG_ON(expr);					\
-		}							\
-	} while (0)
+do {									\
+	if (unlikely((expr))) {						\
+		pr_info("Test (%s) failed\n", #expr);			\
+		BUG_ON(expr);						\
+	}								\
+} while (0)
 # define B43legacy_DEBUG	1
 #else
 /* This will evaluate the argument even if debugging is disabled. */
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index 1965edb..7678005 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -23,6 +23,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/slab.h>
@@ -71,7 +73,7 @@ struct b43legacy_dfs_file * fops_to_dfs_file(struct b43legacy_wldev *dev,
 					  bufsize - count,	\
 					  fmt , ##x);		\
 		else						\
-			printk(KERN_ERR "b43legacy: fappend overflow\n"); \
+			pr_err("fappend overflow\n");		\
 	} while (0)
 
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index f1f8bd0..6b42488 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -27,6 +27,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "b43legacy.h"
 #include "dma.h"
 #include "main.h"
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 8b06ca5..b0536a5 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -29,6 +29,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -190,8 +192,8 @@ void b43legacyinfo(struct b43legacy_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_INFO "b43legacy-%s: %pV",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+	pr_info("%s: %pV",
+		(wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
 }
@@ -209,7 +211,7 @@ void b43legacyerr(struct b43legacy_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_ERR "b43legacy-%s ERROR: %pV",
+	pr_err("%s ERROR: %pV",
 	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
@@ -228,8 +230,8 @@ void b43legacywarn(struct b43legacy_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_WARNING "b43legacy-%s warning: %pV",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+	pr_warn("%s warning: %pV",
+		(wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
 }
@@ -245,7 +247,7 @@ void b43legacydbg(struct b43legacy_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_DEBUG "b43legacy-%s debug: %pV",
+	printk(KERN_DEBUG pr_fmt("%s debug: %pV"),
 	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
@@ -4001,7 +4003,7 @@ static void b43legacy_print_driverinfo(void)
 #ifdef CONFIG_B43LEGACY_DMA
 	feat_dma = "D";
 #endif
-	printk(KERN_INFO "Broadcom 43xx-legacy driver loaded "
+	pr_info("Broadcom 43xx-legacy driver loaded "
 	       "[ Features: %s%s%s%s ]\n",
 	       feat_pci, feat_leds, feat_pio, feat_dma);
 }
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/b43legacy/phy.c
index 995c7d0..e03851d 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -29,6 +29,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/pci.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wireless/b43legacy/radio.c
index 8961776..ff3f996 100644
--- a/drivers/net/wireless/b43legacy/radio.c
+++ b/drivers/net/wireless/b43legacy/radio.c
@@ -29,6 +29,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 
 #include "b43legacy.h"
@@ -78,8 +80,7 @@ u16 channel2freq_bg(u8 channel)
 	};
 
 	if (unlikely(channel < 1 || channel > 14)) {
-		printk(KERN_INFO "b43legacy: Channel %d is out of range\n",
-				  channel);
+		pr_info("Channel %d is out of range\n", channel);
 		dump_stack();
 		return 2412;
 	}
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index a8012f2..385eb72 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -28,6 +28,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/dst.h>
 
 #include "xmit.h"
-- 
1.7.8.111.gad25c.dirty
