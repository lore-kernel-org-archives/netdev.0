From: Adam Lee <adam.lee@canonical.com>
Subject: [PATCH 2/3] rtlwifi: rtl8188ee: add msi module parameter
Date: Mon,  5 May 2014 16:33:37 +0800
Message-ID: <1399278818-19152-2-git-send-email-adam.lee@canonical.com>
References: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:52534 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbaEEId4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 04:33:56 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so3728681pab.17
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 01:33:56 -0700 (PDT)
In-Reply-To: <1399278818-19152-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The msi module parameter offers an option to enable or disable MSI
interrupts mode. For now, some users report RTL8188EE works only with
MSI on their certain platforms, some others report it works only without
MSI, this parameter will help.

Signed-off-by: Adam Lee <adam.lee@canonical.com>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 347af1e..79792d4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -93,6 +93,7 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	u8 tid;
 
 	rtl8188ee_bt_reg_init(hw);
+	rtlpci->msi_support = rtlpriv->cfg->mod_params->msi_support;
 
 	rtlpriv->dm.dm_initialgain_enable = 1;
 	rtlpriv->dm.dm_flag = 0;
@@ -266,6 +267,7 @@ static struct rtl_mod_params rtl88ee_mod_params = {
 	.inactiveps = true,
 	.swctrl_lps = false,
 	.fwctrl_lps = true,
+	.msi_support = false,
 	.debug = DBG_EMERG,
 };
 
@@ -382,10 +384,12 @@ module_param_named(debug, rtl88ee_mod_params.debug, int, 0444);
 module_param_named(ips, rtl88ee_mod_params.inactiveps, bool, 0444);
 module_param_named(swlps, rtl88ee_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl88ee_mod_params.fwctrl_lps, bool, 0444);
+module_param_named(msi, rtl88ee_mod_params.msi_support, bool, 0444);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
 MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
 MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 0)\n");
 MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (default 1)\n");
+MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
-- 
2.0.0.rc0
