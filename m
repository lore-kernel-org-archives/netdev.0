From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] 3c515: Write outside array bounds
Date: Sun, 26 Jul 2009 00:35:29 +0200
Message-ID: <4A6B88B1.9000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:56551 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbZGYWcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 18:32:55 -0400
Received: by ewy26 with SMTP id 26so2451099ewy.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 15:32:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if dev_alloc_skb() fails on the first iteration, a write to
cp->rx_ring[-1] occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Please review: can we error return like this?

diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 3e00fa8..c84815a 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -827,7 +827,7 @@ static int corkscrew_open(struct net_device *dev)
 			skb = dev_alloc_skb(PKT_BUF_SZ);
 			vp->rx_skbuff[i] = skb;
 			if (skb == NULL)
-				break;	/* Bad news!  */
+				return -ENOMEM;	/* Bad news!  */
 			skb->dev = dev;	/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			vp->rx_ring[i].addr = isa_virt_to_bus(skb->data);
