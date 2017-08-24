From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: mv643xx_eth: Be drop monitor friendly
Date: Thu, 24 Aug 2017 16:04:25 -0700
Message-ID: <20170824230425.15948-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

txq_reclaim() does the normal transmit queue reclamation and
rxq_deinit() does the RX ring cleanup, none of these are packet drops,
so use dev_consume_skb() for both locations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c94ea9b2b80..7655616bffef 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1123,7 +1123,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
 
 			if (!WARN_ON(!skb))
-				dev_kfree_skb(skb);
+				dev_consume_skb(skb);
 		}
 
 		if (cmd_sts & ERROR_SUMMARY) {
@@ -2026,7 +2026,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 
 	for (i = 0; i < rxq->rx_ring_size; i++) {
 		if (rxq->rx_skb[i]) {
-			dev_kfree_skb(rxq->rx_skb[i]);
+			dev_consume_skb(rxq->rx_skb[i]);
 			rxq->rx_desc_count--;
 		}
 	}
-- 
2.9.3
