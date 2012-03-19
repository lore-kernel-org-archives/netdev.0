From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 1/3] ath: Add and use pr_fmt, convert printks to pr_<level>
Date: Sun, 18 Mar 2012 17:30:52 -0700
Message-ID: <f34c85d2f618a948d55984458c5eba2c17edc639.1332116921.git.joe@perches.com>
References: <cover.1332116921.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Bob Copeland <me@bobcopeland.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1332116921.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.
Make sure all output is prefixed appropriately.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath5k/ani.c          |   44 +++++++++++--------------
 drivers/net/wireless/ath/ath5k/ath5k.h        |   32 +++++++++--------
 drivers/net/wireless/ath/ath5k/attach.c       |    2 +
 drivers/net/wireless/ath/ath5k/base.c         |    2 +
 drivers/net/wireless/ath/ath5k/debug.c        |   17 ++++++----
 drivers/net/wireless/ath/ath5k/desc.c         |    2 +
 drivers/net/wireless/ath/ath5k/dma.c          |    2 +
 drivers/net/wireless/ath/ath5k/eeprom.c       |    2 +
 drivers/net/wireless/ath/ath5k/initvals.c     |    5 ++-
 drivers/net/wireless/ath/ath5k/led.c          |    2 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c |    2 +
 drivers/net/wireless/ath/ath5k/pci.c          |    4 ++-
 drivers/net/wireless/ath/ath5k/phy.c          |    2 +
 drivers/net/wireless/ath/ath5k/qcu.c          |    2 +
 drivers/net/wireless/ath/ath5k/reset.c        |    2 +
 drivers/net/wireless/ath/ath5k/sysfs.c        |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c    |    2 +
 drivers/net/wireless/ath/ath6kl/init.c        |    2 +
 drivers/net/wireless/ath/ath6kl/main.c        |    2 +
 drivers/net/wireless/ath/ath6kl/txrx.c        |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    8 ++--
 drivers/net/wireless/ath/ath9k/htc_hst.c      |    7 ++--
 drivers/net/wireless/ath/ath9k/init.c         |   13 +++----
 drivers/net/wireless/ath/ath9k/pci.c          |    9 +++--
 drivers/net/wireless/ath/main.c               |    4 ++-
 drivers/net/wireless/ath/regd.c               |    4 ++-
 26 files changed, 107 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/ani.c b/drivers/net/wireless/ath/ath5k/ani.c
index bf67416..6841f5c 100644
--- a/drivers/net/wireless/ath/ath5k/ani.c
+++ b/drivers/net/wireless/ath/ath5k/ani.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ath5k.h"
 #include "reg.h"
 #include "debug.h"
