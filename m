From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/10] spidernet: skb used after netif_receive_skb
Date: Tue, 22 May 2007 18:09:42 -0500
Message-ID: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53646 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756166AbXEVXJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 19:09:47 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MN9kgd029233
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 19:09:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MN9kk6216114
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:09:46 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MN9jBu016365
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 17:09:45 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florin Malita <fmalita@gmail.com>

The stats update code in spider_net_pass_skb_up() is touching the skb 
after it's been passed up to the stack. To avoid that, just update the 
stats first.

Signed-off-by: Florin Malita <fmalita@gmail.com>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
----

 drivers/net/spider_net.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 108adbf..1df2f0b 100644
Index: netdev-2.6/drivers/net/spider_net.c
===================================================================
--- netdev-2.6.orig/drivers/net/spider_net.c	2007-05-21 17:40:49.000000000 -0500
+++ netdev-2.6/drivers/net/spider_net.c	2007-05-22 18:03:16.000000000 -0500
@@ -1014,12 +1014,12 @@ spider_net_pass_skb_up(struct spider_net
 		 */
 	}
 
-	/* pass skb up to stack */
-	netif_receive_skb(skb);
-
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
 	card->netdev_stats.rx_bytes += skb->len;
+
+	/* pass skb up to stack */
+	netif_receive_skb(skb);
 }
 
 #ifdef DEBUG
