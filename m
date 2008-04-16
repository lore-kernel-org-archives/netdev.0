From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/13] ns8320: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:35 -0700
Message-ID: <20080416233757.549298900@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43784 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbYDPXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:27 -0400
Content-Disposition: inline; filename=ns83820
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ns83820.c	2008-04-02 10:55:30.000000000 -0700
+++ b/drivers/net/ns83820.c	2008-04-16 16:34:50.000000000 -0700
@@ -585,16 +585,13 @@ static inline int rx_refill(struct net_d
 	for (i=0; i<NR_RX_DESC; i++) {
 		struct sk_buff *skb;
 		long res;
+
 		/* extra 16 bytes for alignment */
-		skb = __dev_alloc_skb(REAL_RX_BUF_SIZE+16, gfp);
+		skb = __netdev_alloc_skb(ndev, REAL_RX_BUF_SIZE+16, gfp);
 		if (unlikely(!skb))
 			break;
 
-		res = (long)skb->data & 0xf;
-		res = 0x10 - res;
-		res &= 0xf;
-		skb_reserve(skb, res);
-
+		skb_reserve(skb, skb->data - PTR_ALIGN(skb->data, 16));
 		if (gfp != GFP_ATOMIC)
 			spin_lock_irqsave(&dev->rx_info.lock, flags);
 		res = ns83820_add_rx_skb(dev, skb);

-- 

