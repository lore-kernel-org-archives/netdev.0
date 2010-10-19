From: Anders.Franzen@ericsson.com
Subject: [PATCH] ip6_tunnel dont update the mtu on the route.
Date: Tue, 19 Oct 2010 15:50:47 +0200
Message-ID: <1287496247-24127-1-git-send-email-Anders.Franzen@ericsson.com>
Cc: Anders Franzen <anders.franzen@ericsson.com>
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:43467 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab0JSNvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 09:51:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders Franzen <anders.franzen@ericsson.com>

The ip6_tunnel device did not unset the flag,
IFF_XMIT_DST_RELEASE. This will make the dev layer
to release the dst before calling the tunnel.
The tunnel will not update any mtu/pmtu info, since
it does not have a dst on the skb.
---
 net/ipv6/ip6_tunnel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c2c0f89..38b9a56 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1371,6 +1371,7 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->features |= NETIF_F_NETNS_LOCAL;
+	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
 
-- 
1.7.2.3

