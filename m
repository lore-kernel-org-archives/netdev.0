From: Simon Horman <horms@verge.net.au>
Subject: [rfc] bridge: is PACKET_LOOPBACK unlikely()?
Date: Mon, 23 Aug 2010 12:35:32 +0900
Message-ID: <20100823033532.GA28463@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59272 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0HWDfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 23:35:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking at using netdev_rx_handler_register for openvswitch Jesse
Gross suggested that an unlikely() might be worthwhile in that code.
I'm interested to see if its appropriate for the bridge code.

Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/net/bridge/br_input.c
===================================================================
--- net-next-2.6.orig/net/bridge/br_input.c	2010-08-23 12:17:58.000000000 +0900
+++ net-next-2.6/net/bridge/br_input.c	2010-08-23 12:19:46.000000000 +0900
@@ -141,7 +141,7 @@ struct sk_buff *br_handle_frame(struct s
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	int (*rhook)(struct sk_buff *skb);
 
-	if (skb->pkt_type == PACKET_LOOPBACK)
+	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return skb;
 
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
