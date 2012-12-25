From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH 1/2] ipv4/ip_gre: set transport header correctly to gre header
Date: Tue, 25 Dec 2012 11:51:03 +0900
Message-ID: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:44086 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab2LYCvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 21:51:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_tunnel_xmit() incorrectly sets transport header to inner payload
instead of GRE header. It seems copy-and-pasted from ipip.c.
So set transport header to gre header.
(In ipip case the transport header is the inner ip header, so that's
correct.)

Found by inspection. In practice the incorrect transport header
doesn't matter because the skb usually is sent to another net_device
or socket, so the transport header isn't referenced.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 net/ipv4/ip_gre.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 58cb627..303012a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -912,9 +912,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		/* Warning : tiph value might point to freed memory */
 	}
 
-	skb_reset_transport_header(skb);
 	skb_push(skb, gre_hlen);
 	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, sizeof(*iph));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
-- 
1.7.10.4
