From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] igb: Cleanups to fix missing break in switch statements
Date: Thu, 24 Apr 2014 03:30:52 -0700
Message-ID: <1398335460-4283-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43751 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755076AbaDXKbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 06:31:07 -0400
In-Reply-To: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes WARNING:MISSING_BREAK found with checkpatch check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c  | 1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++++
 drivers/net/ethernet/intel/igb/igb_main.c    | 4 ++++
 3 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 93494cb..f8bc2ec 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -432,6 +432,7 @@ static s32 igb_read_invm_i210(struct e1000_hw *hw, u16 offset,
 			*data = ID_LED_RESERVED_FFFF;
 			ret_val = E1000_SUCCESS;
 		}
+		break;
 	case NVM_SUB_DEV_ID:
 		*data = hw->subsystem_device_id;
 		break;
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 794d66b..561df67 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2412,9 +2412,11 @@ static int igb_get_rss_hash_opts(struct igb_adapter *adapter,
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
 		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* Fall through */
 	case UDP_V4_FLOW:
 		if (adapter->flags & IGB_FLAG_RSS_FIELD_IPV4_UDP)
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* Fall through */
 	case SCTP_V4_FLOW:
 	case AH_ESP_V4_FLOW:
 	case AH_V4_FLOW:
@@ -2424,9 +2426,11 @@ static int igb_get_rss_hash_opts(struct igb_adapter *adapter,
 		break;
 	case TCP_V6_FLOW:
 		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* Fall through */
 	case UDP_V6_FLOW:
 		if (adapter->flags & IGB_FLAG_RSS_FIELD_IPV6_UDP)
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* Fall through */
 	case SCTP_V6_FLOW:
 	case AH_ESP_V6_FLOW:
 	case AH_V6_FLOW:
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 967a9df..6b1b93a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -726,12 +726,14 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 				adapter->rx_ring[i]->reg_idx = rbase_offset +
 							       Q_IDX_82576(i);
 		}
+		/* Fall through */
 	case e1000_82575:
 	case e1000_82580:
 	case e1000_i350:
 	case e1000_i354:
 	case e1000_i210:
 	case e1000_i211:
+		/* Fall through */
 	default:
 		for (; i < adapter->num_rx_queues; i++)
 			adapter->rx_ring[i]->reg_idx = rbase_offset + i;
@@ -7956,11 +7958,13 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 		reg = rd32(E1000_DTXCTL);
 		reg |= E1000_DTXCTL_VLAN_ADDED;
 		wr32(E1000_DTXCTL, reg);
+		/* Fall through */
 	case e1000_82580:
 		/* enable replication vlan tag stripping */
 		reg = rd32(E1000_RPLOLR);
 		reg |= E1000_RPLOLR_STRVLAN;
 		wr32(E1000_RPLOLR, reg);
+		/* Fall through */
 	case e1000_i350:
 		/* none of the above registers are supported by i350 */
 		break;
-- 
1.9.0
