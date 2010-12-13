From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 3/5] ifb: fix tx_queue_len overlimit
Date: Mon, 13 Dec 2010 22:43:32 +0800
Message-ID: <1292251414-5154-3-git-send-email-xiaosuo@gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:37550 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab0LMOo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 09:44:27 -0500
Received: by gxk19 with SMTP id 19so3959223gxk.11
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 06:44:27 -0800 (PST)
In-Reply-To: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should check the length of rq after enqueuing, otherwise the length
of rq will be over tx_queue_len.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 1628d01..57c5cfb 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -131,15 +131,15 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len)
-		netif_stop_queue(dev);
-
 	__skb_queue_tail(&dp->rq, skb);
 	if (!dp->tasklet_pending) {
 		dp->tasklet_pending = 1;
 		tasklet_schedule(&dp->ifb_tasklet);
 	}
 
+	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len)
+		netif_stop_queue(dev);
+
 	return NETDEV_TX_OK;
 }
 
