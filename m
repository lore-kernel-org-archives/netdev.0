From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 01/11] netpoll: use skb_queue_purge
Date: Sat, 03 Nov 2007 11:43:15 -0700
Message-ID: <20071103184338.438809660@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46151 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757428AbXKCXgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:32 -0400
Content-Disposition: inline; filename=netpoll-flush.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use standard route for flushing queue.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/core/netpoll.c	2007-11-03 09:13:16.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 09:14:05.000000000 -0700
@@ -816,11 +812,7 @@ void netpoll_cleanup(struct netpoll *np)
 				cancel_rearming_delayed_work(&npinfo->tx_work);
 
 				/* clean after last, unfinished work */
-				if (!skb_queue_empty(&npinfo->txq)) {
-					struct sk_buff *skb;
-					skb = __skb_dequeue(&npinfo->txq);
-					kfree_skb(skb);
-				}
+				__skb_queue_purge(&npinfo->txq);
 				kfree(npinfo);
 				np->dev->npinfo = NULL;
 			}

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

