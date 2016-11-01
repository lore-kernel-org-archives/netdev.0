From: Eli Cooper <elicooper@gmx.com>
Subject: [PATCH net v3 2/2] ip6_udp_tunnel: remove unused IPCB related codes
Date: Tue,  1 Nov 2016 23:45:13 +0800
Message-ID: <20161101154513.30347-2-elicooper@gmx.com>
References: <20161101154513.30347-1-elicooper@gmx.com>
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:61329 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750920AbcKAPpd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 11:45:33 -0400
In-Reply-To: <20161101154513.30347-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some IPCB fields are currently set in udp_tunnel6_xmit_skb(), which are
never used before it reaches ip6tunnel_xmit(), and past that point the
control buffer is no longer interpreted as IPCB.

This clears these unused IPCB related codes. Currently there is no skb
scrubbing in ip6_udp_tunnel, otherwise IPCB(skb)->opt might need to be
cleared for IPv4 packets, as shown in 5146d1f1511
("tunnel: Clear IPCB(skb)->opt before dst_link_failure called").

Signed-off-by: Eli Cooper <elicooper@gmx.com>
---
 net/ipv6/ip6_udp_tunnel.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index a752052..b283f29 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -88,9 +88,6 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 
 	uh->len = htons(skb->len);
 
-	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
-			    | IPSKB_REROUTED);
 	skb_dst_set(skb, dst);
 
 	udp6_set_csum(nocheck, skb, saddr, daddr, skb->len);
-- 
2.10.1
