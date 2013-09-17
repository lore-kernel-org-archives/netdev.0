From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: nf_nat_proto_icmpv6:: fix wrong comparison in icmpv6_manip_pkt
Date: Wed, 18 Sep 2013 00:07:29 +0200
Message-ID: <1379455654-3905-3-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34724 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab3IQWIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:07 -0400
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>

In commit 58a317f1 (netfilter: ipv6: add IPv6 NAT support), icmpv6_manip_pkt
was added with an incorrect comparison of ICMP codes to types.  This causes
problems when using NAT rules with the --random option.  Correct the
comparison.

This closes netfilter bugzilla #851, reported by Alexander Neumann.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
index 61aaf70..2205e8e 100644
--- a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
@@ -69,8 +69,8 @@ icmpv6_manip_pkt(struct sk_buff *skb,
 	hdr = (struct icmp6hdr *)(skb->data + hdroff);
 	l3proto->csum_update(skb, iphdroff, &hdr->icmp6_cksum,
 			     tuple, maniptype);
-	if (hdr->icmp6_code == ICMPV6_ECHO_REQUEST ||
-	    hdr->icmp6_code == ICMPV6_ECHO_REPLY) {
+	if (hdr->icmp6_type == ICMPV6_ECHO_REQUEST ||
+	    hdr->icmp6_type == ICMPV6_ECHO_REPLY) {
 		inet_proto_csum_replace2(&hdr->icmp6_cksum, skb,
 					 hdr->icmp6_identifier,
 					 tuple->src.u.icmp.id, 0);
-- 
1.7.10.4
