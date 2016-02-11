From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 3/8] net: enable LCO for udp_tunnel_handle_offloads()
 users
Date: Thu, 11 Feb 2016 20:50:44 +0000
Message-ID: <alpine.LFD.2.20.1602112050020.15537@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:2237 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbcBKUu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 15:50:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only protocol affected at present is Geneve.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/net/udp_tunnel.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index cca2ad3..734c156 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -103,7 +103,8 @@ static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 {
 	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
-	return iptunnel_handle_offloads(skb, udp_csum, type);
+	/* As we're a UDP tunnel, we support LCO, so don't need csum_help */
+	return iptunnel_handle_offloads(skb, false, type);
 }
 
 static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
