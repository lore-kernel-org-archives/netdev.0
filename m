From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2] ipv6: don't accept multicast traffic with scop 0
Date: Sun, 10 Feb 2013 16:35:22 +0100
Message-ID: <20130210153522.GA20897@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55542 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745Ab3BJPf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 10:35:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
a) moved before multicast source address check
b) changed comment to netdev style

Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_input.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 4ac5bf3..521d9fd 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -118,6 +118,15 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	    ipv6_addr_loopback(&hdr->daddr))
 		goto err;
 
+	/* RFC4291 2.7
+	 * Nodes must not originate a packet to a multicast address whose scop
+	 * field contains the reserved value 0; if such a packet is received, it
+	 * must be silently dropped.
+	 */
+	if (ipv6_addr_is_multicast(&hdr->daddr) &&
+	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 0)
+		goto err;
+
 	/*
 	 * RFC4291 2.7
 	 * Multicast addresses must not be used as source addresses in IPv6
-- 
1.8.1.2
