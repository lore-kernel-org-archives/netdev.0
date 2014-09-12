From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/8] be2net: fix some log messages
Date: Fri, 12 Sep 2014 17:39:14 +0530
Message-ID: <1410523761-1744-2-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:24676 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbaILMGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:49 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

This patch fixes the following minor issues with log messages in be2net:
  1) Period is not required at the end of log message.
  2) Remove "Unknown grp5 event" logs to reduce noise. The driver can safely
     ignore async events from FW it's not interested in.
  3) Reword a log message for better readability to say that SRIOV
     "is disabled" rather than "not supported".

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    2 --
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    |   17 ++++++++---------
 3 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5be100d..d6685ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -309,8 +309,6 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 		be_async_grp5_pvid_state_process(adapter, compl);
 		break;
 	default:
-		dev_warn(&adapter->pdev->dev, "Unknown grp5 event 0x%x!\n",
-			 event_type);
 		break;
 	}
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 2fd3826..ee565be 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -676,7 +676,7 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	status = be_cmd_set_flow_control(adapter,
 					 adapter->tx_fc, adapter->rx_fc);
 	if (status)
-		dev_warn(&adapter->pdev->dev, "Pause param set failed.\n");
+		dev_warn(&adapter->pdev->dev, "Pause param set failed\n");
 
 	return be_cmd_status(status);
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5b26c4c..f059b62 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1093,6 +1093,7 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
  */
 static int be_vid_config(struct be_adapter *adapter)
 {
+	struct device *dev = &adapter->pdev->dev;
 	u16 vids[BE_NUM_VLANS_SUPPORTED];
 	u16 num = 0, i = 0;
 	int status = 0;
@@ -1114,16 +1115,15 @@ static int be_vid_config(struct be_adapter *adapter)
 		if (addl_status(status) ==
 				MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
 			goto set_vlan_promisc;
-		dev_err(&adapter->pdev->dev,
-			"Setting HW VLAN filtering failed.\n");
+		dev_err(dev, "Setting HW VLAN filtering failed\n");
 	} else {
 		if (adapter->flags & BE_FLAGS_VLAN_PROMISC) {
 			/* hw VLAN filtering re-enabled. */
 			status = be_cmd_rx_filter(adapter,
 						  BE_FLAGS_VLAN_PROMISC, OFF);
 			if (!status) {
-				dev_info(&adapter->pdev->dev,
-					 "Disabling VLAN Promiscuous mode.\n");
+				dev_info(dev,
+					 "Disabling VLAN Promiscuous mode\n");
 				adapter->flags &= ~BE_FLAGS_VLAN_PROMISC;
 			}
 		}
@@ -1137,11 +1137,10 @@ set_vlan_promisc:
 
 	status = be_cmd_rx_filter(adapter, BE_FLAGS_VLAN_PROMISC, ON);
 	if (!status) {
-		dev_info(&adapter->pdev->dev, "Enable VLAN Promiscuous mode\n");
+		dev_info(dev, "Enable VLAN Promiscuous mode\n");
 		adapter->flags |= BE_FLAGS_VLAN_PROMISC;
 	} else
-		dev_err(&adapter->pdev->dev,
-			"Failed to enable VLAN Promiscuous mode.\n");
+		dev_err(dev, "Failed to enable VLAN Promiscuous mode\n");
 	return status;
 }
 
@@ -3387,7 +3386,7 @@ static int be_get_sriov_config(struct be_adapter *adapter)
 
 	if (!be_max_vfs(adapter)) {
 		if (num_vfs)
-			dev_warn(dev, "device doesn't support SRIOV\n");
+			dev_warn(dev, "SRIOV is disabled. Ignoring num_vfs\n");
 		adapter->num_vfs = 0;
 		return 0;
 	}
@@ -3661,7 +3660,7 @@ static int be_setup(struct be_adapter *adapter)
 	dev_info(dev, "FW version is %s\n", adapter->fw_ver);
 
 	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
-		dev_err(dev, "Firmware on card is old(%s), IRQs may not work.",
+		dev_err(dev, "Firmware on card is old(%s), IRQs may not work",
 			adapter->fw_ver);
 		dev_err(dev, "Please upgrade firmware to version >= 4.0\n");
 	}
-- 
1.7.1
