From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] rtlwifi: Remove unused cur_rfstate variables
Date: Wed, 11 Oct 2017 22:15:15 +0100
Message-ID: <1507756515-15738-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37362 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752485AbdJKVPT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:15:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up unused cur_rfstate variables in rtl8188ee, rtl8723ae, rtl8723be
and rtl8821ae.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c | 4 +---
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c | 4 +---
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c | 4 +---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c | 4 +---
 4 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
index 0ba26d2..4d843e6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/hw.c
@@ -2235,7 +2235,7 @@ bool rtl88ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
+	enum rf_pwrstate e_rfpowerstate_toset;
 	u32 u4tmp;
 	bool b_actuallyset = false;
 
@@ -2254,8 +2254,6 @@ bool rtl88ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
-	cur_rfstate = ppsc->rfpwr_state;
-
 	u4tmp = rtl_read_dword(rtlpriv, REG_GPIO_OUTPUT);
 	e_rfpowerstate_toset = (u4tmp & BIT(31)) ? ERFON : ERFOFF;
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
index 5ac7b81..4e1e1f8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/hw.c
@@ -2103,7 +2103,7 @@ bool rtl8723e_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
+	enum rf_pwrstate e_rfpowerstate_toset;
 	u8 u1tmp;
 	bool b_actuallyset = false;
 
@@ -2122,8 +2122,6 @@ bool rtl8723e_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
-	cur_rfstate = ppsc->rfpwr_state;
-
 	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
 		       rtl_read_byte(rtlpriv, REG_GPIO_IO_SEL_2)&~(BIT(1)));
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
index 4d47b97..2ad1013 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c
@@ -2486,7 +2486,7 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
+	enum rf_pwrstate e_rfpowerstate_toset;
 	u8 u1tmp;
 	bool b_actuallyset = false;
 
@@ -2505,8 +2505,6 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
-	cur_rfstate = ppsc->rfpwr_state;
-
 	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
 		       rtl_read_byte(rtlpriv, REG_GPIO_IO_SEL_2) & ~(BIT(1)));
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 1d431d4..e756f94 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -3845,7 +3845,7 @@ bool rtl8821ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_phy *rtlphy = &rtlpriv->phy;
-	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
+	enum rf_pwrstate e_rfpowerstate_toset;
 	u8 u1tmp = 0;
 	bool b_actuallyset = false;
 
@@ -3864,8 +3864,6 @@ bool rtl8821ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
-	cur_rfstate = ppsc->rfpwr_state;
-
 	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
 			rtl_read_byte(rtlpriv,
 					REG_GPIO_IO_SEL_2) & ~(BIT(1)));
-- 
2.7.4
