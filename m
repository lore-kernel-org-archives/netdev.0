From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/18] spidernet: skb used after netif_receive_skb
Date: Thu, 7 Jun 2007 14:20:14 -0500
Message-ID: <20070607192014.GA16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Florin Malita <fmalita@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:39727 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763667AbXFGTUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 15:20:19 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JLLvH014606
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:21:21 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JKHYJ552756
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:20:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JKGs4022553
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:20:17 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
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
Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:51:04.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:51:40.000000000 -0500
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
