From: Donatas Abraitis <donatas.abraitis@gmail.com>
Subject: [PATCH net-next v2] net: ipv6: make sure multicast packets are not forwarded beyond the different scopes
Date: Thu, 27 Apr 2017 10:12:02 +0300
Message-ID: <20170427071202.84403-1-donatas.abraitis@gmail.com>
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
        donatas.abraitis@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kvb.lt ([193.219.39.208]:43193 "EHLO list.kvb.lt"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938667AbdD0HMH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 03:12:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	    RFC4291 2.7 Routers must not forward any multicast packets
	    beyond of the scope indicated by the scop field in the
	    destination multicast address.

Signed-off-by: Donatas Abraitis <donatas.abraitis@gmail.com>
---
 net/ipv6/ip6_input.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 9ee208a..cbe5eef 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -165,6 +165,14 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) == 0)
 		goto err;
 
+	/* RFC4291 2.7
+	 * Routers must not forward any multicast packets beyond of the scope
+	 * indicated by the scop field in the destination multicast address.
+	*/
+	if (ipv6_addr_is_multicast(&hdr->daddr) &&
+	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) != IPV6_ADDR_MC_SCOPE(&hdr->saddr))
+	        goto err;
+
 	/*
 	 * RFC4291 2.7
 	 * Multicast addresses must not be used as source addresses in IPv6
-- 
2.10.0
