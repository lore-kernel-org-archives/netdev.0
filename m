From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] rtlwifi: rtl8192ee: simplify coding
Date: Wed, 18 May 2016 02:43:58 +0200
Message-ID: <1463532238-13135-1-git-send-email-xypron.glpk@gmx.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:59399 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755424AbcERAo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 20:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify _rtl92ee_phy_path_adda_on.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
index 018340a..c2bf8d1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/phy.c
@@ -2414,19 +2414,10 @@ static void _rtl92ee_phy_reload_mac_registers(struct ieee80211_hw *hw,
 static void _rtl92ee_phy_path_adda_on(struct ieee80211_hw *hw, u32 *addareg,
 				      bool is_patha_on, bool is2t)
 {
-	u32 pathon;
 	u32 i;
 
-	pathon = is_patha_on ? 0x0fc01616 : 0x0fc01616;
-	if (!is2t) {
-		pathon = 0x0fc01616;
-		rtl_set_bbreg(hw, addareg[0], MASKDWORD, 0x0fc01616);
-	} else {
-		rtl_set_bbreg(hw, addareg[0], MASKDWORD, pathon);
-	}
-
-	for (i = 1; i < IQK_ADDA_REG_NUM; i++)
-		rtl_set_bbreg(hw, addareg[i], MASKDWORD, pathon);
+	for (i = 0; i < IQK_ADDA_REG_NUM; i++)
+		rtl_set_bbreg(hw, addareg[i], MASKDWORD, 0x0fc01616);
 }
 
 static void _rtl92ee_phy_mac_setting_calibration(struct ieee80211_hw *hw,
-- 
2.1.4
