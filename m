From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/10] spidernet: node-aware skbuff allocation
Date: Wed, 16 May 2007 16:58:00 -0500
Message-ID: <20070516215800.GA4997@austin.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:43394 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359AbXEPV6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 17:58:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GLw2Gs024313
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 17:58:02 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GLw2as525178
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 17:58:02 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GLw1gW005780
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 17:58:01 -0400
Content-Disposition: inline
In-Reply-To: <20070516215605.GA4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Christoph Hellwig <hch@lst.de>

Spidernet was the driver I original did all the node-aware netdevice
allocation for, but after a year it still hasn't hit mainline.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----

 drivers/net/spider_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-16 11:58:41.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-16 12:00:25.000000000 -0500
@@ -430,7 +430,8 @@ spider_net_prepare_rx_descr(struct spide
 	/* and we need to have it 128 byte aligned, therefore we allocate a
 	 * bit more */
 	/* allocate an skb */
-	descr->skb = dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
+	descr->skb = netdev_alloc_skb(card->netdev,
+				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Not enough memory to allocate rx buffer\n");
