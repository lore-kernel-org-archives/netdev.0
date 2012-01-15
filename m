From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/8] brcm80211: Use pr_fmt and pr_<level>
Date: Sun, 15 Jan 2012 00:38:44 -0800
Message-ID: <6f9290f7224adc3e71a0da688decd315ed34837b.1326616556.git.joe@perches.com>
References: <cover.1326616556.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1326616556.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert printks to pr_<level>
Prefix logging with pr_fmt.
Use ##__VA_ARGS__ in some WL_ logging macros.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    2 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    3 ++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    2 +
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |    3 ++
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    8 ++--
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |    2 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    2 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   30 ++++++++++----------
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    6 ++--
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    6 ++-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    2 +
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |    2 +
 13 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 4bc8d25..e925290 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -15,6 +15,8 @@
  */
 /* ****************** SDIO CARD Interface Functions **************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/export.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index 9b8c0ed..ac71ade 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@ -13,6 +13,9 @@
  * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/mmc/sdio.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c
index ac8d1f4..b3e3b7f 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c
@@ -19,6 +19,8 @@
  * For certain dcmd codes, the dongle interprets string data from the host.
  ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
index 1c75ea8..4187435 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -13,6 +13,9 @@
  * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 96f47e6..342d9f2 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -14,6 +14,8 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/kthread.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 91ec023..6e4b5e8 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -14,6 +14,8 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/kthread.h>
@@ -3896,8 +3898,7 @@ void *brcmf_sdbrcm_probe(u32 regsva, struct brcmf_sdio_dev *sdiodev)
 	bus->watchdog_tsk = kthread_run(brcmf_sdbrcm_watchdog_thread,
 					bus, "brcmf_watchdog");
 	if (IS_ERR(bus->watchdog_tsk)) {
-		printk(KERN_WARNING
-		       "brcmf_watchdog thread failed to start\n");
+		pr_warn("brcmf_watchdog thread failed to start\n");
 		bus->watchdog_tsk = NULL;
 	}
 	/* Initialize DPC thread */
@@ -3905,8 +3906,7 @@ void *brcmf_sdbrcm_probe(u32 regsva, struct brcmf_sdio_dev *sdiodev)
 	bus->dpc_tsk = kthread_run(brcmf_sdbrcm_dpc_thread,
 				   bus, "brcmf_dpc");
 	if (IS_ERR(bus->dpc_tsk)) {
-		printk(KERN_WARNING
-		       "brcmf_dpc thread failed to start\n");
+		pr_warn("brcmf_dpc thread failed to start\n");
 		bus->dpc_tsk = NULL;
 	}
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c
index 11b2d7c..1534efc 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c
@@ -15,6 +15,8 @@
  */
 /* ***** SDIO interface chip backplane handle functions ***** */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/mmc/card.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index f23b0c3..271ca85 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -16,6 +16,8 @@
 
 /* Toplevel file. Relies on dhd_linux.c to send commands to the dongle. */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
index 69a4872..b5d9b36 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
@@ -32,53 +32,53 @@ struct brcmf_cfg80211_ibss;
 #define WL_DBG_MASK		((WL_DBG_INFO | WL_DBG_ERR | WL_DBG_TRACE) | \
 				(WL_DBG_SCAN) | (WL_DBG_CONN))
 
-#define	WL_ERR(fmt, args...)					\
+#define	WL_ERR(fmt, ...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_ERR) {			\
 		if (net_ratelimit()) {				\
-			printk(KERN_ERR "ERROR @%s : " fmt,	\
-				__func__, ##args);		\
+			pr_err("ERROR @%s : " fmt,		\
+			       __func__, ##__VA_ARGS__);	\
 		}						\
 	}							\
 } while (0)
 
 #if (defined DEBUG)
-#define	WL_INFO(fmt, args...)					\
+#define	WL_INFO(fmt, ...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_INFO) {			\
 		if (net_ratelimit()) {				\
-			printk(KERN_ERR "INFO @%s : " fmt,	\
-				__func__, ##args);		\
+			pr_err("INFO @%s : " fmt,		\
+			       __func__, ##__VA_ARGS__);	\
 		}						\
 	}							\
 } while (0)
 
