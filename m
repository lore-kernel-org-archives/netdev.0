From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] igb: Cleanups for messaging
Date: Wed, 23 Apr 2014 04:15:23 -0700
Message-ID: <1398251726-13638-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398AbaDWLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:38 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes WARNING:PREFER_PR_LEVEL and WARNING:SPLIT_STRING
from checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |  8 +++----
 drivers/net/ethernet/intel/igb/e1000_mac.c   |  6 ++---
 drivers/net/ethernet/intel/igb/e1000_phy.c   |  3 +--
 drivers/net/ethernet/intel/igb/igb_main.c    | 34 ++++++++++------------------
 4 files changed, 18 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index fa36fe1..7b7d08c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1676,7 +1676,7 @@ static s32 igb_setup_serdes_link_82575(struct e1000_hw *hw)
 		    hw->mac.type == e1000_82576) {
 			ret_val = hw->nvm.ops.read(hw, NVM_COMPAT, 1, &data);
 			if (ret_val) {
-				printk(KERN_DEBUG "NVM Read Error\n\n");
+				hw_dbg(KERN_DEBUG "NVM Read Error\n\n");
 				return ret_val;
 			}
 
@@ -2436,8 +2436,7 @@ static s32 igb_update_nvm_checksum_82580(struct e1000_hw *hw)
 
 	ret_val = hw->nvm.ops.read(hw, NVM_COMPATIBILITY_REG_3, 1, &nvm_data);
 	if (ret_val) {
-		hw_dbg("NVM Read Error while updating checksum"
-			" compatibility bit.\n");
+		hw_dbg("NVM Read Error while updating checksum compatibility bit.\n");
 		goto out;
 	}
 
@@ -2447,8 +2446,7 @@ static s32 igb_update_nvm_checksum_82580(struct e1000_hw *hw)
 		ret_val = hw->nvm.ops.write(hw, NVM_COMPATIBILITY_REG_3, 1,
 					&nvm_data);
 		if (ret_val) {
-			hw_dbg("NVM Write Error while updating checksum"
-				" compatibility bit.\n");
+			hw_dbg("NVM Write Error while updating checksum compatibility bit.\n");
 			goto out;
 		}
 	}
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 5910a93..fc2c76e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -866,8 +866,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 			goto out;
 
 		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
-			hw_dbg("Copper PHY and Auto Neg "
-				 "has not completed.\n");
+			hw_dbg("Copper PHY and Auto Neg has not completed.\n");
 			goto out;
 		}
 
@@ -932,8 +931,7 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 				hw_dbg("Flow Control = FULL.\r\n");
 			} else {
 				hw->fc.current_mode = e1000_fc_rx_pause;
-				hw_dbg("Flow Control = "
-				       "RX PAUSE frames only.\r\n");
+				hw_dbg("Flow Control = RX PAUSE frames only.\r\n");
 			}
 		}
 		/* For receiving PAUSE frames ONLY.
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 4009bba..ec7dc6c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -924,8 +924,7 @@ static s32 igb_copper_link_autoneg(struct e1000_hw *hw)
 	if (phy->autoneg_wait_to_complete) {
 		ret_val = igb_wait_autoneg(hw);
 		if (ret_val) {
-			hw_dbg("Error while waiting for "
-			       "autoneg to complete\n");
+			hw_dbg("Error while waiting for autoneg to complete\n");
 			goto out;
 		}
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fb98d46..13edca9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -217,8 +217,7 @@ static void igb_netpoll(struct net_device *);
 #ifdef CONFIG_PCI_IOV
 static unsigned int max_vfs = 0;
 module_param(max_vfs, uint, 0);
-MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
-                 "per physical function");
+MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate per physical function");
 #endif /* CONFIG_PCI_IOV */
 
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
@@ -384,8 +383,7 @@ static void igb_dump(struct igb_adapter *adapter)
 	/* Print netdevice Info */
 	if (netdev) {
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
-		pr_info("Device Name     state            trans_start      "
-			"last_rx\n");
+		pr_info("Device Name     state            trans_start      last_rx\n");
 		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
 			netdev->state, netdev->trans_start, netdev->last_rx);
 	}
