From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/5] rtlwifi: Use temporary variable btc_ops for rtlpriv->btcoexist.btc_ops
Date: Mon, 19 Jun 2017 13:18:15 -0700
Message-ID: <bf91a41de9e3769455e2a325eaddc1cb73112327.1497903396.git.joe@perches.com>
References: <cover.1497903396.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the code line length a little.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/base.c |  7 ++++---
 drivers/net/wireless/realtek/rtlwifi/core.c | 10 ++++++----
 drivers/net/wireless/realtek/rtlwifi/pci.c  |  8 +++++---
 drivers/net/wireless/realtek/rtlwifi/ps.c   | 16 ++++++++++------
 4 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index 4436addcace3..cc4b50e1b7e5 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -1312,11 +1312,11 @@ static void setup_arp_tx(struct rtl_priv *rtlpriv, struct rtl_ps_ctl *ppsc)
 {
 	struct ieee80211_hw *hw = rtlpriv->hw;
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 
 	rtlpriv->ra.is_special_data = true;
 	if (ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_special_packet_notify(
-			rtlpriv, 1);
+		btc_ops->btc_special_packet_notify(rtlpriv, 1);
 	rtl_lps_leave(hw);
 	ppsc->last_delaylps_stamp_jiffies = jiffies;
 }
@@ -1575,6 +1575,7 @@ void rtl_watchdog_wq_callback(void *data)
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	bool busytraffic = false;
@@ -1714,7 +1715,7 @@ void rtl_watchdog_wq_callback(void *data)
 	}
 
 	if (ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
+		btc_ops->btc_periodical(rtlpriv);
 
 	rtlpriv->link_info.bcn_rx_inperiod = 0;
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 63f5c0cd6935..e08febc2d0d6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1046,6 +1046,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -1193,8 +1194,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				      true : false;
 
 		if (ops->get_btc_status())
-			rtlpriv->btcoexist.btc_ops->btc_mediastatus_notify(
-				rtlpriv, mstatus);
+			btc_ops->btc_mediastatus_notify(rtlpriv, mstatus);
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
@@ -1428,6 +1428,7 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1438,7 +1439,7 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 	}
 
 	if (ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 1);
+		btc_ops->btc_scan_notify(rtlpriv, 1);
 
 	if (rtlpriv->dm.supp_phymode_switch) {
 		if (ops->chk_switch_dmdp)
@@ -1464,6 +1465,7 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1491,7 +1493,7 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 
 	ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
 	if (ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 0);
+		btc_ops->btc_scan_notify(rtlpriv, 0);
 }
 
 static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index 81c36978df8a..f129c4c76c05 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -1814,6 +1814,7 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -1826,8 +1827,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	rtlpci->driver_is_goingto_unload = false;
 	if (ops->get_btc_status &&
 	    ops->get_btc_status()) {
-		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
-		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
+		btc_ops->btc_init_variables(rtlpriv);
+		btc_ops->btc_init_hal_vars(rtlpriv);
 	}
 	err = ops->hw_init(hw);
 	if (err) {
@@ -1858,6 +1859,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -1865,7 +1867,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	u8 RFInProgressTimeOut = 0;
 
 	if (ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_halt_notify();
+		btc_ops->btc_halt_notify();
 
 	/*
 	 *should be before disable interrupt&adapter
diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index 5a51e56c5f47..3cd8a387c845 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -210,6 +210,7 @@ void rtl_ips_nic_off_wq_callback(void *data)
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -261,8 +262,8 @@ void rtl_ips_nic_off_wq_callback(void *data)
 
 			/* call before RF off */
 			if (ops->get_btc_status())
-				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
-									   ppsc->inactive_pwrstate);
+				btc_ops->btc_ips_notify(rtlpriv,
+							ppsc->inactive_pwrstate);
 
 			/*rtl_pci_reset_trx_ring(hw); */
 			_rtl_ps_inactive_ps(hw);
@@ -289,6 +290,7 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	enum rf_pwrstate rtstate;
 
@@ -307,8 +309,8 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 			_rtl_ps_inactive_ps(hw);
 			/* call after RF on */
 			if (ops->get_btc_status())
-				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
-									   ppsc->inactive_pwrstate);
+				btc_ops->btc_ips_notify(rtlpriv,
+							ppsc->inactive_pwrstate);
 		}
 	}
 	spin_unlock(&rtlpriv->locks.ips_lock);
@@ -352,6 +354,7 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
+	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	bool enter_fwlps;
@@ -392,14 +395,15 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 				rtl_p2p_ps_cmd(hw , P2P_PS_ENABLE);
 
 			if (ops->get_btc_status())
-				rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
+				btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
 				if (ops->get_btc_status())
-					rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
+					btc_ops->btc_lps_notify(rtlpriv,
+								rt_psmode);
 				enter_fwlps = true;
 				ppsc->pwr_mode = ppsc->fwctrl_psmode;
 				ppsc->smart_ps = 2;
-- 
2.10.0.rc2.1.g053435c
