From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: unset IFF_XMIT_DST_RELEASE in ipip_tunnel_setup()
Date: Thu, 28 May 2009 22:44:30 +0200
Message-ID: <4A1EF7AE.2040404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56048 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755852AbZE1Uoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 16:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipip_tunnel_xmit() might need skb->dst, so tell dev_hard_start_xmit()
to no release it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9054139..bb2f1b1 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -713,6 +713,7 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 
 static void ipip_tunnel_init(struct net_device *dev)
