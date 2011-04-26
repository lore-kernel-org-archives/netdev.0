From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4] ipv4: Respect 'saddr' and 'daddr' args to
 ip_build_and_send_pkt().
Date: Tue, 26 Apr 2011 15:12:00 -0700 (PDT)
Message-ID: <20110426.151200.179925027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758439Ab1DZWMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:12:33 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5A52124C08A
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:12:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This function ignores the passed in addresses and forces their
settings using rt->rt_dst and rt->rt_src.

There is never a reason to do this, because the socket of the
callers of this function must know what addresses it is using.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index bdad3d6..e0d0d5d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -158,8 +158,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	else
 		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
-	iph->daddr    = rt->rt_dst;
-	iph->saddr    = rt->rt_src;
+	iph->daddr    = daddr;
+	iph->saddr    = saddr;
 	iph->protocol = sk->sk_protocol;
 	ip_select_ident(iph, &rt->dst, sk);
 
-- 
1.7.4.5

