From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: Always tag VLAN tagged packets
Date: Mon, 29 Aug 2011 01:41:00 -0700
Message-ID: <1314607268-26958-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab1H2IlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:14 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to fix the patch:
	ixgbe: Cleanup FCOE and VLAN handling in xmit_frame_ring
And can be rolled into it if needed.

What this fixes is that VLAN tagged packets were not being tagged if they
were prio 7 which matches up with TC_PRIO_CONTROL.  In order to fix it I am
just setting things up so that we always tag VLAN tagged packets.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d587967..f095a3b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6762,7 +6762,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	}
 
 	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-	    skb->priority != TC_PRIO_CONTROL) {
+	    ((tx_flags & (IXGBE_TX_FLAGS_HW_VLAN | IXGBE_TX_FLAGS_SW_VLAN)) ||
+	     (skb->priority != TC_PRIO_CONTROL))) {
 		tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
 		tx_flags |= tx_ring->dcb_tc <<
 			    IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT;
-- 
1.7.6
