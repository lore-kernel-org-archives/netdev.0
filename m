From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 1/4] tipc: add net device to skb before UDP xmit
Date: Thu, 3 Mar 2016 14:20:40 +0100
Message-ID: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:54963 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbcCCNUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 08:20:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch enabling a IPv4 UDP bearer caused a null pointer
dereference in iptunnel_xmit_stats(), when it tried to dereference the
net device from the skb. To resolve this we now point the skb device
to the net device resolved from the routing table.

Fixes: 039f50629b7f (ip_tunnel: Move stats update to iptunnel_xmit())
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@gmail.com>
---
 net/tipc/udp_media.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index d63a911..f22a5bb1 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -181,6 +181,8 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 			err = PTR_ERR(rt);
 			goto tx_error;
 		}
+
+		skb->dev = rt->dst.dev;
 		ttl = ip4_dst_hoplimit(&rt->dst);
 		udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb, src->ipv4.s_addr,
 				    dst->ipv4.s_addr, 0, ttl, 0, src->udp_port,
-- 
2.1.4
