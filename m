From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/12 NEXT] rtlwifi: rtl8192cu: Update the power index registers
Date: Mon, 18 Nov 2013 11:11:33 -0600
Message-ID: <1384794696-20314-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch uses the newly introduced power index register routines.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c | 6 ++++++
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.h | 3 +++
 2 files changed, 9 insertions(+)

Index: wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
===================================================================
--- wireless-testing.orig/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
+++ wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
@@ -101,6 +101,15 @@ void rtl92cu_dm_dynamic_txpower(struct i
 			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
 			 rtlphy->current_channel);
 		rtl92c_phy_set_txpower_level(hw, rtlphy->current_channel);
+		if (rtlpriv->dm.dynamic_txhighpower_lvl ==
+		    TXHIGHPWRLEVEL_NORMAL)
+			dm_restorepowerindex(hw);
+		else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
+			 TXHIGHPWRLEVEL_LEVEL1)
+			dm_writepowerindex(hw, 0x14);
+		else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
+			 TXHIGHPWRLEVEL_LEVEL2)
+			dm_writepowerindex(hw, 0x10);
 	}
 
 	rtlpriv->dm.last_dtp_lvl = rtlpriv->dm.dynamic_txhighpower_lvl;
Index: wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/dm.h
===================================================================
--- wireless-testing.orig/drivers/net/wireless/rtlwifi/rtl8192cu/dm.h
+++ wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/dm.h
@@ -30,3 +30,6 @@
 #include "../rtl8192ce/dm.h"
 
 void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw);
+void dm_savepowerindex(struct ieee80211_hw *hw);
+void dm_writepowerindex(struct ieee80211_hw *hw, u8 value);
+void dm_restorepowerindex(struct ieee80211_hw *hw);
