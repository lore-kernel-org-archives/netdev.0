From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/2] qlcnic: fix type of module parameters
Date: Mon, 21 Feb 2011 03:58:33 -0800
Message-ID: <1298289514-15671-2-git-send-email-amit.salecha@qlogic.com>
References: <1298289514-15671-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22885 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755504Ab1BUL6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 06:58:38 -0500
In-Reply-To: <1298289514-15671-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Module parameters auto_fw_reset, use_msi, use_msi_x, qlcnic_mac_learn,
  and load_fw_file should be of type bool not int.
o All module parameters should have qlcnic prefix.
o Remove unnecessary macro for value "1".

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_main.c |   46 +++++++++++++++++++-------------------
 2 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 44e316f..fa7f794 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -867,7 +867,6 @@ struct qlcnic_nic_intr_coalesce {
 #define LINKEVENT_LINKSPEED_MBPS	0
 #define LINKEVENT_LINKSPEED_ENCODED	1
 
-#define AUTO_FW_RESET_ENABLED	0x01
 /* firmware response header:
  *	63:58 - message type
  *	57:56 - owner
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 37c04b4..3fd878c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -30,25 +30,26 @@ static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
 static struct workqueue_struct *qlcnic_wq;
-static int qlcnic_mac_learn;
-module_param(qlcnic_mac_learn, int, 0444);
+static bool qlcnic_mac_learn;
+module_param(qlcnic_mac_learn, bool, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
 
-static int use_msi = 1;
-module_param(use_msi, int, 0444);
-MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
+static bool qlcnic_use_msi = 1;
+module_param(qlcnic_use_msi, bool, 0444);
+MODULE_PARM_DESC(qlcnic_use_msi, "MSI interrupt (0=disabled, 1=enabled");
 
-static int use_msi_x = 1;
-module_param(use_msi_x, int, 0444);
-MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
+static bool qlcnic_use_msi_x = 1;
+module_param(qlcnic_use_msi_x, bool, 0444);
+MODULE_PARM_DESC(qlcnic_use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
 
-static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
-module_param(auto_fw_reset, int, 0644);
-MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
+static bool qlcnic_auto_fw_reset = 1;
+module_param(qlcnic_auto_fw_reset, bool, 0644);
+MODULE_PARM_DESC(qlcnic_auto_fw_reset,
+		 "Auto firmware reset (0=disabled, 1=enabled");
 
-static int load_fw_file;
-module_param(load_fw_file, int, 0444);
-MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
+static bool qlcnic_load_fw_file;
+module_param(qlcnic_load_fw_file, bool, 0444);
+MODULE_PARM_DESC(qlcnic_load_fw_file, "Load firmware from (0=flash, 1=file");
 
 static int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
@@ -404,7 +405,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 		/* fall through for msi */
 	}
 
-	if (use_msi && !pci_enable_msi(pdev)) {
+	if (qlcnic_use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= QLCNIC_MSI_ENABLED;
 		adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
 				msi_tgt_status[adapter->ahw.pci_func]);
@@ -658,8 +659,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
 	}
 
-	adapter->msix_supported = !!use_msi_x;
-	adapter->rss_supported = !!use_msi_x;
+	adapter->msix_supported = qlcnic_use_msi_x;
+	adapter->rss_supported = qlcnic_use_msi_x;
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
@@ -972,7 +973,7 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 	else if (!err)
 		goto check_fw_status;
 
-	if (load_fw_file)
+	if (qlcnic_load_fw_file)
 		qlcnic_request_firmware(adapter);
 	else {
 		err = qlcnic_check_flash_fw_ver(adapter);
@@ -2959,8 +2960,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		if (adapter->need_fw_reset)
 			goto detach;
 
-		if (adapter->reset_context &&
-		    auto_fw_reset == AUTO_FW_RESET_ENABLED) {
+		if (adapter->reset_context && qlcnic_auto_fw_reset) {
 			qlcnic_reset_hw_context(adapter);
 			adapter->netdev->trans_start = jiffies;
 		}
@@ -2973,7 +2973,7 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_request_reset(adapter);
 
-	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED))
+	if (qlcnic_auto_fw_reset)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_info(&netdev->dev, "firmware hang detected\n");
@@ -2982,8 +2982,8 @@ detach:
 	adapter->dev_state = (state == QLCNIC_DEV_NEED_QUISCENT) ? state :
 		QLCNIC_DEV_NEED_RESET;
 
-	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED) &&
-		!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
+	if (qlcnic_auto_fw_reset &&
+	    !test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
 
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
 		QLCDB(adapter, DRV, "fw recovery scheduled.\n");
-- 
1.7.3.2

