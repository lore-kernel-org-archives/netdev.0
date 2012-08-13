From: <Narendra_K@Dell.com>
Subject: [PATCH] ixgbevf - Remove unused parameter in ixgbevf_receive_skb
Date: Mon, 13 Aug 2012 07:44:10 -0700
Message-ID: <20120813144255.GA4789@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <jeffrey.t.kirsher@intel.com>, <peter.p.waskiewicz.jr@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:26553 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab2HMOpj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 10:45:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narendra K <narendra_k@dell.com>

Remove 'rx_ring' parameter as it is not used in ixgbevf_receive_skb

Signed-off-by: Narendra K <narendra_k@dell.com>
---
The patch applies to 'net' tree.

 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 60ef645..cc5cdeb 100644
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
1.7.10.1

-- 
With regards,
Narendra K
