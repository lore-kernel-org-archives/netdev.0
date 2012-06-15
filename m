From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 05/20] b43: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:45 -0700
Message-ID: <8cf055c50431d00cebcd134a6560a59e093057cc.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43/debugfs.c |   20 +++++++++--------
 drivers/net/wireless/b43/main.c    |   41 ++++++++++++++++-------------------
 drivers/net/wireless/b43/pcmcia.c  |    5 ++-
 3 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index e807bd9..1feebd9 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -23,6 +23,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/slab.h>
@@ -61,15 +63,15 @@ struct b43_dfs_file *fops_to_dfs_file(struct b43_wldev *dev,
 }
 
 
-#define fappend(fmt, x...)	\
-	do {							\
-		if (bufsize - count)				\
-			count += snprintf(buf + count,		\
-					  bufsize - count,	\
-					  fmt , ##x);		\
-		else						\
-			printk(KERN_ERR "b43: fappend overflow\n"); \
-	} while (0)
+#define fappend(fmt, x...)					\
+do {								\
+	if (bufsize - count)					\
+		count += snprintf(buf + count,			\
+				  bufsize - count,		\
+				  fmt , ##x);			\
+	else							\
+		pr_err("fappend overflow\n");			\
+} while (0)
 
 
 /* The biggest address values for SHM access from the debugfs files. */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index acd03a4..2bcedce 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -32,6 +32,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -354,8 +356,8 @@ void b43info(struct b43_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_INFO "b43-%s: %pV",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+	pr_info("%s: %pV",
+		(wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
 }
@@ -375,7 +377,7 @@ void b43err(struct b43_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_ERR "b43-%s ERROR: %pV",
+	pr_err("%s ERROR: %pV",
 	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
@@ -396,8 +398,8 @@ void b43warn(struct b43_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_WARNING "b43-%s warning: %pV",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+	pr_warn("%s warning: %pV",
+		(wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
 }
@@ -415,7 +417,7 @@ void b43dbg(struct b43_wl *wl, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk(KERN_DEBUG "b43-%s debug: %pV",
+	printk(KERN_DEBUG pr_fmt("%s debug: %pV"),
 	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
 
 	va_end(args);
@@ -1069,7 +1071,7 @@ static void b43_dump_keymemory(struct b43_wldev *dev)
 	}
 	for (index = 0; index < count; index++) {
 		key = &(dev->key[index]);
-		printk(KERN_DEBUG "Key slot %02u: %s",
+		printk(KERN_DEBUG pr_fmt("Key slot %02u: %s"),
 		       index, (key->keyconf == NULL) ? " " : "*");
 		offset = dev->ktp + (index * B43_SEC_KEYSIZE);
 		for (i = 0; i < B43_SEC_KEYSIZE; i += 2) {
@@ -1794,7 +1796,7 @@ static void b43_handle_firmware_panic(struct b43_wldev *dev)
 
 static void handle_irq_ucode_debug(struct b43_wldev *dev)
 {
-	unsigned int i, cnt;
+	unsigned int i;
 	u16 reason, marker_id, marker_line;
 	__le16 *buf;
 
@@ -1830,18 +1832,15 @@ static void handle_irq_ucode_debug(struct b43_wldev *dev)
 		if (!B43_DEBUG)
 			break; /* Only with driver debugging enabled. */
 		b43info(dev->wl, "Microcode register dump:\n");
-		for (i = 0, cnt = 0; i < 64; i++) {
+		for (i = 0; i < 64; i++) {
 			u16 tmp = b43_shm_read16(dev, B43_SHM_SCRATCH, i);
-			if (cnt == 0)
-				printk(KERN_INFO);
-			printk("r%02u: 0x%04X  ", i, tmp);
-			cnt++;
-			if (cnt == 6) {
-				printk("\n");
-				cnt = 0;
-			}
+			if (!(i % 6))
+				pr_info("");
+			
+			pr_cont("r%02u: 0x%04X%s",
+				i, tmp, (i % 6) != 5 ? "  " : "\n");
 		}
-		printk("\n");
+		pr_cont("\n");
 		break;
 	case B43_DEBUGIRQ_MARKER:
 		if (!B43_DEBUG)
@@ -5509,10 +5508,8 @@ static void b43_print_driverinfo(void)
 #ifdef CONFIG_B43_SDIO
 	feat_sdio = "S";
 #endif
-	printk(KERN_INFO "Broadcom 43xx driver loaded "
-	       "[ Features: %s%s%s%s%s ]\n",
-	       feat_pci, feat_pcmcia, feat_nphy,
-	       feat_leds, feat_sdio);
+	pr_info("Broadcom 43xx driver loaded [ Features: %s%s%s%s%s ]\n",
+		feat_pci, feat_pcmcia, feat_nphy, feat_leds, feat_sdio);
 }
 
 static int __init b43_init(void)
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 714cad6..0c0751a 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -21,6 +21,8 @@
 
 */
 
+#define pr_fmt(fmt) "b43-pcmcia: " fmt
+
 #include "pcmcia.h"
 
 #include <linux/ssb/ssb.h>
@@ -105,8 +107,7 @@ err_disable:
 err_kfree_ssb:
 	kfree(ssb);
 out_error:
-	printk(KERN_ERR "b43-pcmcia: Initialization failed (%d, %d)\n",
-	       res, err);
+	pr_err("Initialization failed (%d, %d)\n", res, err);
 	return err;
 }
 
-- 
1.7.8.111.gad25c.dirty
