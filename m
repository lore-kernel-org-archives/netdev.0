From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: bridge: fix IPv6 packets not being bridged with CONFIG_IPV6=n
Date: Thu,  3 Sep 2015 11:50:57 +0200
Message-ID: <1441273861-31092-3-git-send-email-pablo@netfilter.org>
References: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46727 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbbICJoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:44:37 -0400
In-Reply-To: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

230ac490f7fba introduced a dependency to CONFIG_IPV6 which breaks bridging
of IPv6 packets on a bridge with CONFIG_IPV6=n.

Sysctl entry /proc/sys/net/bridge/bridge-nf-call-ip6tables defaults to 1,
for this reason packets are handled by br_nf_pre_routing_ipv6(). When compiled
with CONFIG_IPV6=n this function returns NF_DROP but should return NF_ACCEPT
to let packets through.

Change CONFIG_IPV6=n br_nf_pre_routing_ipv6() return value to NF_ACCEPT.

Tested with a simple bridge with two interfaces and IPv6 packets trying
to pass from host on left side to host on right side of the bridge.

Fixes: 230ac490f7fba ("netfilter: bridge: split ipv6 code into separated file")
Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/br_netfilter.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
index bab824b..d4c6b5f 100644
--- a/include/net/netfilter/br_netfilter.h
+++ b/include/net/netfilter/br_netfilter.h
@@ -59,7 +59,7 @@ static inline unsigned int
 br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		       const struct nf_hook_state *state)
 {
-	return NF_DROP;
+	return NF_ACCEPT;
 }
 #endif
 
-- 
1.7.10.4
