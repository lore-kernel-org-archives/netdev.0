From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: use ipv6_addr_copy() in ip6_route_redirect()
Date: Wed, 07 Oct 2009 11:46:53 -0400
Message-ID: <4ACCB7ED.7070901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:30629 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759397AbZJGPrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 11:47:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ip6_route_redirect() to use ipv6_addr_copy().

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d6fe764..df9432a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1471,9 +1471,10 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 				},
 			},
 		},
-		.gateway = *gateway,
 	};
 
+	ipv6_addr_copy(&rdfl.gateway, gateway);
+
 	if (rt6_need_strict(dest))
 		flags |= RT6_LOOKUP_F_IFACE;
 
