From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 7/7] qlcnic: rename module params with module_param_named
Date: Tue,  4 Dec 2012 08:33:58 -0500
Message-ID: <1354628038-2234-8-git-send-email-sony.chacko@qlogic.com>
References: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:32277 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753315Ab2LDNwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 08:52:42 -0500
In-Reply-To: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Add qlcnic prefix to qlcnic driver module parameters.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   32 +++++++++++-----------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d94d3e9..8b566c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -34,21 +34,21 @@ static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
 
-static int use_msi = 1;
-module_param(use_msi, int, 0444);
+static int qlcnic_use_msi = 1;
 MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
+module_param_named(use_msi, qlcnic_use_msi, int, 0444);
 
-static int use_msi_x = 1;
-module_param(use_msi_x, int, 0444);
+static int qlcnic_use_msi_x = 1;
 MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
+module_param_named(use_msi_x, qlcnic_use_msi_x, int, 0444);
 
-static int auto_fw_reset = 1;
-module_param(auto_fw_reset, int, 0644);
+static int qlcnic_auto_fw_reset = 1;
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
+module_param_named(auto_fw_reset, qlcnic_auto_fw_reset, int, 0644);
 
-static int load_fw_file;
-module_param(load_fw_file, int, 0444);
+static int qlcnic_load_fw_file;
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
+module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
 
 static int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
@@ -317,7 +317,7 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct pci_dev *pdev = adapter->pdev;
 
-	if (use_msi && !pci_enable_msi(pdev)) {
+	if (qlcnic_use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= QLCNIC_MSI_ENABLED;
 		offset = msi_tgt_status[adapter->ahw->pci_func];
 		adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter->ahw,
@@ -631,7 +631,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
 	}
 
-	adapter->ahw->msix_supported = !!use_msi_x;
+	adapter->ahw->msix_supported = !!qlcnic_use_msi_x;
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
@@ -961,7 +961,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	else if (!err)
 		goto check_fw_status;
 
-	if (load_fw_file)
+	if (qlcnic_load_fw_file)
 		qlcnic_request_firmware(adapter);
 	else {
 		err = qlcnic_check_flash_fw_ver(adapter);
@@ -2558,7 +2558,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->ahw->reset_context && auto_fw_reset) {
+		if (adapter->ahw->reset_context && qlcnic_auto_fw_reset) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2573,7 +2573,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_request_reset(adapter);
 
-	if (auto_fw_reset)
+	if (qlcnic_auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_err(&adapter->pdev->dev, "firmware hang detected\n");
@@ -2598,8 +2598,8 @@ detach:
 	adapter->dev_state = (state == QLCNIC_DEV_NEED_QUISCENT) ? state :
 		QLCNIC_DEV_NEED_RESET;
 
-	if (auto_fw_reset &&
-		!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
+	if (qlcnic_auto_fw_reset && !test_and_set_bit(__QLCNIC_RESETTING,
+						      &adapter->state)) {
 
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
 		QLCDB(adapter, DRV, "fw recovery scheduled.\n");
@@ -2784,7 +2784,7 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 
 int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
 {
-	if (!use_msi_x && !use_msi) {
+	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
 		netdev_info(netdev, "no msix or msi support, hence no rss\n");
 		return -EINVAL;
 	}
-- 
1.7.1
