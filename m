From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 3/7] rtlwifi: rtl8192ce: Convert driver to use new rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:29 -0500
Message-ID: <1380219933-16784-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now that rtl_phy_scan_operation_backup() exists, convert rtl8192ce to use it.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h | 1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  | 3 ++-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
index bb319b0..ff32b5b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
@@ -202,7 +202,6 @@ void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 void rtl92c_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel);
 void rtl92c_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
 bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm);
-void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type);
 void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 1420356..b790320 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -30,6 +30,7 @@
 #include "../wifi.h"
 #include "../core.h"
 #include "../pci.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -219,7 +220,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops = {
 	.set_bw_mode = rtl92c_phy_set_bw_mode,
 	.switch_channel = rtl92c_phy_sw_chnl,
 	.dm_watchdog = rtl92c_dm_watchdog,
-	.scan_operation_backup = rtl92c_phy_scan_operation_backup,
+	.scan_operation_backup = rtl_phy_scan_operation_backup,
 	.set_rf_power_state = rtl92c_phy_set_rf_power_state,
 	.led_control = rtl92ce_led_control,
 	.set_desc = rtl92ce_set_desc,
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
