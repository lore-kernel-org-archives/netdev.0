From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] realtek: rtlwifi: drivers: Use the rtl_btc convenience macro
Date: Mon, 19 Jun 2017 13:18:18 -0700
Message-ID: <b70dcaa00cc18869fe82894537941693db37be5d.1497903396.git.joe@perches.com>
References: <cover.1497903396.git.joe@perches.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the uses of the btcoexist.<funcs> to the rtl_btc macro to
save a few lines of code.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c      | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c | 4 +---
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c      | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c      | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c      | 6 ++----
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c      | 3 +--
 6 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
index 11d97fa0e921..9fc3e79e5a43 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c
@@ -2572,8 +2572,7 @@ void rtl92ee_bt_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+	rtl_btc(rtlpriv, rtlpriv->cfg->ops, btc_init_hw_config(rtlpriv));
 }
 
 void rtl92ee_suspend(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
index ec9bcf32f0ab..8621ea8f6644 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c
@@ -1767,9 +1767,7 @@ void rtl_8723e_c2h_command_handle(struct ieee80211_hw *hw)
 
 		rtl8723e_dm_bt_parse_bt_info(hw, ptmp_buf, c2h_event.cmd_len);
 
-		if (rtlpriv->cfg->ops->get_btc_status())
-			rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
-
+		rtl_btc(rtlpriv, rtlpriv->cfg->ops, btc_periodical(rtlpriv));
 		break;
 	default:
 		break;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index 5ac7b815648a..3b6d140bb863 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -2419,8 +2419,7 @@ void rtl8723e_bt_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+	rtl_btc(rtlpriv, rtlpriv->cfg->ops, btc_init_hw_config(rtlpriv));
 }
 
 void rtl8723e_suspend(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index a79f936bb394..bddc4f56832d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -2719,8 +2719,7 @@ void rtl8723be_bt_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+	rtl_btc(rtlpriv, rtlpriv->cfg->ops, btc_init_hw_config(rtlpriv));
 
 }
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
index 73350103b736..a7a537716a8e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
@@ -1879,10 +1879,8 @@ void rtl8821ae_c2h_content_parsing(struct ieee80211_hw *hw,
 	case C2H_8812_BT_INFO:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
 			 "[C2H], C2H_8812_BT_INFO!!\n");
-		if (rtlpriv->cfg->ops->get_btc_status())
-			rtlpriv->btcoexist.btc_ops->btc_btinfo_notify(rtlpriv,
-								      tmp_buf,
-								      c2h_cmd_len);
+		rtl_btc(rtlpriv, rtlpriv->cfg->ops,
+			btc_btinfo_notify(rtlpriv, tmp_buf, c2h_cmd_len));
 		break;
 	default:
 		break;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 2bc6bace069c..f76c64570d16 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -4012,8 +4012,7 @@ void rtl8821ae_bt_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+	rtl_btc(rtlpriv, rtlpriv->cfg->ops, btc_init_hw_config(rtlpriv));
 }
 
 void rtl8821ae_suspend(struct ieee80211_hw *hw)
-- 
2.10.0.rc2.1.g053435c
