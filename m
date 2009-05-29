From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: unset IFF_XMIT_DST_RELEASE in ipgre_tunnel_setup()
Date: Fri, 29 May 2009 10:35:10 +0200
Message-ID: <4A1F9E3E.5020409@gmail.com>
References: <4A1EF7AE.2040404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33238 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731AbZE2IfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:35:18 -0400
In-Reply-To: <4A1EF7AE.2040404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_tunnel_xmit() might need skb->dst, so tell dev_hard_start_xmit()
to no release it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e62510d..77436e2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1238,6 +1238,7 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 
 static int ipgre_tunnel_init(struct net_device *dev)
