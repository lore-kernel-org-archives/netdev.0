From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/31: xtables: remove some goto
Date: Wed, 10 Jun 2009 21:46:33 +0200 (MEST)
Message-ID: <20090610194631.11112.42021.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33157 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761068AbZFJTqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:31 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9452258d8173806f67b1be5b3b00c39b052060c8
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 21:31:32 2009 +0200

    netfilter: xtables: remove some goto
    
    Combining two ifs, and goto is easily gone.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 82888bc..cfcb7af 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -359,15 +359,12 @@ ipt_do_table(struct sk_buff *skb,
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
 		if (!ip_packet_match(ip, indev, outdev,
-		    &e->ip, mtpar.fragoff)) {
- no_match:
+		    &e->ip, mtpar.fragoff) ||
+		    IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0) {
 			e = ipt_next_entry(e);
 			continue;
 		}
 
-		if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
-			goto no_match;
-
 		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
 
 		t = ipt_get_target(e);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index a6c2213..d01b8a3 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -386,15 +386,12 @@ ip6t_do_table(struct sk_buff *skb,
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
-		    &mtpar.thoff, &mtpar.fragoff, &hotdrop)) {
- no_match:
+		    &mtpar.thoff, &mtpar.fragoff, &hotdrop) ||
+		    IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0) {
 			e = ip6t_next_entry(e);
 			continue;
 		}
 
-		if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
-			goto no_match;
-
 		ADD_COUNTER(e->counters,
 			    ntohs(ipv6_hdr(skb)->payload_len) +
 			    sizeof(struct ipv6hdr), 1);
