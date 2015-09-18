From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 14/14] netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6
Date: Fri, 18 Sep 2015 11:06:00 -0500
Message-ID: <1442592360-2575-14-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51487 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbIRQS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:18:56 -0400
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
