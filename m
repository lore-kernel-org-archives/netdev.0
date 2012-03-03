From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: Minor formatting and comment corrections for ixgbe_xmit_frame_ring
Date: Fri,  2 Mar 2012 18:24:25 -0800
Message-ID: <1330741468-23900-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238Ab2CCCYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:37 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to address several minor issues in
ixgbe_xmit_frame_ring.  Specifically it adds a comment explaining the TXSW
flag, and correctly wraps a line over 80 characters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4e55860..1cf676b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7012,11 +7012,6 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-#ifdef CONFIG_PCI_IOV
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		tx_flags |= IXGBE_TX_FLAGS_TXSW;
-
-#endif
 	/* if we have a HW VLAN tag being added default to the HW one */
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT;
@@ -7029,10 +7024,20 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			goto out_drop;
 
 		protocol = vhdr->h_vlan_encapsulated_proto;
-		tx_flags |= ntohs(vhdr->h_vlan_TCI) << IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= ntohs(vhdr->h_vlan_TCI) <<
+				  IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
 	}
 
+#ifdef CONFIG_PCI_IOV
+	/*
+	 * Use the l2switch_enable flag - would be false if the DMA
+	 * Tx switch had been disabled.
+	 */
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		tx_flags |= IXGBE_TX_FLAGS_TXSW;
+
+#endif
 	/* DCB maps skb priorities 0-7 onto 3 bit PCP of VLAN tag. */
 	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
 	    ((tx_flags & (IXGBE_TX_FLAGS_HW_VLAN | IXGBE_TX_FLAGS_SW_VLAN)) ||
-- 
1.7.7.6
