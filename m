From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath: change logging functions to return void
Date: Mon, 22 Sep 2014 10:35:34 -0700
Message-ID: <1411407334.2952.46.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wil6210 <wil6210@qca.qualcomm.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return values are not used by callers of these functions
so change the functions to return void.

Other miscellanea:

o add __printf verification to wil6210 logging functions
  No format/argument mismatches found

Signed-off-by: Joe Perches <joe@perches.com>
---
This change is associated to a desire to eventually
change printk to return void.

 drivers/net/wireless/ath/ath10k/debug.c    | 18 +++++-------------
 drivers/net/wireless/ath/ath10k/debug.h    |  6 +++---
 drivers/net/wireless/ath/ath6kl/common.h   |  2 +-
 drivers/net/wireless/ath/ath6kl/debug.c    | 28 ++++++++--------------------
 drivers/net/wireless/ath/ath6kl/debug.h    | 13 ++++++-------
 drivers/net/wireless/ath/wil6210/debug.c   | 14 ++++----------
 drivers/net/wireless/ath/wil6210/wil6210.h |  7 +++++--
 7 files changed, 32 insertions(+), 56 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/net/wireless/ath/ath10k/debug.c
index f3f0a80..29eb2aa 100644
--- a/drivers/net/wireless/ath/ath10k/debug.c
+++ b/drivers/net/wireless/ath/ath10k/debug.c
@@ -106,21 +106,18 @@ struct ath10k_dump_file_data {
 	u8 data[0];
 } __packed;
 
-int ath10k_info(struct ath10k *ar, const char *fmt, ...)
+void ath10k_info(struct ath10k *ar, const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = dev_info(ar->dev, "%pV", &vaf);
+	dev_info(ar->dev, "%pV", &vaf);
 	trace_ath10k_log_info(&vaf);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(ath10k_info);
 
@@ -142,25 +139,22 @@ void ath10k_print_driver_info(struct ath10k *ar)
 }
 EXPORT_SYMBOL(ath10k_print_driver_info);
 
