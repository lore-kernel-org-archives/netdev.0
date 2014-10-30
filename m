From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/6 3.18] rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing get_btc_status
Date: Wed, 29 Oct 2014 23:17:08 -0500
Message-ID: <1414642633-3700-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The recent changes in checking for Bluetooth status added some callbacks to code
in rtlwifi. To make certain that all callbacks are defined, a dummy routine has been
added to rtlwifi, and the drivers that need to use it are modified.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/core.c         | 6 ++++++
 drivers/net/wireless/rtlwifi/core.h         | 1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c | 1 +
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c | 1 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c | 1 +
 5 files changed, 10 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index f6179bc..07dae0d 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1828,3 +1828,9 @@ const struct ieee80211_ops rtl_ops = {
 	.flush = rtl_op_flush,
 };
 EXPORT_SYMBOL_GPL(rtl_ops);
+
+bool rtl_btc_status_false(void)
+{
+	return false;
+}
+EXPORT_SYMBOL_GPL(rtl_btc_status_false);
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index 59cd3b9..624e1dc 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -42,5 +42,6 @@ void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_path rfpath, u32 addr,
 		     u32 mask, u32 data);
 void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data);
 bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb);
+bool rtl_btc_status_false(void);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index d86b5b5..46ea076 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -244,6 +244,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops = {
 	.phy_lc_calibrate = _rtl92ce_phy_lc_calibrate,
 	.phy_set_bw_mode_callback = rtl92ce_phy_set_bw_mode_callback,
 	.dm_dynamic_txpower = rtl92ce_dm_dynamic_txpower,
+	.get_btc_status = rtl_btc_status_false,
 };
 
 static struct rtl_mod_params rtl92ce_mod_params = {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index edab5a5..a0aba08 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -251,6 +251,7 @@ static struct rtl_hal_ops rtl8192de_hal_ops = {
 	.get_rfreg = rtl92d_phy_query_rf_reg,
 	.set_rfreg = rtl92d_phy_set_rf_reg,
 	.linked_set_reg = rtl92d_linked_set_reg,
+	.get_btc_status = rtl_btc_status_false,
 };
 
 static struct rtl_mod_params rtl92de_mod_params = {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 1bff2a0..5e16984 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -294,6 +294,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.set_bbreg = rtl92s_phy_set_bb_reg,
 	.get_rfreg = rtl92s_phy_query_rf_reg,
 	.set_rfreg = rtl92s_phy_set_rf_reg,
+	.get_btc_status = rtl_btc_status_false,
 };
 
 static struct rtl_mod_params rtl92se_mod_params = {
-- 
2.1.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
