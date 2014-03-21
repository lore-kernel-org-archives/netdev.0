From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/4] net: don't clear skbuff hash on tunnel xmit
Date: Thu, 20 Mar 2014 17:09:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1403201702050.7145@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:38596 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965867AbaCUAJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:09:20 -0400
Received: by mail-ve0-f201.google.com with SMTP id cz12so202241veb.2
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 17:09:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no reason to clear on transmit, most likely effect is that
we lose what is otherwise a perfectly good hash for the encapsulated
flow.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_tunnel_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index b86f0a3..195be81 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -56,7 +56,6 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, xnet);
 
-	skb_clear_hash(skb);
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
-- 
1.9.1.423.g4596e3a
