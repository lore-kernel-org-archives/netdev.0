From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/7] rtlwifi: Neaten RT_ASSERT, RT_TRACE, RTPRINT, RT_PRINT_DATA macros
Date: Wed,  4 Jan 2012 19:40:39 -0800
Message-ID: <54d3f83c3e53d7008a013a631c23360a983695a6.1325734202.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the macros a bit more readable.

Use do {...} while (0) without terminating semicolons.
Add missing terminating semicolon to a few uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/debug.h         |   88 ++++++++++++--------------
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c  |    2 +-
 drivers/net/wireless/rtlwifi/usb.c           |    6 +-
 5 files changed, 47 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 160dd06..802c491 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -156,53 +156,47 @@ enum dbgp_flag_e {
 	DBGP_TYPE_MAX
 };
 
-#define RT_ASSERT(_exp, fmt)				\
-	do {						\
-		if (!(_exp)) {			\
-			printk(KERN_DEBUG "%s:%s(): ", KBUILD_MODNAME, \
-			__func__);			\
-			printk fmt;			\
-		} \
-	} while (0);
-
-#define RT_TRACE(rtlpriv, comp, level, fmt)\
-	do { \
-		if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) && \
-			((level) <= rtlpriv->dbg.global_debuglevel))) {\
-			printk(KERN_DEBUG "%s:%s():<%lx-%x> ", KBUILD_MODNAME, \
-			__func__, in_interrupt(), in_atomic());	\
-			printk fmt;				\
-		} \
-	} while (0);
-
-#define RTPRINT(rtlpriv, dbgtype, dbgflag, printstr)	\
-	do {						\
-		if (unlikely(rtlpriv->dbg.dbgp_type[dbgtype] & dbgflag)) { \
-			printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);	\
-			printk printstr;		\
-		}					\
-	} while (0);
-
-#define RT_PRINT_DATA(rtlpriv, _comp, _level, _titlestring, _hexdata, \
-		_hexdatalen) \
-	do {\
-		if (unlikely(((_comp) & rtlpriv->dbg.global_debugcomponents) &&\
-			(_level <= rtlpriv->dbg.global_debuglevel)))	{ \
-			int __i;					\
-			u8*	ptr = (u8 *)_hexdata;			\
-			printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);	\
-			printk("In process \"%s\" (pid %i):", current->comm,\
-					current->pid); \
-			printk(_titlestring);		\
-			for (__i = 0; __i < (int)_hexdatalen; __i++) {	\
-				printk("%02X%s", ptr[__i], (((__i + 1) % 4)\
-							== 0) ? "  " : " ");\
-				if (((__i + 1) % 16) == 0)		\
-					printk("\n");			\
-			}				\
-			printk(KERN_DEBUG "\n");			\
-		} \
-	} while (0);
+#define RT_ASSERT(_exp, fmt)						\
+do {									\
+	if (!(_exp)) {							\
+		printk(KERN_DEBUG "%s:%s(): ",				\
+		       KBUILD_MODNAME, __func__);			\
+		printk fmt;						\
+	}								\
+} while (0)
+
+#define RT_TRACE(rtlpriv, comp, level, fmt)				\
+do {									\
+	if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) &&	\
+		     ((level) <= rtlpriv->dbg.global_debuglevel))) {	\
+		printk(KERN_DEBUG "%s:%s():<%lx-%x> ",			\
+		       KBUILD_MODNAME, __func__,			\
+		       in_interrupt(), in_atomic());			\
+		printk fmt;						\
+	}								\
+} while (0)
+
+#define RTPRINT(rtlpriv, dbgtype, dbgflag, printstr)			\
+do {									\
+	if (unlikely(rtlpriv->dbg.dbgp_type[dbgtype] & dbgflag)) {	\
+		printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);		\
+		printk printstr;					\
+	}								\
+} while (0)
+
+#define RT_PRINT_DATA(rtlpriv, _comp, _level, _titlestring, _hexdata,	\
+		      _hexdatalen)					\
+do {									\
+	if (unlikely(((_comp) & rtlpriv->dbg.global_debugcomponents) &&	\
+		     (_level <= rtlpriv->dbg.global_debuglevel))) {	\
+		printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);		\
+		pr_cont("In process \"%s\" (pid %i):",			\
+			current->comm, current->pid);			\
+		printk(_titlestring);					\
+		print_hex_dump_bytes("", DUMP_PREFIX_NONE,		\
+				     _hexdata, _hexdatalen);		\
+	}								\
+} while (0)
 
 void rtl_dbgp_flag_init(struct ieee80211_hw *hw);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
index 3b585aa..ce9eea9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -374,7 +374,7 @@ void rtl92ce_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
 		 ("Switch to %s bandwidth\n",
 		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"))
+		  "20MHz" : "40MHz"));
 
 	if (is_hal_stop(rtlhal)) {
 		rtlphy->set_bwmode_inprogress = false;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index e49cf22..df491d3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -360,7 +360,7 @@ void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
 		 ("Switch to %s bandwidth\n",
 		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"))
+		  "20MHz" : "40MHz"));
 	if (is_hal_stop(rtlhal)) {
 		rtlphy->set_bwmode_inprogress = false;
 		return;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 9d89d7c..c8c4cf9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1617,7 +1617,7 @@ static void _rtl92de_read_txpower_info(struct ieee80211_hw *hw,
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				 ("Is D cut,Internal PA0 %d Internal PA1 %d\n",
 				 rtlefuse->internal_pa_5g[0],
-				 rtlefuse->internal_pa_5g[1]))
+				 rtlefuse->internal_pa_5g[1]));
 		}
 		rtlefuse->eeprom_c9 = hwinfo[EEPROM_RF_OPT6];
 		rtlefuse->eeprom_cc = hwinfo[EEPROM_RF_OPT7];
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index e956fa7..1b8e68e 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -414,7 +414,7 @@ static struct sk_buff *_rtl_prep_rx_urb(struct ieee80211_hw *hw,
 			       gfp_mask);
 	if (!skb) {
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("Failed to __dev_alloc_skb!!\n"))
+			 ("Failed to __dev_alloc_skb!!\n"));
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -632,14 +632,14 @@ static int _rtl_usb_receive(struct ieee80211_hw *hw)
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-				 ("Failed to alloc URB!!\n"))
+				 ("Failed to alloc URB!!\n"));
 			goto err_out;
 		}
 
 		skb = _rtl_prep_rx_urb(hw, rtlusb, urb, GFP_KERNEL);
 		if (IS_ERR(skb)) {
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-				 ("Failed to prep_rx_urb!!\n"))
+				 ("Failed to prep_rx_urb!!\n"));
 			err = PTR_ERR(skb);
 			goto err_out;
 		}
-- 
1.7.8.111.gad25c.dirty
