From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Subject: [PATCH net-next] net: macb: replace literal constant with NET_IP_ALIGN
Date: Tue, 30 Jun 2015 20:25:25 +0300
Message-ID: <5592D105.7080006@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "'Nicolas Ferre" <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.uti.ro ([91.220.13.110]:57268 "EHLO mx2.uti.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbbF3Rlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 13:41:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Nicolae Rosia <nicolae.rosia@certsign.ro>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index caeb395..dbb5160 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2554,9 +2554,9 @@ static void at91ether_rx(struct net_device *dev)
 	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
 		p_recv = lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
 		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
-		skb = netdev_alloc_skb(dev, pktlen + 2);
+		skb = netdev_alloc_skb(dev, pktlen + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, 2);
+			skb_reserve(skb, NET_IP_ALIGN);
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
 
 			skb->protocol = eth_type_trans(skb, dev);
-- 
2.1.0