@@ -438,9 +436,7 @@ static void igb_dump(struct igb_adapter *adapter)
 		pr_info("------------------------------------\n");
 		pr_info("TX QUEUE INDEX = %d\n", tx_ring->queue_index);
 		pr_info("------------------------------------\n");
-		pr_info("T [desc]     [address 63:0  ] [PlPOCIStDDM Ln] "
-			"[bi->dma       ] leng  ntw timestamp        "
-			"bi->skb\n");
+		pr_info("T [desc]     [address 63:0  ] [PlPOCIStDDM Ln] [bi->dma       ] leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
 			const char *next_desc;
@@ -458,9 +454,8 @@ static void igb_dump(struct igb_adapter *adapter)
 			else
 				next_desc = "";
 
-			pr_info("T [0x%03X]    %016llX %016llX %016llX"
-				" %04X  %p %016llX %p%s\n", i,
-				le64_to_cpu(u0->a),
+			pr_info("T [0x%03X]    %016llX %016llX %016llX %04X  %p %016llX %p%s\n",
+				i, le64_to_cpu(u0->a),
 				le64_to_cpu(u0->b),
 				(u64)dma_unmap_addr(buffer_info, dma),
 				dma_unmap_len(buffer_info, len),
@@ -519,10 +514,8 @@ rx_ring_summary:
 		pr_info("------------------------------------\n");
 		pr_info("RX QUEUE INDEX = %d\n", rx_ring->queue_index);
 		pr_info("------------------------------------\n");
-		pr_info("R  [desc]      [ PktBuf     A0] [  HeadBuf   DD] "
-			"[bi->dma       ] [bi->skb] <-- Adv Rx Read format\n");
-		pr_info("RWB[desc]      [PcsmIpSHl PtRs] [vl er S cks ln] -----"
-			"----------- [bi->skb] <-- Adv Rx Write-Back format\n");
+		pr_info("R  [desc]      [ PktBuf     A0] [  HeadBuf   DD] [bi->dma       ] [bi->skb] <-- Adv Rx Read format\n");
+		pr_info("RWB[desc]      [PcsmIpSHl PtRs] [vl er S cks ln] ---------------- [bi->skb] <-- Adv Rx Write-Back format\n");
 
 		for (i = 0; i < rx_ring->count; i++) {
 			const char *next_desc;
@@ -4215,8 +4208,8 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			ctrl = rd32(E1000_CTRL);
 			/* Links status message must follow this format */
-			printk(KERN_INFO "igb: %s NIC Link is Up %d Mbps %s "
-			       "Duplex, Flow Control: %s\n",
+			netdev_info(netdev,
+			       "igb: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
 			       netdev->name,
 			       adapter->link_speed,
 			       adapter->link_duplex == FULL_DUPLEX ?
@@ -4243,9 +4236,7 @@ static void igb_watchdog_task(struct work_struct *work)
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
 			    E1000_THSTAT_LINK_THROTTLE)) {
-				netdev_info(netdev, "The network adapter link "
-					    "speed was downshifted because it "
-					    "overheated\n");
+				netdev_info(netdev, "The network adapter link speed was downshifted because it overheated\n");
 			}
 
 			/* adjust timeout factor according to speed/duplex */
@@ -4277,12 +4268,11 @@ static void igb_watchdog_task(struct work_struct *work)
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
 			    E1000_THSTAT_PWR_DOWN)) {
-				netdev_err(netdev, "The network adapter was "
-					   "stopped because it overheated\n");
+				netdev_err(netdev, "The network adapter was stopped because it overheated\n");
 			}
 
 			/* Links status message must follow this format */
-			printk(KERN_INFO "igb: %s NIC Link is Down\n",
+			netdev_info(netdev, "igb: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
 
-- 
1.9.0
