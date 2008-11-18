From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: fix per-slice rx/tx_dropped counters
Date: Tue, 18 Nov 2008 21:10:56 +0100
Message-ID: <49232150.4010202@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1940 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751935AbYKRULN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 15:11:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly attribute transmit and receive drops by incrementing the
per-slice counter.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: net-next-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- net-next-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-11-11 21:51:11.000000000 +0100
+++ net-next-2.6/drivers/net/myri10ge/myri10ge.c	2008-11-18 21:02:12.000000000 +0100
@@ -1309,7 +1309,7 @@
 
 	skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
 	if (unlikely(skb == NULL)) {
-		mgp->stats.rx_dropped++;
+		ss->stats.rx_dropped++;
 		do {
 			i--;
 			put_page(rx_frags[i].page);
@@ -2924,6 +2924,7 @@
 {
 	struct sk_buff *segs, *curr;
 	struct myri10ge_priv *mgp = netdev_priv(dev);
+	struct myri10ge_slice_state *ss;
 	int status;
 
 	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
@@ -2950,8 +2951,9 @@
 	return 0;
 
 drop:
+	ss = &mgp->ss[skb_get_queue_mapping(skb)];
 	dev_kfree_skb_any(skb);
-	mgp->stats.tx_dropped += 1;
+	ss->stats.tx_dropped += 1;
 	return 0;
 }
 


