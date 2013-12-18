From: Tom Herbert <therbert@google.com>
Subject: [PATCH 03/15] net: cxgb4 calls skb_set_hash
Date: Tue, 17 Dec 2013 23:23:29 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172316570.24419@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:37911 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3LRHXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:23:30 -0500
Received: by mail-yh0-f74.google.com with SMTP id a41so705922yho.3
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:23:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index cc380c3..4274543 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1630,7 +1630,8 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
+		skb_set_hash(skb, (__force u32)pkt->rsshdr.hash_val,
+			     PKT_HASH_TYPE_L3);
 
 	if (unlikely(pkt->vlan_ex)) {
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
@@ -1686,7 +1687,8 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	skb->protocol = eth_type_trans(skb, q->netdev);
 	skb_record_rx_queue(skb, q->idx);
 	if (skb->dev->features & NETIF_F_RXHASH)
-		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
+		skb_set_hash(skb, (__force u32)pkt->rsshdr.hash_val,
+			     PKT_HASH_TYPE_L3);
 
 	rxq->stats.pkts++;
 
-- 
1.8.5.1
