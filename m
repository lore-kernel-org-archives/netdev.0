From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 05/17] net: cxgb4 calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:27:29 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260922590.21031@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:41093 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317Ab3KZR1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:27:30 -0500
Received: by mail-ob0-f201.google.com with SMTP id va2so1255797obc.0
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:27:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index ac311f5..c9fd598 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1630,7 +1630,8 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
+		skb_set_rxhash(skb, (__force u32)pkt->rsshdr.hash_val,
+			       RXHASH_TYPE_L3);
 
 	if (unlikely(pkt->vlan_ex)) {
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
@@ -1686,7 +1687,8 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	skb->protocol = eth_type_trans(skb, q->netdev);
 	skb_record_rx_queue(skb, q->idx);
 	if (skb->dev->features & NETIF_F_RXHASH)
-		skb->rxhash = (__force u32)pkt->rsshdr.hash_val;
+		skb_set_rxhash(skb, (__force u32)pkt->rsshdr.hash_val,
+			       RXHASH_TYPE_L3);
 
 	rxq->stats.pkts++;
 
-- 
1.8.4.1
