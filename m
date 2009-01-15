From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH] korina: set dev field of allocated socketbufs
Date: Thu, 15 Jan 2009 23:29:58 +0100
Message-ID: <20090115223035.AD41B4043839@mail.nwl.cc>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org>
 <1232058598-15811-2-git-send-email-n0-1@freewrt.org>
 <1232058598-15811-3-git-send-email-n0-1@freewrt.org>
Cc: davem@davemloft.net, jeff@garzik.org, florian@openwrt.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58492 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935042AbZAOWjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 17:39:42 -0500
In-Reply-To: <1232058598-15811-3-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure if this is necessary, but the original driver did it and
apparently also many other drivers do it, so it should not be completely
wrong to do it.

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 75010ca..56b4db2 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -419,6 +419,7 @@ static int korina_rx(struct net_device *dev, int limit)
 			/* 16 bit align */
 			skb_reserve(skb_new, 2);
 
+			skb_new->dev = dev;
 			lp->rx_skb[lp->rx_next_done] = skb_new;
 		}
 
@@ -763,6 +764,7 @@ static void korina_alloc_ring(struct net_device *dev)
 		if (!skb)
 			break;
 		skb_reserve(skb, 2);
+		skb->dev = dev;
 		lp->rx_skb[i] = skb;
 		lp->rd_ring[i].control = DMA_DESC_IOD |
 				DMA_COUNT(KORINA_RBSIZE);
-- 
1.5.6.4

