From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] ixgbe: Correcting small packet padding
Date: Fri, 19 Oct 2012 23:26:03 -0700
Message-ID: <1350714367-24208-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab2JTG0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:40 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

Driver pad skb up to 17 bytes because of the HW requirement. However, that code
implementation mess up the skb tail pointer after padding. This patch sets
skb->tail correctly.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 46bf0fd..c1ce6e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6538,6 +6538,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		if (skb_pad(skb, 17 - skb->len))
 			return NETDEV_TX_OK;
 		skb->len = 17;
+		skb_set_tail_pointer(skb, 17);
 	}
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
-- 
1.7.11.7
