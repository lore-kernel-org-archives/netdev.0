From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] sit: fix 4in4 + IPsec scenario
Date: Wed, 26 Jun 2013 17:40:33 +0200
Message-ID: <1372261233-19648-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43852 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab3FZPkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 11:40:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 32b8a8e59c9c "sit: add IPv4 over IPv4 support",
tunnel->parms.iph.protocol is 0 when both 4in4 and 6in4 are setup, but
xfrm_lookup() is called only when proto is != 0, thus we need to pass the real
value.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index bd227e5..3b00d81 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -542,7 +542,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	rt = ip_route_output_tunnel(dev_net(dev), &fl4,
-				    tunnel->parms.iph.protocol,
+				    protocol,
 				    dst, tnl_params->saddr,
 				    tunnel->parms.o_key,
 				    RT_TOS(tos),
-- 
1.8.2.1
