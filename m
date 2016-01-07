From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 2/5] net: enable LCO for
 udp_tunnel_handle_offloads() users
Date: Thu, 7 Jan 2016 17:12:37 +0000
Message-ID: <568E9C85.1090208@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:41790 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752660AbcAGRMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:12:49 -0500
In-Reply-To: <568E9BF9.2050001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only protocol affected at present is Geneve.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/net/udp_tunnel.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index cb2f89f..210eb90 100644
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
