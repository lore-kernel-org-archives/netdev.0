From: anders.franzen@ericsson.com
Subject: (unknown)
Date: Tue, 19 Oct 2010 13:15:39 +0200
Message-ID: <4cbd7ddb.h2XSBQwB8NK8A+mZ%anders.franzen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:63895 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758326Ab0JSLPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 07:15:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 5f9bad2172884c192c267cdd29d7fa62b6072252 Mon Sep 17 00:00:00 2001
From: Anders Franzen <anders.franzen@ericsson.com>
Date: Tue, 19 Oct 2010 10:54:28 +0200
Subject: [PATCH] ip6_tunnel dont update the mtu on the route.

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