-int ath10k_err(struct ath10k *ar, const char *fmt, ...)
+void ath10k_err(struct ath10k *ar, const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = dev_err(ar->dev, "%pV", &vaf);
+	dev_err(ar->dev, "%pV", &vaf);
 	trace_ath10k_log_err(&vaf);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(ath10k_err);
 
-int ath10k_warn(struct ath10k *ar, const char *fmt, ...)
+void ath10k_warn(struct ath10k *ar, const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
@@ -173,8 +167,6 @@ int ath10k_warn(struct ath10k *ar, const char *fmt, ...)
 	trace_ath10k_log_warn(&vaf);
 
 	va_end(args);
-
-	return 0;
 }
 EXPORT_SYMBOL(ath10k_warn);
 
diff --git a/drivers/net/wireless/ath/ath10k/debug.h b/drivers/net/wireless/ath/ath10k/debug.h
index 5674653..a4d35e4 100644
--- a/drivers/net/wireless/ath/ath10k/debug.h
+++ b/drivers/net/wireless/ath/ath10k/debug.h
@@ -39,9 +39,9 @@ enum ath10k_debug_mask {
 
 extern unsigned int ath10k_debug_mask;
 
-__printf(2, 3) int ath10k_info(struct ath10k *ar, const char *fmt, ...);
-__printf(2, 3) int ath10k_err(struct ath10k *ar, const char *fmt, ...);
-__printf(2, 3) int ath10k_warn(struct ath10k *ar, const char *fmt, ...);
+__printf(2, 3) void ath10k_info(struct ath10k *ar, const char *fmt, ...);
+__printf(2, 3) void ath10k_err(struct ath10k *ar, const char *fmt, ...);
+__printf(2, 3) void ath10k_warn(struct ath10k *ar, const char *fmt, ...);
 void ath10k_print_driver_info(struct ath10k *ar);
 
 #ifdef CONFIG_ATH10K_DEBUGFS
diff --git a/drivers/net/wireless/ath/ath6kl/common.h b/drivers/net/wireless/ath/ath6kl/common.h
index 05debf7..4f82e86 100644
--- a/drivers/net/wireless/ath/ath6kl/common.h
+++ b/drivers/net/wireless/ath/ath6kl/common.h
@@ -22,7 +22,7 @@
 
 #define ATH6KL_MAX_IE			256
 
-__printf(2, 3) int ath6kl_printk(const char *level, const char *fmt, ...);
+__printf(2, 3) void ath6kl_printk(const char *level, const char *fmt, ...);
 
 /*
  * Reflects the version of binary interface exposed by ATH6KL target
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index 55c4064..81ba48d 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -37,76 +37,64 @@ struct ath6kl_fwlog_slot {
 
 #define ATH6KL_FWLOG_VALID_MASK 0x1ffff
 
-int ath6kl_printk(const char *level, const char *fmt, ...)
+void ath6kl_printk(const char *level, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	int rtn;
 
 	va_start(args, fmt);
 
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	rtn = printk("%sath6kl: %pV", level, &vaf);
+	printk("%sath6kl: %pV", level, &vaf);
 
 	va_end(args);
-
-	return rtn;
 }
 EXPORT_SYMBOL(ath6kl_printk);
 
-int ath6kl_info(const char *fmt, ...)
+void ath6kl_info(const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = ath6kl_printk(KERN_INFO, "%pV", &vaf);
+	ath6kl_printk(KERN_INFO, "%pV", &vaf);
 	trace_ath6kl_log_info(&vaf);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(ath6kl_info);
 
-int ath6kl_err(const char *fmt, ...)
+void ath6kl_err(const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = ath6kl_printk(KERN_ERR, "%pV", &vaf);
+	ath6kl_printk(KERN_ERR, "%pV", &vaf);
 	trace_ath6kl_log_err(&vaf);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(ath6kl_err);
 
-int ath6kl_warn(const char *fmt, ...)
+void ath6kl_warn(const char *fmt, ...)
 {
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = ath6kl_printk(KERN_WARNING, "%pV", &vaf);
+	ath6kl_printk(KERN_WARNING, "%pV", &vaf);
 	trace_ath6kl_log_warn(&vaf);
 	va_end(args);
-
-	return ret;
 }
 EXPORT_SYMBOL(ath6kl_warn);
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index e194c10d..19106ed 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -50,10 +50,10 @@ enum ATH6K_DEBUG_MASK {
 };
 
 extern unsigned int debug_mask;
-__printf(2, 3) int ath6kl_printk(const char *level, const char *fmt, ...);
-__printf(1, 2) int ath6kl_info(const char *fmt, ...);
-__printf(1, 2) int ath6kl_err(const char *fmt, ...);
-__printf(1, 2) int ath6kl_warn(const char *fmt, ...);
+__printf(2, 3) void ath6kl_printk(const char *level, const char *fmt, ...);
+__printf(1, 2) void ath6kl_info(const char *fmt, ...);
+__printf(1, 2) void ath6kl_err(const char *fmt, ...);
+__printf(1, 2) void ath6kl_warn(const char *fmt, ...);
 
 enum ath6kl_war {
 	ATH6KL_WAR_INVALID_RATE,
@@ -81,10 +81,9 @@ int ath6kl_debug_init_fs(struct ath6kl *ar);
 void ath6kl_debug_cleanup(struct ath6kl *ar);
 
 #else
-static inline int ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask,
-			     const char *fmt, ...)
+static inline void ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask,
+			      const char *fmt, ...)
 {
-	return 0;
 }
 
 static inline void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
diff --git a/drivers/net/wireless/ath/wil6210/debug.c b/drivers/net/wireless/ath/wil6210/debug.c
index 9eeabf4..7a925ac 100644
--- a/drivers/net/wireless/ath/wil6210/debug.c
+++ b/drivers/net/wireless/ath/wil6210/debug.c
@@ -17,40 +17,34 @@
 #include "wil6210.h"
 #include "trace.h"
 
-int wil_err(struct wil6210_priv *wil, const char *fmt, ...)
+void wil_err(struct wil6210_priv *wil, const char *fmt, ...)
 {
 	struct net_device *ndev = wil_to_ndev(wil);
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = netdev_err(ndev, "%pV", &vaf);
+	netdev_err(ndev, "%pV", &vaf);
 	trace_wil6210_log_err(&vaf);
 	va_end(args);
-
-	return ret;
 }
 
-int wil_info(struct wil6210_priv *wil, const char *fmt, ...)
+void wil_info(struct wil6210_priv *wil, const char *fmt, ...)
 {
 	struct net_device *ndev = wil_to_ndev(wil);
 	struct va_format vaf = {
 		.fmt = fmt,
 	};
 	va_list args;
-	int ret;
 
 	va_start(args, fmt);
 	vaf.va = &args;
-	ret = netdev_info(ndev, "%pV", &vaf);
+	netdev_info(ndev, "%pV", &vaf);
 	trace_wil6210_log_info(&vaf);
 	va_end(args);
-
-	return ret;
 }
 
 int wil_dbg_trace(struct wil6210_priv *wil, const char *fmt, ...)
diff --git a/drivers/net/wireless/ath/wil6210/wil6210.h b/drivers/net/wireless/ath/wil6210/wil6210.h
index 133eeb8..d13fa53 100644
--- a/drivers/net/wireless/ath/wil6210/wil6210.h
+++ b/drivers/net/wireless/ath/wil6210/wil6210.h
@@ -451,9 +451,12 @@ struct wil6210_priv {
 #define ndev_to_wil(n) (wdev_to_wil(n->ieee80211_ptr))
 #define wil_to_pcie_dev(i) (&i->pdev->dev)
 
+__printf(2, 3)
 int wil_dbg_trace(struct wil6210_priv *wil, const char *fmt, ...);
-int wil_err(struct wil6210_priv *wil, const char *fmt, ...);
-int wil_info(struct wil6210_priv *wil, const char *fmt, ...);
+__printf(2, 3)
+void wil_err(struct wil6210_priv *wil, const char *fmt, ...);
+__printf(2, 3)
+void wil_info(struct wil6210_priv *wil, const char *fmt, ...);
 #define wil_dbg(wil, fmt, arg...) do { \
 	netdev_dbg(wil_to_ndev(wil), fmt, ##arg); \
 	wil_dbg_trace(wil, fmt, ##arg); \
