From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0733/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:59 +0800
Message-ID: <20160802114059.30924-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38465 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934396AbcHBMSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:18:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/sfc/efx.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 097f363..42e03431 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -116,7 +116,7 @@ static struct workqueue_struct *reset_workqueue;
  * This is only used in MSI-X interrupt mode
  */
 bool efx_separate_tx_channels;
-module_param(efx_separate_tx_channels, bool, 0444);
+module_param(efx_separate_tx_channels, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(efx_separate_tx_channels,
 		 "Use separate channels for TX and RX");
 
@@ -169,20 +169,20 @@ static unsigned int interrupt_mode;
  * The default (0) means to assign an interrupt to each core.
  */
 static unsigned int rss_cpus;
-module_param(rss_cpus, uint, 0444);
+module_param(rss_cpus, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling");
 
 static bool phy_flash_cfg;
-module_param(phy_flash_cfg, bool, 0644);
+module_param(phy_flash_cfg, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
 
 static unsigned irq_adapt_low_thresh = 8000;
-module_param(irq_adapt_low_thresh, uint, 0644);
+module_param(irq_adapt_low_thresh, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(irq_adapt_low_thresh,
 		 "Threshold score for reducing IRQ moderation");
 
 static unsigned irq_adapt_high_thresh = 16000;
-module_param(irq_adapt_high_thresh, uint, 0644);
+module_param(irq_adapt_high_thresh, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(irq_adapt_high_thresh,
 		 "Threshold score for increasing IRQ moderation");
 
@@ -2381,7 +2381,7 @@ show_phy_type(struct device *dev, struct device_attribute *attr, char *buf)
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 	return sprintf(buf, "%d\n", efx->phy_type);
 }
-static DEVICE_ATTR(phy_type, 0444, show_phy_type, NULL);
+static DEVICE_ATTR(phy_type, S_IRUSR | S_IRGRP | S_IROTH, show_phy_type, NULL);
 
 #ifdef CONFIG_SFC_MCDI_LOGGING
 static ssize_t show_mcdi_log(struct device *dev, struct device_attribute *attr,
@@ -2402,7 +2402,7 @@ static ssize_t set_mcdi_log(struct device *dev, struct device_attribute *attr,
 	mcdi->logging_enabled = enable;
 	return count;
 }
-static DEVICE_ATTR(mcdi_logging, 0644, show_mcdi_log, set_mcdi_log);
+static DEVICE_ATTR(mcdi_logging, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, show_mcdi_log, set_mcdi_log);
 #endif
 
 static int efx_register_netdev(struct efx_nic *efx)
@@ -3474,7 +3474,7 @@ static struct pci_driver efx_pci_driver = {
  *
  *************************************************************************/
 
-module_param(interrupt_mode, uint, 0444);
+module_param(interrupt_mode, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(interrupt_mode,
 		 "Interrupt mode (0=>MSIX 1=>MSI 2=>legacy)");
 
-- 
2.9.2
