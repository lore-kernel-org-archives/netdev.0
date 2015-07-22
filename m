From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/10] ipvs: call skb_sender_cpu_clear
Date: Thu, 23 Jul 2015 01:00:50 +0200
Message-ID: <1437606052-5179-9-git-send-email-pablo@netfilter.org>
References: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54447 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbbGVWz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:27 -0400
In-Reply-To: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Reset XPS's sender_cpu on forwarding.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 34dc142..258a0b0 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -529,6 +529,8 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (ret == NF_ACCEPT) {
 		nf_reset(skb);
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 	}
 	return ret;
 }
@@ -569,6 +571,8 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 
 	if (!local) {
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
@@ -589,6 +593,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (!local) {
 		ip_vs_drop_early_demux_sk(skb);
 		skb_forward_csum(skb);
+		if (!skb->sk)
+			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
-- 
1.7.10.4
