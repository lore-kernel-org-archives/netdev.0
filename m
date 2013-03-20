From: pablo@netfilter.org
Subject: [PATCH 6/7] ipvs: remove extra rcu lock
Date: Wed, 20 Mar 2013 11:49:33 +0100
Message-ID: <1363776574-4766-7-git-send-email-pablo@netfilter.org>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