@@ -728,33 +730,25 @@ void
 ath5k_ani_print_counters(struct ath5k_hw *ah)
 {
 	/* clears too */
-	printk(KERN_NOTICE "ACK fail\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_ACK_FAIL));
-	printk(KERN_NOTICE "RTS fail\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_RTS_FAIL));
-	printk(KERN_NOTICE "RTS success\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_RTS_OK));
-	printk(KERN_NOTICE "FCS error\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_FCS_FAIL));
+	pr_notice("ACK fail\t%d\n", ath5k_hw_reg_read(ah, AR5K_ACK_FAIL));
+	pr_notice("RTS fail\t%d\n", ath5k_hw_reg_read(ah, AR5K_RTS_FAIL));
+	pr_notice("RTS success\t%d\n", ath5k_hw_reg_read(ah, AR5K_RTS_OK));
+	pr_notice("FCS error\t%d\n", ath5k_hw_reg_read(ah, AR5K_FCS_FAIL));
 
 	/* no clear */
-	printk(KERN_NOTICE "tx\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PROFCNT_TX));
-	printk(KERN_NOTICE "rx\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PROFCNT_RX));
-	printk(KERN_NOTICE "busy\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PROFCNT_RXCLR));
-	printk(KERN_NOTICE "cycles\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PROFCNT_CYCLE));
-
-	printk(KERN_NOTICE "AR5K_PHYERR_CNT1\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PHYERR_CNT1));
-	printk(KERN_NOTICE "AR5K_PHYERR_CNT2\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_PHYERR_CNT2));
-	printk(KERN_NOTICE "AR5K_OFDM_FIL_CNT\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_OFDM_FIL_CNT));
-	printk(KERN_NOTICE "AR5K_CCK_FIL_CNT\t%d\n",
-		ath5k_hw_reg_read(ah, AR5K_CCK_FIL_CNT));
+	pr_notice("tx\t%d\n", ath5k_hw_reg_read(ah, AR5K_PROFCNT_TX));
+	pr_notice("rx\t%d\n", ath5k_hw_reg_read(ah, AR5K_PROFCNT_RX));
+	pr_notice("busy\t%d\n", ath5k_hw_reg_read(ah, AR5K_PROFCNT_RXCLR));
+	pr_notice("cycles\t%d\n", ath5k_hw_reg_read(ah, AR5K_PROFCNT_CYCLE));
+
+	pr_notice("AR5K_PHYERR_CNT1\t%d\n",
+		  ath5k_hw_reg_read(ah, AR5K_PHYERR_CNT1));
+	pr_notice("AR5K_PHYERR_CNT2\t%d\n",
+		  ath5k_hw_reg_read(ah, AR5K_PHYERR_CNT2));
+	pr_notice("AR5K_OFDM_FIL_CNT\t%d\n",
+		  ath5k_hw_reg_read(ah, AR5K_OFDM_FIL_CNT));
+	pr_notice("AR5K_CCK_FIL_CNT\t%d\n",
+		  ath5k_hw_reg_read(ah, AR5K_CCK_FIL_CNT));
 }
 
 #endif
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 8d434b8..954c373 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -76,26 +76,28 @@
   GENERIC DRIVER DEFINITIONS
 \****************************/
 
-#define ATH5K_PRINTF(fmt, ...) \
-	printk(KERN_WARNING "%s: " fmt, __func__, ##__VA_ARGS__)
-
-#define ATH5K_PRINTK(_sc, _level, _fmt, ...) \
-	printk(_level "ath5k %s: " _fmt, \
-		((_sc) && (_sc)->hw) ? wiphy_name((_sc)->hw->wiphy) : "", \
-		##__VA_ARGS__)
-
-#define ATH5K_PRINTK_LIMIT(_sc, _level, _fmt, ...) do { \
-	if (net_ratelimit()) \
-		ATH5K_PRINTK(_sc, _level, _fmt, ##__VA_ARGS__); \
-	} while (0)
+#define ATH5K_PRINTF(fmt, ...)						\
+	pr_warn("%s: " fmt, __func__, ##__VA_ARGS__)
+
+#define ATH5K_PRINTK(_sc, _level, _fmt, ...)				\
+	printk(_level pr_fmt("%s%s" _fmt),				\
+	       ((_sc) && (_sc)->hw) ? wiphy_name((_sc)->hw->wiphy) : "", \
+	       ((_sc) && (_sc)->hw) ? ": " : "",			\
+	       ##__VA_ARGS__)
+
+#define ATH5K_PRINTK_LIMIT(_sc, _level, _fmt, ...)			\
+do {									\
+	if (net_ratelimit())						\
+		ATH5K_PRINTK(_sc, _level, _fmt, ##__VA_ARGS__); 	\
+} while (0)
 
-#define ATH5K_INFO(_sc, _fmt, ...) \
+#define ATH5K_INFO(_sc, _fmt, ...)					\
 	ATH5K_PRINTK(_sc, KERN_INFO, _fmt, ##__VA_ARGS__)
 
-#define ATH5K_WARN(_sc, _fmt, ...) \
+#define ATH5K_WARN(_sc, _fmt, ...)					\
 	ATH5K_PRINTK_LIMIT(_sc, KERN_WARNING, _fmt, ##__VA_ARGS__)
 
-#define ATH5K_ERR(_sc, _fmt, ...) \
+#define ATH5K_ERR(_sc, _fmt, ...)					\
 	ATH5K_PRINTK_LIMIT(_sc, KERN_ERR, _fmt, ##__VA_ARGS__)
 
 /*
diff --git a/drivers/net/wireless/ath/ath5k/attach.c b/drivers/net/wireless/ath/ath5k/attach.c
index d7114c7..7106547 100644
--- a/drivers/net/wireless/ath/ath5k/attach.c
+++ b/drivers/net/wireless/ath/ath5k/attach.c
@@ -20,6 +20,8 @@
 * Attach/Detach Functions and helpers *
 \*************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/pci.h>
 #include <linux/slab.h>
 #include "ath5k.h"
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 0e643b0..a9c0503 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -40,6 +40,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/wireless/ath/ath5k/debug.c b/drivers/net/wireless/ath/ath5k/debug.c
index 8c5ce8b..9be8857 100644
--- a/drivers/net/wireless/ath/ath5k/debug.c
+++ b/drivers/net/wireless/ath/ath5k/debug.c
@@ -57,6 +57,9 @@
  * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
  * THE POSSIBILITY OF SUCH DAMAGES.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/export.h>
 #include <linux/moduleparam.h>
 
@@ -254,10 +257,10 @@ static ssize_t write_file_beacon(struct file *file,
 
 	if (strncmp(buf, "disable", 7) == 0) {
 		AR5K_REG_DISABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE);
-		printk(KERN_INFO "debugfs disable beacons\n");
+		pr_info("debugfs disable beacons\n");
 	} else if (strncmp(buf, "enable", 6) == 0) {
 		AR5K_REG_ENABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE);
-		printk(KERN_INFO "debugfs enable beacons\n");
+		pr_info("debugfs enable beacons\n");
 	}
 	return count;
 }
@@ -457,19 +460,19 @@ static ssize_t write_file_antenna(struct file *file,
 
 	if (strncmp(buf, "diversity", 9) == 0) {
 		ath5k_hw_set_antenna_mode(ah, AR5K_ANTMODE_DEFAULT);
-		printk(KERN_INFO "ath5k debug: enable diversity\n");
+		pr_info("debug: enable diversity\n");
 	} else if (strncmp(buf, "fixed-a", 7) == 0) {
 		ath5k_hw_set_antenna_mode(ah, AR5K_ANTMODE_FIXED_A);
-		printk(KERN_INFO "ath5k debugfs: fixed antenna A\n");
+		pr_info("debug: fixed antenna A\n");
 	} else if (strncmp(buf, "fixed-b", 7) == 0) {
 		ath5k_hw_set_antenna_mode(ah, AR5K_ANTMODE_FIXED_B);
-		printk(KERN_INFO "ath5k debug: fixed antenna B\n");
+		pr_info("debug: fixed antenna B\n");
 	} else if (strncmp(buf, "clear", 5) == 0) {
 		for (i = 0; i < ARRAY_SIZE(ah->stats.antenna_rx); i++) {
 			ah->stats.antenna_rx[i] = 0;
 			ah->stats.antenna_tx[i] = 0;
 		}
-		printk(KERN_INFO "ath5k debug: cleared antenna stats\n");
+		pr_info("debug: cleared antenna stats\n");
 	}
 	return count;
 }
@@ -639,7 +642,7 @@ static ssize_t write_file_frameerrors(struct file *file,
 		st->txerr_fifo = 0;
 		st->txerr_filt = 0;
 		st->tx_all_count = 0;
-		printk(KERN_INFO "ath5k debug: cleared frameerrors stats\n");
+		pr_info("debug: cleared frameerrors stats\n");
 	}
 	return count;
 }
diff --git a/drivers/net/wireless/ath/ath5k/desc.c b/drivers/net/wireless/ath/ath5k/desc.c
index f8bfa3a..77a6077 100644
--- a/drivers/net/wireless/ath/ath5k/desc.c
+++ b/drivers/net/wireless/ath/ath5k/desc.c
@@ -21,6 +21,8 @@
  Hardware Descriptor Functions
 \******************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ath5k.h"
 #include "reg.h"
 #include "debug.h"
diff --git a/drivers/net/wireless/ath/ath5k/dma.c b/drivers/net/wireless/ath/ath5k/dma.c
index 5cc9aa8..ce86f15 100644
--- a/drivers/net/wireless/ath/ath5k/dma.c
+++ b/drivers/net/wireless/ath/ath5k/dma.c
@@ -29,6 +29,8 @@
  * status registers (ISR).
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ath5k.h"
 #include "reg.h"
 #include "debug.h"
diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index cd708c1..4026c90 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -21,6 +21,8 @@
 * EEPROM access functions and helpers *
 \*************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 
 #include "ath5k.h"
diff --git a/drivers/net/wireless/ath/ath5k/initvals.c b/drivers/net/wireless/ath/ath5k/initvals.c
index a1ea78e..ee1c2fa 100644
--- a/drivers/net/wireless/ath/ath5k/initvals.c
+++ b/drivers/net/wireless/ath/ath5k/initvals.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ath5k.h"
 #include "reg.h"
 #include "debug.h"
@@ -1574,8 +1576,7 @@ ath5k_hw_write_initvals(struct ath5k_hw *ah, u8 mode, bool skip_pcu)
 
 		/* AR5K_MODE_11B */
 		if (mode > 2) {
-			ATH5K_ERR(ah,
-				"unsupported channel mode: %d\n", mode);
+			ATH5K_ERR(ah, "unsupported channel mode: %d\n", mode);
 			return -EINVAL;
 		}
 
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index c1151c7..b9f708a 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -39,6 +39,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/pci.h>
 #include "ath5k.h"
 
diff --git a/drivers/net/wireless/ath/ath5k/mac80211-ops.c b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
index 5c53299..22b80af 100644
--- a/drivers/net/wireless/ath/ath5k/mac80211-ops.c
+++ b/drivers/net/wireless/ath/ath5k/mac80211-ops.c
@@ -41,6 +41,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/mac80211.h>
 #include <asm/unaligned.h>
 
diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
index 849fa06..53424e8 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/nl80211.h>
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
@@ -347,7 +349,7 @@ init_ath5k_pci(void)
 
 	ret = pci_register_driver(&ath5k_pci_driver);
 	if (ret) {
-		printk(KERN_ERR "ath5k_pci: can't register pci driver\n");
+		pr_err("pci: can't register pci driver\n");
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 3a28454..8b71a2d 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -22,6 +22,8 @@
 * PHY related functions *
 \***********************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <asm/unaligned.h>
diff --git a/drivers/net/wireless/ath/ath5k/qcu.c b/drivers/net/wireless/ath/ath5k/qcu.c
index 30b50f9..a6de200 100644
--- a/drivers/net/wireless/ath/ath5k/qcu.c
+++ b/drivers/net/wireless/ath/ath5k/qcu.c
@@ -20,6 +20,8 @@
 Queue Control Unit, DCF Control Unit Functions
 \********************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ath5k.h"
 #include "reg.h"
 #include "debug.h"
diff --git a/drivers/net/wireless/ath/ath5k/reset.c b/drivers/net/wireless/ath/ath5k/reset.c
index 200f165..0c2dd47 100644
--- a/drivers/net/wireless/ath/ath5k/reset.c
+++ b/drivers/net/wireless/ath/ath5k/reset.c
@@ -23,6 +23,8 @@
   Reset function and helpers
 \****************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <asm/unaligned.h>
 
 #include <linux/pci.h>		/* To determine if a card is pci-e */
diff --git a/drivers/net/wireless/ath/ath5k/sysfs.c b/drivers/net/wireless/ath/ath5k/sysfs.c
index 9364da7..04cf0ca 100644
--- a/drivers/net/wireless/ath/ath5k/sysfs.c
+++ b/drivers/net/wireless/ath/ath5k/sysfs.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/device.h>
 #include <linux/pci.h>
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 00d3895..bdcc68f 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -15,6 +15,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/moduleparam.h>
 #include <linux/inetdevice.h>
 #include <linux/export.h>
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 03cae14..eb7cc2f 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -16,6 +16,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/moduleparam.h>
 #include <linux/errno.h>
 #include <linux/export.h>
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index 229e192..07071fc 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -15,6 +15,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "core.h"
 #include "hif-ops.h"
 #include "cfg80211.h"
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index f85353f..521f0be 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -15,6 +15,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "core.h"
 #include "debug.h"
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index de5ee15..a2e939a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "htc.h"
 
 MODULE_AUTHOR("Atheros Communications");
@@ -966,9 +968,7 @@ int ath9k_htc_resume(struct htc_target *htc_handle)
 static int __init ath9k_htc_init(void)
 {
 	if (ath9k_hif_usb_init() < 0) {
-		printk(KERN_ERR
-			"ath9k_htc: No USB devices found,"
-			" driver not installed.\n");
+		pr_err("No USB devices found, driver not installed\n");
 		return -ENODEV;
 	}
 
@@ -979,6 +979,6 @@ module_init(ath9k_htc_init);
 static void __exit ath9k_htc_exit(void)
 {
 	ath9k_hif_usb_exit();
-	printk(KERN_INFO "ath9k_htc: Driver unloaded\n");
+	pr_info("Driver unloaded\n");
 }
 module_exit(ath9k_htc_exit);
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 1b90ed8..8a8a88a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "htc.h"
 
 static int htc_issue_send(struct htc_target *target, struct sk_buff* skb,
@@ -432,8 +434,7 @@ struct htc_target *ath9k_htc_hw_alloc(void *hif_handle,
 
 	target = kzalloc(sizeof(struct htc_target), GFP_KERNEL);
 	if (!target) {
-		printk(KERN_ERR "Unable to allocate memory for"
-			"target device\n");
+		pr_err("Unable to allocate memory for target device\n");
 		return NULL;
 	}
 
@@ -464,7 +465,7 @@ int ath9k_htc_hw_init(struct htc_target *target,
 		      char *product, u32 drv_info)
 {
 	if (ath9k_htc_probe_device(target, dev, devid, product, drv_info)) {
-		printk(KERN_ERR "Failed to initialize the device\n");
+		pr_err("Failed to initialize the device\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 60159f4..ce8b523 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/ath9k_platform.h>
@@ -866,17 +868,14 @@ static int __init ath9k_init(void)
 	/* Register rate control algorithm */
 	error = ath_rate_control_register();
 	if (error != 0) {
-		printk(KERN_ERR
-			"ath9k: Unable to register rate control "
-			"algorithm: %d\n",
-			error);
+		pr_err("Unable to register rate control algorithm: %d\n",
+		       error);
 		goto err_out;
 	}
 
 	error = ath_pci_init();
 	if (error < 0) {
-		printk(KERN_ERR
-			"ath9k: No PCI devices found, driver not installed.\n");
+		pr_err("No PCI devices found, driver not installed\n");
 		error = -ENODEV;
 		goto err_rate_unregister;
 	}
@@ -905,6 +904,6 @@ static void __exit ath9k_exit(void)
 	ath_ahb_exit();
 	ath_pci_exit();
 	ath_rate_control_unregister();
-	printk(KERN_INFO "%s: Driver unloaded\n", dev_info);
+	pr_info("%s: Driver unloaded\n", dev_info);
 }
 module_exit(ath9k_exit);
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 77dc327..a856b51 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/nl80211.h>
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
@@ -171,14 +173,13 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	ret =  pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret) {
-		printk(KERN_ERR "ath9k: 32-bit DMA not available\n");
+		pr_err("32-bit DMA not available\n");
 		goto err_dma;
 	}
 
 	ret = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (ret) {
-		printk(KERN_ERR "ath9k: 32-bit DMA consistent "
-			"DMA enable failed\n");
+		pr_err("32-bit DMA consistent DMA enable failed\n");
 		goto err_dma;
 	}
 
@@ -224,7 +225,7 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	mem = pci_iomap(pdev, 0, 0);
 	if (!mem) {
-		printk(KERN_ERR "PCI memory map error\n") ;
+		pr_err("PCI memory map error\n") ;
 		ret = -EIO;
 		goto err_iomap;
 	}
diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
index ea2c737..8e99540 100644
--- a/drivers/net/wireless/ath/main.c
+++ b/drivers/net/wireless/ath/main.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 
@@ -49,7 +51,7 @@ struct sk_buff *ath_rxbuf_alloc(struct ath_common *common,
 		if (off != 0)
 			skb_reserve(skb, common->cachelsz - off);
 	} else {
-		printk(KERN_ERR "skbuff alloc of size %u failed\n", len);
+		pr_err("skbuff alloc of size %u failed\n", len);
 		return NULL;
 	}
 
diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/regd.c
index 10dea37..d816980 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <net/cfg80211.h>
@@ -562,7 +564,7 @@ static int __ath_regd_init(struct ath_regulatory *reg)
 	printk(KERN_DEBUG "ath: EEPROM regdomain: 0x%0x\n", reg->current_rd);
 
 	if (!ath_regd_is_eeprom_valid(reg)) {
-		printk(KERN_ERR "ath: Invalid EEPROM contents\n");
+		pr_err("Invalid EEPROM contents\n");
 		return -EINVAL;
 	}
 
-- 
1.7.8.111.gad25c.dirty
