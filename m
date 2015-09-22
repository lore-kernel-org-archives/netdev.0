From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 30/30] netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6
Date: Tue, 22 Sep 2015 11:14:20 +0200
Message-ID: <1442913260-3925-31-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

Use nf_ct_net(ct) instead of guessing that the netdevice out can
reliably report the network namespace the conntrack operation is
happening in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
index 7745609..31ba7ca 100644
--- a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
@@ -34,7 +34,7 @@ nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
 			    ctinfo == IP_CT_RELATED_REPLY));
 
-	if (ipv6_dev_get_saddr(dev_net(out), out,
+	if (ipv6_dev_get_saddr(nf_ct_net(ct), out,
 			       &ipv6_hdr(skb)->daddr, 0, &src) < 0)
 		return NF_DROP;
 
-- 
1.7.10.4

