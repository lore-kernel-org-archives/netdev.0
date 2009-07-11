From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH] sit: fix regression: do not release skb->dst before xmit
Date: Sat, 11 Jul 2009 15:01:29 +0200
Message-ID: <1247317289-27867-1-git-send-email-contact@saschahlusiak.de>
Cc: berni@birkenwald.de, Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61523 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbZGKND0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 09:03:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sit module makes use of skb->dst in it's xmit function,
so since 93f154b594fe47 sit tunnels are broken, because the
flag IFF_XMIT_DST_RELEASE is not unset.

This patch unsets that flag for sit devices to fix this
regression.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 68e5230..98b7327 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1018,6 +1018,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr);
 	dev->flags		= IFF_NOARP;
+	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
-- 
1.6.3.3

