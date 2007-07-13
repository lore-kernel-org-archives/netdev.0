From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: Remove nonsensical limit in the tx done routine
Date: Fri, 13 Jul 2007 20:15:13 +0200
Message-ID: <4697C131.7070805@myri.com>
References: <4697C0E8.40003@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1981 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932290AbXGMSN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 14:13:59 -0400
In-Reply-To: <4697C0E8.40003@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove nonsensical limit in the tx done routine. Specifically,
the loop will always terminate after processing <= 1 rings worth
of frames, as the mcp index is not refetched, so the removed
conditional could never be true.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-2.6.22/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.22.orig/drivers/net/myri10ge/myri10ge.c	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22/drivers/net/myri10ge/myri10ge.c	2007-07-12 11:21:29.000000000 +0200
@@ -1059,7 +1059,6 @@
 	struct myri10ge_tx_buf *tx = &mgp->tx;
 	struct sk_buff *skb;
 	int idx, len;
-	int limit = 0;
 
 	while (tx->pkt_done != mcp_index) {
 		idx = tx->done & tx->mask;
@@ -1090,11 +1089,6 @@
 							      bus), len,
 					       PCI_DMA_TODEVICE);
 		}
-
-		/* limit potential for livelock by only handling
-		 * 2 full tx rings per call */
-		if (unlikely(++limit > 2 * tx->mask))
-			break;
 	}
 	/* start the queue if we've stopped it */
 	if (netif_queue_stopped(mgp->dev)


