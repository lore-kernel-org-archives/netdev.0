From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 3/3] rtlwifi: rtl8723be: add msi module parameter
Date: Mon,  5 May 2014 16:33:38 +0800
Message-ID: <1399278818-19152-3-git-send-email-adam.lee@canonical.com>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399278818-19152-1-git-send-email-adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The msi module parameter offers an option to enable or disable MSI
interrupts mode, for debugging and workaround(in case) convenience.

Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index a072136..ff12bf4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -92,7 +92,7 @@ int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	rtl8723be_bt_reg_init(hw);
-	rtlpci->msi_support = false;
+	rtlpci->msi_support = rtlpriv->cfg->mod_params->msi_support;
 	rtlpriv->btcoexist.btc_ops = rtl_btc_get_ops_pointer();
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
@@ -253,6 +253,7 @@ static struct rtl_mod_params rtl8723be_mod_params = {
 	.inactiveps = true,
 	.swctrl_lps = false,
 	.fwctrl_lps = true,
+	.msi_support = false,
 	.debug = DBG_EMERG,
 };
 
@@ -365,9 +366,11 @@ module_param_named(debug, rtl8723be_mod_params.debug, int, 0444);
 module_param_named(ips, rtl8723be_mod_params.inactiveps, bool, 0444);
 module_param_named(swlps, rtl8723be_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
+module_param_named(msi, rtl8723be_mod_params.msi_support, bool, 0444);
 MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
 MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
 MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
+MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
-- 
2.0.0.rc0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
