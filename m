From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH] net: wireless: rtlwifi: rtl8723be: phy.c:  Remove unused function
Date: Sat, 20 Dec 2014 23:59:18 +0100
Message-ID: <1419116358-13223-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the function rtl8723be_phy_get_txpower_level() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c |   25 -------------------------
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h |    2 --
 2 files changed, 27 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
index 20dcc25..b7b73cb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
@@ -874,31 +874,6 @@ void rtl8723be_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 		  ROFDM0_RXDETECTOR3, rtlphy->framesync);
 }
 
-void rtl8723be_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &rtlpriv->phy;
-	u8 txpwr_level;
-	long txpwr_dbm;
-
-	txpwr_level = rtlphy->cur_cck_txpwridx;
-	txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_B,
-						 txpwr_level);
-	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
-	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G, txpwr_level) >
-	    txpwr_dbm)
-		txpwr_dbm =
-		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
-						 txpwr_level);
-	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
-	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
-					 txpwr_level) > txpwr_dbm)
-		txpwr_dbm =
-		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
-						 txpwr_level);
-	*powerlevel = txpwr_dbm;
-}
