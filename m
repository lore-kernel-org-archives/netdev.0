From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/13] ixp2000: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:37 -0700
Message-ID: <20080416233757.698199646@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43783 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbYDPXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:27 -0400
Content-Disposition: inline; filename=ixp2000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ixp2000/ixpdev.c	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/ixp2000/ixpdev.c	2008-04-07 12:43:41.000000000 -0700
@@ -108,14 +108,14 @@ static int ixpdev_rx(struct net_device *
 		if (unlikely(!netif_running(nds[desc->channel])))
 			goto err;
 
-		skb = dev_alloc_skb(desc->pkt_length + 2);
+		skb = netdev_alloc_skb(dev, desc->pkt_length + 2);
 		if (likely(skb != NULL)) {
 			skb_reserve(skb, 2);
 			skb_copy_to_linear_data(skb, buf, desc->pkt_length);
 			skb_put(skb, desc->pkt_length);
 			skb->protocol = eth_type_trans(skb, nds[desc->channel]);
 
-			skb->dev->last_rx = jiffies;
+			dev->last_rx = jiffies;
 
 			netif_receive_skb(skb);
 		}

-- 

