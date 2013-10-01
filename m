From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 3/4] ip_tunnel_core: Change __skb_push back to skb_push
Date: Tue, 1 Oct 2013 11:35:51 +0200
Message-ID: <20131001093551.GI7660@secunet.com>
References: <20131001093359.GG7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34091 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab3JAJfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 05:35:53 -0400
Content-Disposition: inline
In-Reply-To: <20131001093359.GG7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Git commit 0e6fbc5b ("ip_tunnels: extend iptunnel_xmit()")
moved the IP header installation to iptunnel_xmit() and
changed skb_push() to __skb_push(). This makes possible
bugs hard to track down, so change it back to skb_push().

Cc: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index d6c856b..c31e3ad 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -61,7 +61,7 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
 	/* Push down and install the IP header. */
-	__skb_push(skb, sizeof(struct iphdr));
+	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
 
 	iph = ip_hdr(skb);
-- 
1.7.9.5
