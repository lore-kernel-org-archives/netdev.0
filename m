From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: use ipv6_addr_v4mapped()
Date: Mon, 09 Nov 2009 17:05:53 -0500
Message-ID: <4AF89241.7060203@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:30305 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbZKIWPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 17:15:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change udp6_portaddr_hash() to use ipv6_addr_v4mapped()
inline instead of ipv6_addr_type().

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2915e1d..0ed1637 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -89,7 +89,7 @@ static unsigned int udp6_portaddr_hash(struct net *net,
 
 	if (ipv6_addr_any(addr6))
 		hash = jhash_1word(0, mix);
-	else if (ipv6_addr_type(addr6) == IPV6_ADDR_MAPPED)
+	else if (ipv6_addr_v4mapped(addr6))
 		hash = jhash_1word(addr6->s6_addr32[3], mix);
 	else
 		hash = jhash2(addr6->s6_addr32, 4, mix);
