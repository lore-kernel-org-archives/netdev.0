From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] ipv4: In ip_build_and_send_pkt() use 'saddr' and
 'daddr' args passed in.
Date: Wed, 04 May 2011 13:19:38 -0700 (PDT)
Message-ID: <20110504.131938.102545384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab1EDUUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:10 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 41B6224C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of rt->rt_{dst,src}

The only tricky part is source route option handling.

If the source route option is enabled we can't just use plain 'daddr',
we have to use opt->opt.faddr.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3aa4c31..db38c18 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -158,8 +158,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	else
 		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
-	iph->daddr    = rt->rt_dst;
-	iph->saddr    = rt->rt_src;
+	iph->daddr    = (opt && opt->opt.srr ? opt->opt.faddr : daddr);
+	iph->saddr    = saddr;
 	iph->protocol = sk->sk_protocol;
 	ip_select_ident(iph, &rt->dst, sk);
 
-- 
1.7.4.5

