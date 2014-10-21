From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8821ae: Fix possible array overrun
Date: Tue, 21 Oct 2014 10:52:51 -0500
Message-ID: <1413906771-28599-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50274 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbaJUPxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:53:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot reported a possible array overrun. The affected code
checks for overruns, but fails to take the steps necessary to fix them.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
index 9786313..1e9570f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
@@ -1889,15 +1889,18 @@ static void _rtl8821ae_store_tx_power_by_rate(struct ieee80211_hw *hw,
 	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 rate_section = _rtl8821ae_get_rate_section_index(regaddr);
 
-	if (band != BAND_ON_2_4G && band != BAND_ON_5G)
+	if (band != BAND_ON_2_4G && band != BAND_ON_5G) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid Band %d\n", band);
-
-	if (rfpath >= MAX_RF_PATH)
+		band = BAND_ON_2_4G;
+	}
+	if (rfpath >= MAX_RF_PATH) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid RfPath %d\n", rfpath);
-
-	if (txnum >= MAX_RF_PATH)
+		rfpath = MAX_RF_PATH - 1;
+	}
+	if (txnum >= MAX_RF_PATH) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid TxNum %d\n", txnum);
-
+		txnum = MAX_RF_PATH - 1;
+	}
 	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section] = data;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "TxPwrByRateOffset[Band %d][RfPath %d][TxNum %d][RateSection %d] = 0x%x\n",
-- 
1.8.4.5
