From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/5] realtek: btcoexist: Make the rtl_btc_ops struct const
Date: Mon, 19 Jun 2017 13:18:17 -0700
Message-ID: <b71e1465b0ca58d748229392ab1bcdbaf65d762d.1497903396.git.joe@perches.com>
References: <cover.1497903396.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid allowing a write into what should be const.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c | 4 ++--
 drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c               | 2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h              | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c b/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c
index 3ab0cfe26513..19a95b69255d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c
@@ -29,7 +29,7 @@
 #include "rtl_btc.h"
 #include "halbt_precomp.h"
 
-static struct rtl_btc_ops rtl_btc_operation = {
+static const struct rtl_btc_ops rtl_btc_operation = {
 	.btc_init_variables = rtl_btc_init_variables,
 	.btc_init_hal_vars = rtl_btc_init_hal_vars,
 	.btc_init_hw_config = rtl_btc_init_hw_config,
@@ -161,7 +161,7 @@ void rtl_btc_special_packet_notify(struct rtl_priv *rtlpriv, u8 pkt_type)
 	return exhalbtc_special_packet_notify(&gl_bt_coexist, pkt_type);
 }
 
-struct rtl_btc_ops *rtl_btc_get_ops_pointer(void)
+const struct rtl_btc_ops *rtl_btc_get_ops_pointer(void)
 {
 	return &rtl_btc_operation;
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h b/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h
index fff5117e1c4e..83c5bb2d6ad8 100644
--- a/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h
+++ b/drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h
@@ -44,7 +44,7 @@ bool rtl_btc_is_disable_edca_turbo(struct rtl_priv *rtlpriv);
 bool rtl_btc_is_bt_disabled(struct rtl_priv *rtlpriv);
 void rtl_btc_special_packet_notify(struct rtl_priv *rtlpriv, u8 pkt_type);
 
-struct rtl_btc_ops *rtl_btc_get_ops_pointer(void);
+const struct rtl_btc_ops *rtl_btc_get_ops_pointer(void);
 
 u8 rtl_get_hwpg_bt_exist(struct rtl_priv *rtlpriv);
 u8 rtl_get_hwpg_bt_type(struct rtl_priv *rtlpriv);
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index fa93401acdab..8000894c4212 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -1814,7 +1814,7 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
-	struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
+	const struct rtl_btc_ops *btc_ops = rtlpriv->btcoexist.btc_ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
diff --git a/drivers/net/wireless/realtek/rtlwifi/wifi.h b/drivers/net/wireless/realtek/rtlwifi/wifi.h
index 9a916188a703..d03f0ca92530 100644
--- a/drivers/net/wireless/realtek/rtlwifi/wifi.h
+++ b/drivers/net/wireless/realtek/rtlwifi/wifi.h
@@ -2475,7 +2475,7 @@ struct rtl_btc_info {
 };
 
 struct bt_coexist_info {
-	struct rtl_btc_ops *btc_ops;
+	const struct rtl_btc_ops *btc_ops;
 	struct rtl_btc_info btc_info;
 	/* EEPROM BT info. */
 	u8 eeprom_bt_coexist;
-- 
2.10.0.rc2.1.g053435c
