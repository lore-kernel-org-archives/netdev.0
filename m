From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] rtlwifi: rtl818x: constify rtl_intf_ops structures
Date: Sun,  1 May 2016 21:57:44 +0200
Message-ID: <1462132664-1619-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rtl_intf_ops structures are never modified, so declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/realtek/rtlwifi/pci.c  |    2 +-
 drivers/net/wireless/realtek/rtlwifi/pci.h  |    2 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c  |    2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index 1ac41b8..66030ea 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -2456,7 +2456,7 @@ int rtl_pci_resume(struct device *dev)
 EXPORT_SYMBOL(rtl_pci_resume);
 #endif /* CONFIG_PM_SLEEP */
 
-struct rtl_intf_ops rtl_pci_ops = {
+const struct rtl_intf_ops rtl_pci_ops = {
 	.read_efuse_byte = read_efuse_byte,
 	.adapter_start = rtl_pci_start,
 	.adapter_stop = rtl_pci_stop,
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.h b/drivers/net/wireless/realtek/rtlwifi/pci.h
index 5da6703..b951eba 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.h
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.h
@@ -286,7 +286,7 @@ struct rtl_pci_priv {
 
 int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw);
 
-extern struct rtl_intf_ops rtl_pci_ops;
+extern const struct rtl_intf_ops rtl_pci_ops;
 
 int rtl_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id);
diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
index aac1ed3..41617b7 100644
--- a/drivers/net/wireless/realtek/rtlwifi/usb.c
+++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
@@ -1049,7 +1049,7 @@ static void rtl_fill_h2c_cmd_work_callback(struct work_struct *work)
 	rtlpriv->cfg->ops->fill_h2c_cmd(hw, H2C_RA_MASK, 5, rtlpriv->rate_mask);
 }
 
-static struct rtl_intf_ops rtl_usb_ops = {
+static const struct rtl_intf_ops rtl_usb_ops = {
 	.adapter_start = rtl_usb_start,
 	.adapter_stop = rtl_usb_stop,
 	.adapter_tx = rtl_usb_tx,
diff --git a/drivers/net/wireless/realtek/rtlwifi/wifi.h b/drivers/net/wireless/realtek/rtlwifi/wifi.h
index 11d9c23..4e0ab4d 100644
--- a/drivers/net/wireless/realtek/rtlwifi/wifi.h
+++ b/drivers/net/wireless/realtek/rtlwifi/wifi.h
@@ -2593,7 +2593,7 @@ struct rtl_priv {
 	 *intf_ops : for diff interrface usb/pcie
 	 */
 	struct rtl_hal_cfg *cfg;
-	struct rtl_intf_ops *intf_ops;
+	const struct rtl_intf_ops *intf_ops;
 
 	/*this var will be set by set_bit,
 	   and was used to indicate status of

