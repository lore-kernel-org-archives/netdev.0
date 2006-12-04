From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19] AT91RM9200 Ethernet update 3
Date: 04 Dec 2006 14:50:24 +0200
Message-ID: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:2826 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP id S936797AbWLDNAK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:00:10 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A minor fix to the Atmel AT91RM9200 Ethernet driver.

1. Use dev_alloc_skb() instead of alloc_skb().
2. It is not necessary to adjust skb->len manually.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Mon Dec  4 14:42:05 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:43:57 2006
@@ -855,14 +855,13 @@
 	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
 		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
-		skb = alloc_skb(pktlen + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(pktlen + 2);
 		if (skb != NULL) {
 			skb_reserve(skb, 2);
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
 
 			skb->dev = dev;
 			skb->protocol = eth_type_trans(skb, dev);
-			skb->len = pktlen;
 			dev->last_rx = jiffies;
 			lp->stats.rx_bytes += pktlen;
 			netif_rx(skb);



