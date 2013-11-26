From: Tom Herbert <therbert@google.com>
Subject: [PATCH 12/17] net: sky2 calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:55:56 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252154360.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:61345 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab3KZFz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:55:57 -0500
Received: by mail-qe0-f74.google.com with SMTP id b10so264361qen.5
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:55:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/marvell/sky2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index a7df981..abfe57a 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2495,7 +2495,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 		skb_copy_from_linear_data(re->skb, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
-		skb->rxhash = re->skb->rxhash;
+		skb_set_rxhash(skb, re->skb->rxhash, RXHASH_TYPE_L3);
 		skb->vlan_proto = re->skb->vlan_proto;
 		skb->vlan_tci = re->skb->vlan_tci;
 
@@ -2503,7 +2503,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 					       length, PCI_DMA_FROMDEVICE);
 		re->skb->vlan_proto = 0;
 		re->skb->vlan_tci = 0;
-		re->skb->rxhash = 0;
+		skb_clear_rxhash(re->skb);
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
 	}
@@ -2723,7 +2723,7 @@ static void sky2_rx_hash(struct sky2_port *sky2, u32 status)
 	struct sk_buff *skb;
 
 	skb = sky2->rx_ring[sky2->rx_next].skb;
-	skb->rxhash = le32_to_cpu(status);
+	skb_set_rxhash(skb, le32_to_cpu(status), RXHASH_TYPE_L3);
 }
 
 /* Process status response ring */
-- 
1.8.4.1
