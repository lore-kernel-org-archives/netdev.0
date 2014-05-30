From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 7/8] net: mv643xx_eth: Drop the NETDEV_TX_BUSY return path
Date: Fri, 30 May 2014 13:40:10 -0300
Message-ID: <1401468011-10609-8-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58458 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933898AbaE3Qla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:30 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After adding proper stop/wake thresholds, we can expect a queue to never
be full and drop the NETDEV_TX_BUSY return path. In any case, if the queue
cannot accommodate a TSO packet, the packet would be discarded.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2cea86d..88afbe0 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -996,8 +996,6 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		if (txq->tx_desc_count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
-	} else if (ret == -EBUSY) {
-		return NETDEV_TX_BUSY;
 	} else {
 		txq->tx_dropped++;
 		dev_kfree_skb_any(skb);
-- 
1.9.1
