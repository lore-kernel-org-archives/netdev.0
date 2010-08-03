From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH] ixgbe: ixgbe_fcoe build break
Date: Tue,  3 Aug 2010 10:57:58 -0500
Message-ID: <1280851078-4263-1-git-send-email-jon.mason@exar.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiew
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39480 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755952Ab0HCP6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 11:58:20 -0400
Received: by yxg6 with SMTP id 6so1642746yxg.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 08:58:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ixgbe_fcoe has fields that are #ifdef'ed with CONFIG_IXGBE_DCB.
However, not all references to those fields check for CONFIG_IXGBE_DCB.
This patch adds the necessary check to allow for ixgbe to compile.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7d6a415..9ec3dfe 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6155,9 +6155,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 			txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
 			txq += adapter->ring_feature[RING_F_FCOE].mask;
 			return txq;
+#ifdef CONFIG_IXGBE_DCB
 		} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			txq = adapter->fcoe.up;
 			return txq;
+#endif
 		}
 	}
 #endif
@@ -6218,8 +6220,10 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	     skb->protocol == htons(ETH_P_FIP))) {
 		tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
 			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+#ifdef CONFIG_IXGBE_DCB
 		tx_flags |= ((adapter->fcoe.up << 13)
 			      << IXGBE_TX_FLAGS_VLAN_SHIFT);
+#endif
 		/* flag for FCoE offloads */
 		if (skb->protocol == htons(ETH_P_FCOE))
 			tx_flags |= IXGBE_TX_FLAGS_FCOE;
-- 
1.7.0.4

