From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 4/4] gre6: Move the setting of dev->iflink into the ndo_init functions.
Date: Mon, 3 Nov 2014 09:19:30 +0100
Message-ID: <1415002770-5797-5-git-send-email-steffen.klassert@secunet.com>
References: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35471 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbaKCIUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 03:20:12 -0500
In-Reply-To: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise it gets overwritten by register_netdev().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_gre.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 12c3c8e..4564e1f 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -961,8 +961,6 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 	else
 		dev->flags &= ~IFF_POINTOPOINT;
 
-	dev->iflink = p->link;
-
 	/* Precalculate GRE options length */
 	if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
 		if (t->parms.o_flags&GRE_CSUM)
@@ -1272,6 +1270,7 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ip6gre_tunnel_stats->syncp);
 	}
 
+	dev->iflink = tunnel->parms.link;
 
 	return 0;
 }
@@ -1481,6 +1480,8 @@ static int ip6gre_tap_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	dev->iflink = tunnel->parms.link;
+
 	return 0;
 }
 
-- 
1.9.1
