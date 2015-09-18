From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 15/15] netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6
Date: Fri, 18 Sep 2015 14:33:08 -0500
Message-ID: <1442604788-19718-15-git-send-email-ebiederm@xmission.com>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use nf_ct_net(ct) instead of guessing that the netdevice out can
reliably report the network namespace the conntrack operation is
happening in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
index 7745609665cd..31ba7ca19757 100644
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
2.2.1

