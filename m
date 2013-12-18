From: Tom Herbert <therbert@google.com>
Subject: [PATCH 10/15] net: sky2 calls skb_set_hash
Date: Tue, 17 Dec 2013 23:28:13 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172323570.11882@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:36905 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3LRH2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:28:14 -0500
Received: by mail-qc0-f201.google.com with SMTP id r5so735930qcx.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:28:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/marvell/sky2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 43aa7acd..6509935 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2495,7 +2495,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 		skb_copy_from_linear_data(re->skb, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
-		skb->rxhash = re->skb->rxhash;
+		skb_copy_hash(skb, re->skb);
 		skb->vlan_proto = re->skb->vlan_proto;
 		skb->vlan_tci = re->skb->vlan_tci;
 
@@ -2503,7 +2503,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 					       length, PCI_DMA_FROMDEVICE);
 		re->skb->vlan_proto = 0;
 		re->skb->vlan_tci = 0;
-		re->skb->rxhash = 0;
+		skb_clear_hash(re->skb);
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
 	}
@@ -2723,7 +2723,7 @@ static void sky2_rx_hash(struct sky2_port *sky2, u32 status)
 	struct sk_buff *skb;
 
 	skb = sky2->rx_ring[sky2->rx_next].skb;
-	skb->rxhash = le32_to_cpu(status);
+	skb_set_hash(skb, le32_to_cpu(status), PKT_HASH_TYPE_L3);
 }
 
 /* Process status response ring */
-- 
1.8.5.1
