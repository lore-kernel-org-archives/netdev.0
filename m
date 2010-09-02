From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: another last_rx round
Date: Thu, 02 Sep 2010 08:29:58 +0200
Message-ID: <1283408998.2484.131.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48947 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab0IBGaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 02:30:04 -0400
Received: by wwj40 with SMTP id 40so302959wwj.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 23:30:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kill last_rx use in l2tp and two net drivers

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/cxgb4vf/sge.c |    1 -
 drivers/net/pxa168_eth.c  |    1 -
 net/l2tp/l2tp_eth.c       |    1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index eb5a1c9..e00fd9c 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1520,7 +1520,6 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	__skb_pull(skb, PKTSHIFT);
 	skb->protocol = eth_type_trans(skb, rspq->netdev);
 	skb_record_rx_queue(skb, rspq->idx);
-	skb->dev->last_rx = jiffies;                  /* XXX removed 2.6.29 */
 	pi = netdev_priv(skb->dev);
 	rxq->stats.pkts++;
 
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 659915c..764aa90 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -848,7 +848,6 @@ static int rxq_process(struct net_device *dev, int budget)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
 		}
-		dev->last_rx = jiffies;
 	}
 	/* Fill RX ring with skb's */
 	rxq_refill(dev);
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 58c6c4c..f3468ba 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -144,7 +144,6 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 	nf_reset(skb);
 
 	if (dev_forward_skb(dev, skb) == NET_RX_SUCCESS) {
-		dev->last_rx = jiffies;
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += data_len;
 	} else


