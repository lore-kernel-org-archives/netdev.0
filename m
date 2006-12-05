From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19 4/4] AT91RM9200 Ethernet: Use dev_alloc_skb()
Date: 05 Dec 2006 15:37:02 +0200
Message-ID: <1165325822.12510.98.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3631 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968202AbWLENqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 08:46:53 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_alloc_skb() instead of alloc_skb().

It is also not necessary to adjust skb->len manually since that's
already done by skb_put().


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Tue Dec  5 14:12:53 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Tue Dec  5 14:13:38 2006
@@ -853,14 +853,13 @@
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



