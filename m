From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] fm10k: consistently refer to VLANs and VLAN IDs
Date: Sun, 13 Dec 2015 16:27:37 -0800
Message-ID: <1450052867-36654-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42600 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbbLNA1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:50 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Instead of using lowercase vlan, vid, or VID, always use VLAN or VLAN ID
in comments when referring to VLANs. The original driver code was
consistent, but recent patches have not been as consistent with this
naming scheme.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  8 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     | 14 +++++++-------
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index fa26e20..8595a3d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -138,7 +138,7 @@ struct fm10k_ring {
 					 * different for DCB and RSS modes
 					 */
 	u8 qos_pc;			/* priority class of queue */
-	u16 vid;			/* default vlan ID of queue */
+	u16 vid;			/* default VLAN ID of queue */
 	u16 count;			/* amount of descriptors */
 
 	u16 next_to_alloc;
@@ -440,7 +440,7 @@ union fm10k_ftag_info {
 	struct {
 		/* dglort and sglort combined into a single 32bit desc read */
 		__le32 glort;
-		/* upper 16 bits of vlan are reserved 0 for swpri_type_user */
+		/* upper 16 bits of VLAN are reserved 0 for swpri_type_user */
 		__le32 vlan;
 	} d;
 	struct {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 79f6b7d..c60b553 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -632,7 +632,7 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 			return NETDEV_TX_OK;
 		}
 
-		/* locate vlan header */
+		/* locate VLAN header */
 		vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
 
 		/* pull the 2 key pieces of data out of it */
@@ -778,7 +778,7 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (!set)
 		clear_bit(vid, interface->active_vlans);
 
-	/* disable the default VID on ring if we have an active VLAN */
+	/* disable the default VLAN ID on ring if we have an active VLAN */
 	for (i = 0; i < interface->num_rx_queues; i++) {
 		struct fm10k_ring *rx_ring = interface->rx_ring[i];
 		u16 rx_vid = rx_ring->vid & (VLAN_N_VID - 1);
@@ -789,7 +789,7 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 			rx_ring->vid &= ~FM10K_VLAN_CLEAR;
 	}
 
-	/* Do not remove default VID related entries from VLAN and MAC tables */
+	/* Do not remove default VLAN ID related entries from VLAN and MAC tables */
 	if (!set && vid == hw->mac.default_vid)
 		return 0;
 
@@ -814,7 +814,7 @@ static int fm10k_update_vid(struct net_device *netdev, u16 vid, bool set)
 	if (err)
 		goto err_out;
 
-	/* set vid prior to syncing/unsyncing the VLAN */
+	/* set VLAN ID prior to syncing/unsyncing the VLAN */
 	interface->vid = vid + (set ? VLAN_N_VID : 0);
 
 	/* Update the unicast and multicast address list to add/drop VLAN */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 644b0c1..b9ed94a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -715,7 +715,7 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 	/* assign default VLAN to queue */
 	ring->vid = hw->mac.default_vid;
 
-	/* if we have an active VLAN, disable default VID */
+	/* if we have an active VLAN, disable default VLAN ID */
 	if (test_bit(hw->mac.default_vid, interface->active_vlans))
 		ring->vid |= FM10K_VLAN_CLEAR;
 
@@ -1292,7 +1292,7 @@ static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
 	if (!fm10k_glort_valid_pf(hw, glort))
 		return FM10K_ERR_PARAM;
 
-	/* verify VID is valid */
+	/* verify VLAN ID is valid */
 	if (pvid >= FM10K_VLAN_TABLE_VID_MAX)
 		return FM10K_ERR_PARAM;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 5bb6185..ad6381c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -329,7 +329,7 @@ static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
 	/* clear set bit from VLAN ID */
 	vid &= ~FM10K_VLAN_CLEAR;
 
-	/* if glort or vlan are not valid return error */
+	/* if glort or VLAN are not valid return error */
 	if (!fm10k_glort_valid_pf(hw, glort) || vid >= FM10K_VLAN_TABLE_VID_MAX)
 		return FM10K_ERR_PARAM;
 
@@ -921,7 +921,7 @@ err_out:
 	txqctl |= (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
 		  FM10K_TXQCTL_VF | vf_idx;
 
-	/* assign VID */
+	/* assign VLAN ID */
 	for (i = 0; i < queues_per_pool; i++)
 		fm10k_write_reg(hw, FM10K_TXQCTL(vf_q_idx + i), txqctl);
 
@@ -1172,12 +1172,12 @@ s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *hw, u32 **results,
 }
 
 /**
- * fm10k_iov_select_vid - Select correct default VID
+ * fm10k_iov_select_vid - Select correct default VLAN ID
  * @hw: Pointer to hardware structure
- * @vid: VID to correct
+ * @vid: VLAN ID to correct
  *
- * Will report an error if VID is out of range. For VID = 0, it will return
- * either the pf_vid or sw_vid depending on which one is set.
+ * Will report an error if the VLAN ID is out of range. For VID = 0, it will
+ * return either the pf_vid or sw_vid depending on which one is set.
  */
 static inline s32 fm10k_iov_select_vid(struct fm10k_vf_info *vf_info, u16 vid)
 {
@@ -1707,7 +1707,7 @@ s32 fm10k_msg_update_pvid_pf(struct fm10k_hw *hw, u32 **results,
 	if (!fm10k_glort_valid_pf(hw, glort))
 		return FM10K_ERR_PARAM;
 
-	/* verify VID is valid */
+	/* verify VLAN ID is valid */
 	if (pvid >= FM10K_VLAN_TABLE_VID_MAX)
 		return FM10K_ERR_PARAM;
 
-- 
2.5.0
