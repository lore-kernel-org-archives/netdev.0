From: Priit Laes <plaes@plaes.org>
Subject: [PATCH 6/6] rtlwifi: Rename rtl_translate_todbm to rtl_signalpower_todbm
Date: Wed, 11 Mar 2015 22:03:29 +0200
Message-ID: <1426104209-6913-7-git-send-email-plaes@plaes.org>
References: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Priit Laes <plaes@plaes.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:51920 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752663AbbCKUDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 16:03:51 -0400
In-Reply-To: <1426104209-6913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/stats.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index c702d01..4739324 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -48,14 +48,9 @@ u8 rtl_evm_db_to_percentage(char value)
 }
 EXPORT_SYMBOL(rtl_evm_db_to_percentage);
 
-static long rtl_translate_todbm(struct ieee80211_hw *hw,
-			 u8 signal_strength_index)
+static long rtl_signalpower_todbm(u8 signal_strength_index)
 {
-	long signal_power;
-
-	signal_power = (long)((signal_strength_index + 1) >> 1);
-	signal_power -= 95;
-	return signal_power;
+	return (long)((signal_strength_index + 1) >> 1) - 95;
 }
 
 long rtl_signal_scale_mapping(long currsig)
@@ -93,7 +88,7 @@ static void rtl_process_ui_rssi(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	u8 rfpath;
-	u32 last_rssi, tmpval;
+	u32 last_rssi;
 
 	if (!pstatus->packet_toself && !pstatus->packet_beacon)
 		return;
@@ -112,10 +107,9 @@ static void rtl_process_ui_rssi(struct ieee80211_hw *hw,
 	    pstatus->signalstrength;
 	if (rtlpriv->stats.ui_rssi.index >= PHY_RSSI_SLID_WIN_MAX)
 		rtlpriv->stats.ui_rssi.index = 0;
-	tmpval = rtlpriv->stats.ui_rssi.total_val /
-		rtlpriv->stats.ui_rssi.total_num;
-	rtlpriv->stats.signal_strength = rtl_translate_todbm(hw,
-		(u8) tmpval);
+	rtlpriv->stats.signal_strength = rtl_signalpower_todbm(
+		(u8)rtlpriv->stats.ui_rssi.total_val /
+			rtlpriv->stats.ui_rssi.total_num);
 	pstatus->rssi = rtlpriv->stats.signal_strength;
 
 	if (pstatus->is_cck)
-- 
2.3.1
