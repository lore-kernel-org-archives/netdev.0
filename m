From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: ftgmac100: use kfree_skb() where appropriate
Date: Thu, 16 Jan 2014 23:38:24 -0800
Message-ID: <1389944304.31367.476.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40279 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaAQHi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 02:38:26 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so1470037pad.0
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 23:38:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In order to get correct drop monitor notifications for dropped
packets, we should call kfree_skb() instead of dev_kfree_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 24d87898209b..c11ecbc98149 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -766,7 +766,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 			continue;
 
 		dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 	}
 
 	dma_free_coherent(priv->dev, sizeof(struct ftgmac100_descs),
@@ -1148,7 +1148,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 			netdev_dbg(netdev, "tx packet too big\n");
 
 		netdev->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -1159,7 +1159,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 			netdev_err(netdev, "map socket buffer failed\n");
 
 		netdev->stats.tx_dropped++;
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
