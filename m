From: Joe Perches <joe@perches.com>
Subject: [PATCH] rtlwifi: Simplify rtl_get/set inline functions
Date: Sat, 17 Mar 2012 13:36:30 -0700
Message-ID: <b3abde4a48c61f2064953d020fd985c37d6594ac.1332016501.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42439 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756437Ab2CQUgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 16:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a temporary to make the code a bit neater.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/wifi.h |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index b591614..0f1d211 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1954,37 +1954,35 @@ static inline void rtl_write_dword(struct rtl_priv *rtlpriv,
 static inline u32 rtl_get_bbreg(struct ieee80211_hw *hw,
 				u32 regaddr, u32 bitmask)
 {
-	return ((struct rtl_priv *)(hw)->priv)->cfg->ops->get_bbreg(hw,
-								    regaddr,
-								    bitmask);
+	struct rtl_priv *rtlpriv = hw->priv;
+
+	return rtlpriv->cfg->ops->get_bbreg(hw, regaddr, bitmask);
 }
 
 static inline void rtl_set_bbreg(struct ieee80211_hw *hw, u32 regaddr,
 				 u32 bitmask, u32 data)
 {
-	((struct rtl_priv *)(hw)->priv)->cfg->ops->set_bbreg(hw,
-							     regaddr, bitmask,
-							     data);
+	struct rtl_priv *rtlpriv = hw->priv;
 
+	rtlpriv->cfg->ops->set_bbreg(hw, regaddr, bitmask, data);
 }
 
 static inline u32 rtl_get_rfreg(struct ieee80211_hw *hw,
 				enum radio_path rfpath, u32 regaddr,
 				u32 bitmask)
 {
-	return ((struct rtl_priv *)(hw)->priv)->cfg->ops->get_rfreg(hw,
-								    rfpath,
-								    regaddr,
-								    bitmask);
+	struct rtl_priv *rtlpriv = hw->priv;
+
+	return rtlpriv->cfg->ops->get_rfreg(hw, rfpath, regaddr, bitmask);
 }
 
 static inline void rtl_set_rfreg(struct ieee80211_hw *hw,
 				 enum radio_path rfpath, u32 regaddr,
 				 u32 bitmask, u32 data)
 {
-	((struct rtl_priv *)(hw)->priv)->cfg->ops->set_rfreg(hw,
-							     rfpath, regaddr,
-							     bitmask, data);
+	struct rtl_priv *rtlpriv = hw->priv;
+
+	rtlpriv->cfg->ops->set_rfreg(hw, rfpath, regaddr, bitmask, data);
 }
 
 static inline bool is_hal_stop(struct rtl_hal *rtlhal)
-- 
1.7.8.111.gad25c.dirty
