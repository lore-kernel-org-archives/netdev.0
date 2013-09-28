From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] ethernet: cleanup eth_type_trans
Date: Fri, 27 Sep 2013 17:19:41 -0700
Message-ID: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:62688 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab3I1AVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 20:21:38 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so3192449pbb.41
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 17:21:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old legacy comment and weird if condition.
The comment has outlived it's stay and is throwback to some
early net code (before my time). Maybe Dave remembers what it meant.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ethernet/eth.c	2013-09-26 17:25:54.093639280 -0700
+++ b/net/ethernet/eth.c	2013-09-26 17:34:35.363115182 -0700
@@ -169,20 +169,9 @@ __be16 eth_type_trans(struct sk_buff *sk
 		else
 			skb->pkt_type = PACKET_MULTICAST;
 	}
-
-	/*
-	 *      This ALLMULTI check should be redundant by 1.4
-	 *      so don't forget to remove it.
-	 *
-	 *      Seems, you forgot to remove it. All silly devices
-	 *      seems to set IFF_PROMISC.
-	 */
-
-	else if (1 /*dev->flags&IFF_PROMISC */) {
-		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
-						      dev->dev_addr)))
-			skb->pkt_type = PACKET_OTHERHOST;
-	}
+	else if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
+						   dev->dev_addr)))
+		skb->pkt_type = PACKET_OTHERHOST;
 
 	/*
 	 * Some variants of DSA tagging don't have an ethertype field