-#define	WL_TRACE(fmt, args...)					\
+#define	WL_TRACE(fmt, ...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_TRACE) {			\
 		if (net_ratelimit()) {				\
-			printk(KERN_ERR "TRACE @%s : " fmt,	\
-				__func__, ##args);		\
+			pr_err("TRACE @%s : " fmt,		\
+			       __func__, ##__VA_ARGS__);	\
 		}						\
 	}							\
 } while (0)
 
-#define	WL_SCAN(fmt, args...)					\
+#define	WL_SCAN(fmt, ...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_SCAN) {			\
 		if (net_ratelimit()) {				\
-			printk(KERN_ERR "SCAN @%s : " fmt,	\
-				__func__, ##args);		\
+			pr_err("SCAN @%s : " fmt,		\
+			       __func__, ##__VA_ARGS__);	\
 		}						\
 	}							\
 } while (0)
 
-#define	WL_CONN(fmt, args...)					\
+#define	WL_CONN(fmt, ...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_CONN) {			\
 		if (net_ratelimit()) {				\
-			printk(KERN_ERR "CONN @%s : " fmt,	\
-				__func__, ##args);		\
+			pr_err("CONN @%s : " fmt,		\
+			       __func__, ##__VA_ARGS__);	\
 		}						\
 	}							\
 } while (0)
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 9c60f42..a5c1634 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -15,6 +15,7 @@
  */
 
 #define __UNDEF_NO_VERSION__
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/etherdevice.h>
 #include <linux/sched.h>
@@ -1121,8 +1122,7 @@ static int __devinit brcms_bcma_probe(struct bcma_device *pdev)
 
 	wl = brcms_attach(pdev);
 	if (!wl) {
-		pr_err("%s: %s: brcms_attach failed!\n", KBUILD_MODNAME,
-		       __func__);
+		pr_err("%s: brcms_attach failed!\n", __func__);
 		return -ENODEV;
 	}
 	return 0;
@@ -1215,7 +1215,7 @@ static int __init brcms_module_init(void)
 #endif				/* DEBUG */
 
 	error = bcma_driver_register(&brcms_bcma_driver);
-	printk(KERN_ERR "%s: register returned %d\n", __func__, error);
+	pr_err("%s: register returned %d\n", __func__, error);
 	if (!error)
 		return 0;
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 72701a4..976a531 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -14,6 +14,8 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/pci_ids.h>
 #include <linux/if_ether.h>
 #include <net/mac80211.h>
@@ -5807,7 +5809,7 @@ void brcms_c_print_txstatus(struct tx_status *txs)
 bool brcms_c_chipmatch(u16 vendor, u16 device)
 {
 	if (vendor != PCI_VENDOR_ID_BROADCOM) {
-		pr_err("chipmatch: unknown vendor id %04x\n", vendor);
+		pr_err("unknown vendor id %04x\n", vendor);
 		return false;
 	}
 
@@ -5820,7 +5822,7 @@ bool brcms_c_chipmatch(u16 vendor, u16 device)
 	if ((device == BCM43236_D11N_ID) || (device == BCM43236_D11N2G_ID))
 		return true;
 
-	pr_err("chipmatch: unknown device id %04x\n", device);
+	pr_err("unknown device id %04x\n", device);
 	return false;
 }
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index a0909be6..ec7450d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -14,6 +14,8 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/delay.h>
 #include <linux/cordic.h>
diff --git a/drivers/net/wireless/brcm80211/brcmutil/utils.c b/drivers/net/wireless/brcm80211/brcmutil/utils.c
index 4908660..b45ab34 100644
--- a/drivers/net/wireless/brcm80211/brcmutil/utils.c
+++ b/drivers/net/wireless/brcm80211/brcmutil/utils.c
@@ -14,6 +14,8 @@
  * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/netdevice.h>
 #include <linux/module.h>
 
-- 
1.7.8.111.gad25c.dirty
