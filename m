From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] spidernet: node-aware skbuff allocation
Date: Wed, 16 May 2007 15:01:42 +0200
Message-ID: <20070516130142.GA1437@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:43146 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbXEPNB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 09:01:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Spidernet was the driver I original did all the node-aware netdevice
allocation for, but after a year it still hasn't hit mainline.

So here's the patch again:


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.orig/drivers/net/spider_net.c	2006-10-23 17:20:14.000000000 +0200
+++ linux-2.6/drivers/net/spider_net.c	2006-10-30 13:27:48.000000000 +0100
@@ -395,7 +395,8 @@
 	/* and we need to have it 128 byte aligned, therefore we allocate a
 	 * bit more */
 	/* allocate an skb */
-	descr->skb = dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
+	descr->skb = netdev_alloc_skb(card->netdev,
+				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Not enough memory to allocate rx buffer\n");
