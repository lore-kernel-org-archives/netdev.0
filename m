From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 3/5] defxx: Use netdev_alloc_skb consistently
Date: Sat, 5 Jul 2014 15:14:36 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020559470.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaGEOOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:37 -0400
Received: from localhost.localdomain ([127.0.0.1]:48341 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859971AbaGEOOgcPaEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:36 +0200
In-Reply-To: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the two remaining places across the driver that use dev_alloc_skb 
to netdev_alloc_skb.  Another place has already been converted to use 
__netdev_alloc_skb, no idea why these two have been left behind.

Reported-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Tested-by: Robert Coerver <Robert.Coerver@ll.mit.edu>
Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Please apply,

  Maciej

linux-defxx-netdev-alloc-skb.patch
Index: linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140623-swarm64-eb.orig/drivers/net/fddi/defxx.c
+++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.c
@@ -3049,7 +3049,8 @@ static void dfx_rcv_queue_process(
 				if (pkt_len > SKBUFF_RX_COPYBREAK) {
 					struct sk_buff *newskb;
 
-					newskb = dev_alloc_skb(NEW_SKB_SIZE);
+					newskb = netdev_alloc_skb(bp->dev,
+								  NEW_SKB_SIZE);
 					if (newskb){
 						rx_in_place = 1;
 
@@ -3070,7 +3071,10 @@ static void dfx_rcv_queue_process(
 						skb = NULL;
 				} else
 #endif
-					skb = dev_alloc_skb(pkt_len+3);	/* alloc new buffer to pass up, add room for PRH */
+					/* Alloc new buffer to pass up,
+					 * add room for PRH. */
+					skb = netdev_alloc_skb(bp->dev,
+							       pkt_len + 3);
 				if (skb == NULL)
 					{
 					printk("%s: Could not allocate receive buffer.  Dropping packet.\n", bp->dev->name);
