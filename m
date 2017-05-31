From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] ixgbe: Resolve warnings for -Wimplicit-fallthrough
Date: Wed, 31 May 2017 14:19:29 -0700
Message-ID: <20170531211936.63417-9-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:18995 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751160AbdEaVT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:56 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

This patch adds/changes fall through comments to address new warnings
produced by gcc 7.

Fixed formatting on a couple of comments in the function.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   | 9 ++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 8 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   | 7 +++----
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index c8ac46049f34..d602637ccc40 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1589,15 +1589,17 @@ s32 ixgbe_fdir_set_input_mask_82599(struct ixgbe_hw *hw,
 
 	switch (ntohs(input_mask->formatted.vlan_id) & 0xEFFF) {
 	case 0x0000:
-		/* mask VLAN ID, fall through to mask VLAN priority */
+		/* mask VLAN ID */
 		fdirm |= IXGBE_FDIRM_VLANID;
+		/* fall through */
 	case 0x0FFF:
 		/* mask VLAN priority */
 		fdirm |= IXGBE_FDIRM_VLANP;
 		break;
 	case 0xE000:
-		/* mask VLAN ID only, fall through */
+		/* mask VLAN ID only */
 		fdirm |= IXGBE_FDIRM_VLANID;
+		/* fall through */
 	case 0xEFFF:
 		/* no VLAN fields masked */
 		break;
@@ -1608,8 +1610,9 @@ s32 ixgbe_fdir_set_input_mask_82599(struct ixgbe_hw *hw,
 
 	switch (input_mask->formatted.flex_bytes & 0xFFFF) {
 	case 0x0000:
-		/* Mask Flex Bytes, fall through */
+		/* Mask Flex Bytes */
 		fdirm |= IXGBE_FDIRM_FLEX;
+		/* fall through */
 	case 0xFFFF:
 		break;
 	default:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 3af6127f0d44..76ad0e0bd542 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -155,7 +155,7 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		/* only backplane uses autoc so fall though */
+		/* fall through - only backplane uses autoc */
 	case ixgbe_media_type_fiber:
 		reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
 
@@ -3549,7 +3549,7 @@ void ixgbe_set_rxpba_generic(struct ixgbe_hw *hw,
 		rxpktsize <<= IXGBE_RXPBSIZE_SHIFT;
 		for (; i < (num_pb / 2); i++)
 			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), rxpktsize);
-		/* Fall through to configure remaining packet buffers */
+		/* fall through - configure remaining packet buffers */
 	case (PBA_STRATEGY_EQUAL):
 		/* Divide the remaining Rx packet buffer evenly among the TCs */
 		rxpktsize = (pbsize / (num_pb - i)) << IXGBE_RXPBSIZE_SHIFT;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index cced74dd5a63..9113e8099b03 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2668,6 +2668,7 @@ static int ixgbe_flowspec_to_flow_type(struct ethtool_rx_flow_spec *fsp,
 				*flow_type = IXGBE_ATR_FLOW_TYPE_IPV4;
 				break;
 			}
+			/* fall through */
 		default:
 			return 0;
 		}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0d2c54693cf3..54463f03b3db 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1452,7 +1452,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 					IXGBE_DCA_CTRL_DCA_MODE_CB2);
 			break;
 		}
-		/* Fall Through since DCA is disabled. */
+		/* fall through - DCA is disabled. */
 	case DCA_PROVIDER_REMOVE:
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 			dca_remove_requester(dev);
@@ -2233,6 +2233,7 @@ static struct sk_buff *ixgbe_run_xdp(struct ixgbe_adapter *adapter,
 		break;
 	default:
 		bpf_warn_invalid_xdp_action(act);
+		/* fallthrough */
 	case XDP_ABORTED:
 		trace_xdp_exception(rx_ring->netdev, xdp_prog, act);
 		/* fallthrough -- handle aborts by dropping packet */
@@ -4177,7 +4178,7 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_x550em_a:
 		if (adapter->num_vfs)
 			rdrxctl |= IXGBE_RDRXCTL_PSP;
-		/* fall through for older HW */
+		/* fall through */
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		/* Disable RSC for ACK packets */
@@ -6885,6 +6886,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		hwstats->o2bspc += IXGBE_READ_REG(hw, IXGBE_O2BSPC);
 		hwstats->b2ospc += IXGBE_READ_REG(hw, IXGBE_B2OSPC);
 		hwstats->b2ogprc += IXGBE_READ_REG(hw, IXGBE_B2OGPRC);
+		/* fall through */
 	case ixgbe_mac_82599EB:
 		for (i = 0; i < 16; i++)
 			adapter->hw_rx_no_dma_resources +=
@@ -8207,6 +8209,7 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 			break;
+		/* fall through */
 	default:
 		return fallback(dev, skb);
 	}
@@ -9931,6 +9934,7 @@ bool ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 			/* only support first port */
 			if (hw->bus.func != 0)
 				break;
+			/* fall through */
 		case IXGBE_SUBDEV_ID_82599_SP_560FLR:
 		case IXGBE_SUBDEV_ID_82599_SFP:
 		case IXGBE_SUBDEV_ID_82599_RNDC:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 13c96a13841e..e2766da5fe02 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -540,16 +540,15 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 		case ixgbe_mbox_api_11:
 		case ixgbe_mbox_api_12:
 		case ixgbe_mbox_api_13:
-			/*
-			 * Version 1.1 supports jumbo frames on VFs if PF has
+			/* Version 1.1 supports jumbo frames on VFs if PF has
 			 * jumbo frames enabled which means legacy VFs are
 			 * disabled
 			 */
 			if (pf_max_frame > ETH_FRAME_LEN)
 				break;
+			/* fall through */
 		default:
-			/*
-			 * If the PF or VF are running w/ jumbo frames enabled
+			/* If the PF or VF are running w/ jumbo frames enabled
 			 * we need to shut down the VF Rx path as we cannot
 			 * support jumbo frames on legacy VFs
 			 */
-- 
2.12.2
