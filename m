From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: remove extra rcu lock
Date: Tue, 19 Mar 2013 21:40:50 +0900
Message-ID: <1363696850-14766-4-git-send-email-horms@verge.net.au>
References: <1363696850-14766-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45734 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622Ab3CSMk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 08:40:56 -0400
In-Reply-To: <1363696850-14766-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

In 3.7 we added code that uses ipv4_update_pmtu but after commit
c5ae7d4192 (ipv4: must use rcu protection while calling fib_lookup)
the RCU lock is not needed.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 18b4bc5..61f49d2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1394,10 +1394,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
 				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
-			rcu_read_lock();
 			ipv4_update_pmtu(skb, dev_net(skb->dev),
 					 mtu, 0, 0, 0, 0);
-			rcu_read_unlock();
 			/* Client uses PMTUD? */
 			if (!(cih->frag_off & htons(IP_DF)))
 				goto ignore_ipip;
-- 
1.7.10.4
