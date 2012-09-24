From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] ixgbevf - Remove unused parameter in ixgbevf_receive_skb
Date: Mon, 24 Sep 2012 02:00:04 -0700
Message-ID: <1348477207-27030-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13634 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970Ab2IXJAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:13 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narendra K <narendra_k@dell.com>

Remove 'rx_ring' parameter as it is not used in ixgbevf_receive_skb

Signed-off-by: Narendra K <narendra_k@dell.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 7aa31ee..cb215c6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -272,12 +272,10 @@ cont_loop:
  * @q_vector: structure containing interrupt and ring information
  * @skb: packet to send up
  * @status: hardware indication of status of receive
- * @rx_ring: rx descriptor ring (for a specific queue) to setup
  * @rx_desc: rx descriptor
  **/
 static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 				struct sk_buff *skb, u8 status,
-				struct ixgbevf_ring *ring,
 				union ixgbe_adv_rx_desc *rx_desc)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
@@ -461,7 +459,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		}
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
-		ixgbevf_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
+		ixgbevf_receive_skb(q_vector, skb, staterr, rx_desc);
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
-- 
1.7.11.4
