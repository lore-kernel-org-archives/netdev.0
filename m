From: Kevin Lo <kevlo@kevlo.org>
Subject: [PATCH] via-rhine: changed to use netdev_alloc_skb() from
	dev_alloc_skb
Date: Wed, 27 Aug 2008 11:35:09 +0800
Message-ID: <1219808109.7135.11.camel@nsl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vHmvErS7fPKrgKlKm9z3"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kevlo.org ([220.128.136.52]:33259 "EHLO ns.kevlo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbYH0Dld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 23:41:33 -0400
Received: from [127.0.0.1] (ns.kevlo.org [220.128.136.52])
	by ns.kevlo.org (8.14.3/8.14.3) with ESMTP id m7R3ZUZS005596
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 11:35:36 +0800 (CST)
	(envelope-from kevlo@kevlo.org)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vHmvErS7fPKrgKlKm9z3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Use netdev_alloc_skb. This sets skb->dev and allows 
arch specific allocation. Also cleanup the alignment code.

Tested on x86_64.

Signed-off-by:	Kevin Lo <kevlo@kevlo.org>

--=-vHmvErS7fPKrgKlKm9z3
Content-Disposition: attachment; filename=patch-via-rhine
Content-Type: text/x-patch; name=patch-via-rhine; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.27-rc4/drivers/net/via-rhine.c.orig	2008-08-27 09:38:44.000000000 +0800
+++ linux-2.6.27-rc4/drivers/net/via-rhine.c	2008-08-27 09:40:50.000000000 +0800
@@ -914,7 +914,7 @@ static void alloc_rbufs(struct net_devic
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(rp->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, rp->rx_buf_sz);
 		rp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1473,8 +1473,8 @@ static int rhine_rx(struct net_device *d
 			/* Check if the packet is long enough to accept without
 			   copying to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-				(skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
+				(skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN)) != NULL) {
+				skb_reserve(skb, NET_IP_ALIGN);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(rp->pdev,
 							    rp->rx_skbuff_dma[entry],
 							    rp->rx_buf_sz,
@@ -1518,7 +1518,7 @@ static int rhine_rx(struct net_device *d
 		struct sk_buff *skb;
 		entry = rp->dirty_rx % RX_RING_SIZE;
 		if (rp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(rp->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, rp->rx_buf_sz);
 			rp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */

--=-vHmvErS7fPKrgKlKm9z3--

