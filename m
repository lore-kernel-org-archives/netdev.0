From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 6/15] spidernet: skb used after netif_receive_skb
Date: Mon, 11 Jun 2007 13:32:31 -0500
Message-ID: <20070611183231.GF13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:34368 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbXFKScj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:32:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIWc1B005446
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:32:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIWaUX175076
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:32:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIWYbg024300
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:32:35 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
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
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-08 17:40:02.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-08 17:40:09.000000000 -0500
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
