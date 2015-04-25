From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 4/6] ipv6: netfilter: comparison for equality with NULL
Date: Sat, 25 Apr 2015 10:26:58 +0100
Message-ID: <1429954020-11763-5-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36729 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758808AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code uses a mixture of coding styles. In some instances check for NULL
pointer is done as x == NULL and sometimes as !x. !x is preferred
according to checkpatch and this patch makes the code consistent by
adopting the latter form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c                |  4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 18 +++++++++---------
 net/ipv6/netfilter/ip6t_ah.c                   |  2 +-
 net/ipv6/netfilter/ip6t_frag.c                 |  2 +-
 net/ipv6/netfilter/ip6t_hbh.c                  |  6 +++---
 net/ipv6/netfilter/ip6t_ipv6header.c           |  2 +-
 net/ipv6/netfilter/ip6t_mh.c                   |  2 +-
 net/ipv6/netfilter/ip6t_rt.c                   |  6 +++---
 net/ipv6/netfilter/ip6table_filter.c           |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  2 +-
 net/ipv6/netfilter/ip6table_nat.c              |  2 +-
 net/ipv6/netfilter/ip6table_raw.c              |  2 +-
 net/ipv6/netfilter/ip6table_security.c         |  2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  6 +++---
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 16 ++++++++--------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c               | 12 ++++++------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c            |  6 +++---
 net/ipv6/netfilter/nf_tables_ipv6.c            |  2 +-
 21 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1f8a503..ce8c529 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -927,7 +927,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	countersize = sizeof(struct xt_counters) * private->number;
 	counters = vzalloc(countersize);
 
-	if (counters == NULL)
+	if (!counters)
 		return ERR_PTR(-ENOMEM);
 
 	get_counters(private, counters);
@@ -2150,7 +2150,7 @@ icmp6_match(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 
 	ic = skb_header_pointer(skb, par->thoff, sizeof(_icmph), &_icmph);
-	if (ic == NULL) {
+	if (!ic) {
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 6edb7b1..0dd7123 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -59,7 +59,7 @@ synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
 	fl6.fl6_dport = nth->dest;
 	security_skb_classify_flow((struct sk_buff *)skb, flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
+	if (!dst || dst->error) {
 		dst_release(dst);
 		goto free_nskb;
 	}
@@ -97,7 +97,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -138,7 +138,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -183,7 +183,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -221,7 +221,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -280,7 +280,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 
 	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	if (!synproxy_parse_options(skb, par->thoff, th, &opts))
@@ -329,11 +329,11 @@ static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
 	int thoff;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (!ct)
 		return NF_ACCEPT;
 
 	synproxy = nfct_synproxy(ct);
-	if (synproxy == NULL)
+	if (!synproxy)
 		return NF_ACCEPT;
 
 	if (nf_is_loopback_packet(skb))
@@ -346,7 +346,7 @@ static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 
 	th = skb_header_pointer(skb, thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	state = &ct->proto.tcp;
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 04099ab..e504376 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -53,7 +53,7 @@ static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	ah = skb_header_pointer(skb, ptr, sizeof(_ah), &_ah);
-	if (ah == NULL) {
+	if (!ah) {
 		par->hotdrop = true;
 		return false;
 	}
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 3b5735e..0e14438 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -51,7 +51,7 @@ frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	fh = skb_header_pointer(skb, ptr, sizeof(_frag), &_frag);
-	if (fh == NULL) {
+	if (!fh) {
 		par->hotdrop = true;
 		return false;
 	}
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index 01df142..fc6af64 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -70,7 +70,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	oh = skb_header_pointer(skb, ptr, sizeof(_optsh), &_optsh);
-	if (oh == NULL) {
+	if (!oh) {
 		par->hotdrop = true;
 		return false;
 	}
@@ -107,7 +107,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 				break;
 			tp = skb_header_pointer(skb, ptr, sizeof(_opttype),
 						&_opttype);
-			if (tp == NULL)
+			if (!tp)
 				break;
 
 			/* Type check */
@@ -128,7 +128,7 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 				lp = skb_header_pointer(skb, ptr + 1,
 							sizeof(_optlen),
 							&_optlen);
-				if (lp == NULL)
+				if (!lp)
 					break;
 				spec_len = optinfo->opts[temp] & 0x00FF;
 
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 8b14744..c53ce69 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -65,7 +65,7 @@ ipv6header_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		}
 
 		hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
-		BUG_ON(hp == NULL);
+		BUG_ON(!hp);
 
 		/* Calculate the header length */
 		if (nexthdr == NEXTHDR_FRAGMENT)
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index 0c90c66..e3b4eb6 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -43,7 +43,7 @@ static bool mh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 
 	mh = skb_header_pointer(skb, par->thoff, sizeof(_mh), &_mh);
-	if (mh == NULL) {
+	if (!mh) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		pr_debug("Dropping evil MH tinygram.\n");
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index 2c99b94..bdab49e 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -57,7 +57,7 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	rh = skb_header_pointer(skb, ptr, sizeof(_route), &_route);
-	if (rh == NULL) {
+	if (!rh) {
 		par->hotdrop = true;
 		return false;
 	}
@@ -137,7 +137,7 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 							sizeof(_addr),
 							&_addr);
 
-				BUG_ON(ap == NULL);
+				BUG_ON(!ap);
 
 				if (ipv6_addr_equal(ap, &rtinfo->addrs[i])) {
 					pr_debug("i=%d temp=%d;\n", i, temp);
@@ -166,7 +166,7 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 							+ temp * sizeof(_addr),
 							sizeof(_addr),
 							&_addr);
-				BUG_ON(ap == NULL);
+				BUG_ON(!ap);
 
 				if (!ipv6_addr_equal(ap, &rtinfo->addrs[temp]))
 					break;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 5c33d8a..139b247 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -51,7 +51,7 @@ static int __net_init ip6table_filter_net_init(struct net *net)
 	struct ip6t_replace *repl;
 
 	repl = ip6t_alloc_initial_table(&packet_filter);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	/* Entry 1 is the FORWARD hook */
 	((struct ip6t_standard *)repl->entries)[1].target.verdict =
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index b551f5b..ff2ad69 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -95,7 +95,7 @@ static int __net_init ip6table_mangle_net_init(struct net *net)
 	struct ip6t_replace *repl;
 
 	repl = ip6t_alloc_initial_table(&packet_mangler);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	net->ipv6.ip6table_mangle =
 		ip6t_register_table(net, &packet_mangler, repl);
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index c3a7f7a..87d6d3e 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -108,7 +108,7 @@ static int __net_init ip6table_nat_net_init(struct net *net)
 	struct ip6t_replace *repl;
 
 	repl = ip6t_alloc_initial_table(&nf_nat_ipv6_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	net->ipv6.ip6table_nat = ip6t_register_table(net, &nf_nat_ipv6_table, repl);
 	kfree(repl);
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 0b33caa..761ae0c 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -34,7 +34,7 @@ static int __net_init ip6table_raw_net_init(struct net *net)
 	struct ip6t_replace *repl;
 
 	repl = ip6t_alloc_initial_table(&packet_raw);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	net->ipv6.ip6table_raw =
 		ip6t_register_table(net, &packet_raw, repl);
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index fcef83c..544e15b 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -52,7 +52,7 @@ static int __net_init ip6table_security_net_init(struct net *net)
 	struct ip6t_replace *repl;
 
 	repl = ip6t_alloc_initial_table(&security_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	net->ipv6.ip6table_security =
 		ip6t_register_table(net, &security_table, repl);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4ba0c34..59c29a2 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -42,7 +42,7 @@ static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 
 	ap = skb_header_pointer(skb, nhoff + offsetof(struct ipv6hdr, saddr),
 				sizeof(_addrs), _addrs);
-	if (ap == NULL)
+	if (!ap)
 		return false;
 
 	memcpy(tuple->src.u3.ip6, ap, sizeof(tuple->src.u3.ip6));
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 1f5b350..b6cd77b 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -42,7 +42,7 @@ static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 	struct icmp6hdr _hdr;
 
 	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
-	if (hp == NULL)
+	if (!hp)
 		return false;
 	tuple->dst.u.icmp.type = hp->icmp6_type;
 	tuple->src.u.icmp.id = hp->icmp6_identifier;
@@ -152,7 +152,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	const struct nf_conntrack_l4proto *inproto;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
 
-	NF_CT_ASSERT(skb->nfct == NULL);
+	NF_CT_ASSERT(!skb->nfct);
 
 	/* Are they talking about one of our connections? */
 	if (!nf_ct_get_tuplepr(skb,
@@ -202,7 +202,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	int type;
 
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
-	if (icmp6h == NULL) {
+	if (!icmp6h) {
 		if (LOG_INVALID(net, IPPROTO_ICMPV6))
 			nf_log_packet(net, PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: short packet ");
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index a7f6977..51478de 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -103,7 +103,7 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(nf_ct_frag6_sysctl_table),
 				GFP_KERNEL);
-		if (table == NULL)
+		if (!table)
 			goto err_alloc;
 
 		table[0].data = &net->nf_frag.frags.timeout;
@@ -115,7 +115,7 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	}
 
 	hdr = register_net_sysctl(net, "net/netfilter", table);
-	if (hdr == NULL)
+	if (!hdr)
 		goto err_reg;
 
 	net->nf_frag.sysctl.frags_hdr = hdr;
@@ -384,7 +384,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 
 	inet_frag_kill(&fq->q, &nf_frags);
 
-	WARN_ON(head == NULL);
+	WARN_ON(!head);
 	WARN_ON(NFCT_FRAG6_CB(head)->offset != 0);
 
 	ecn = ip_frag_ecn_table[fq->ecn];
@@ -414,7 +414,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 		int i, plen = 0;
 
 		clone = alloc_skb(0, GFP_ATOMIC);
-		if (clone == NULL)
+		if (!clone)
 			goto out_oom;
 
 		clone->next = head->next;
@@ -475,7 +475,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net_device *dev)
 
 	/* all original skbs are linked into the NFCT_FRAG6_CB(head).orig */
 	fp = skb_shinfo(head)->frag_list;
-	if (fp && NFCT_FRAG6_CB(fp)->orig == NULL)
+	if (fp && !NFCT_FRAG6_CB(fp)->orig)
 		/* at above code, head skb is divided into two skbs. */
 		fp = fp->next;
 
@@ -586,7 +586,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 		return skb;
 
 	clone = skb_clone(skb, GFP_ATOMIC);
-	if (clone == NULL) {
+	if (!clone) {
 		pr_debug("Can't clone skb\n");
 		return skb;
 	}
@@ -604,7 +604,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     ip6_frag_ecn(hdr));
-	if (fq == NULL) {
+	if (!fq) {
 		pr_debug("Can't find and can't create new queue\n");
 		goto ret_orig;
 	}
@@ -621,7 +621,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
 		ret_skb = nf_ct_frag6_reasm(fq, dev);
-		if (ret_skb == NULL)
+		if (!ret_skb)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
 	spin_unlock_bh(&fq->q.lock);
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index a45db0b..16dd024 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -66,7 +66,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(ops->hooknum, skb));
 	/* queued */
-	if (reasm == NULL)
+	if (!reasm)
 		return NF_STOLEN;
 
 	/* error occurred or not fragmented */
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 8dd8696..35166a2 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -55,7 +55,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 		logflags = NF_LOG_MASK;
 
 	ih = skb_header_pointer(skb, ip6hoff, sizeof(_ip6h), &_ip6h);
-	if (ih == NULL) {
+	if (!ih) {
 		nf_log_buf_add(m, "TRUNCATED");
 		return;
 	}
@@ -78,7 +78,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 		const struct ipv6_opt_hdr *hp;
 
 		hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
-		if (hp == NULL) {
+		if (!hp) {
 			nf_log_buf_add(m, "TRUNCATED");
 			return;
 		}
@@ -95,7 +95,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 			nf_log_buf_add(m, "FRAG:");
 			fh = skb_header_pointer(skb, ptr, sizeof(_fhdr),
 						&_fhdr);
-			if (fh == NULL) {
+			if (!fh) {
 				nf_log_buf_add(m, "TRUNCATED ");
 				return;
 			}
@@ -143,7 +143,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 
 				ah = skb_header_pointer(skb, ptr, sizeof(_ahdr),
 							&_ahdr);
-				if (ah == NULL) {
+				if (!ah) {
 					/*
 					 * Max length: 26 "INCOMPLETE [65535
 					 *  bytes] )"
@@ -178,7 +178,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 				 */
 				eh = skb_header_pointer(skb, ptr, sizeof(_esph),
 							&_esph);
-				if (eh == NULL) {
+				if (!eh) {
 					nf_log_buf_add(m, "INCOMPLETE [%u bytes] )",
 						       skb->len - ptr);
 					return;
@@ -224,7 +224,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		ic = skb_header_pointer(skb, ptr, sizeof(_icmp6h), &_icmp6h);
-		if (ic == NULL) {
+		if (!ic) {
 			nf_log_buf_add(m, "INCOMPLETE [%u bytes] ",
 				       skb->len - ptr);
 			return;
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index e76900e..4f78aab 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -291,7 +291,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	nat = nf_ct_nat_ext_add(ct);
-	if (nat == NULL)
+	if (!nat)
 		return NF_ACCEPT;
 
 	switch (ctinfo) {
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 5629db8..6603ae6 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -45,7 +45,7 @@ const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
 
 	otcph = skb_header_pointer(oldskb, tcphoff, sizeof(struct tcphdr),
 				   otcph);
-	if (otcph == NULL)
+	if (!otcph)
 		return NULL;
 
 	/* No RST for RST. */
@@ -159,7 +159,7 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 	fl6.fl6_dport = otcph->source;
 	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
+	if (!dst || dst->error) {
 		dst_release(dst);
 		return;
 	}
@@ -238,7 +238,7 @@ void nf_send_unreach6(struct net *net, struct sk_buff *skb_in,
 	if (!reject6_csum_ok(skb_in, hooknum))
 		return;
 
-	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
+	if (hooknum == NF_INET_LOCAL_OUT && !skb_in->dev)
 		skb_in->dev = net->loopback_dev;
 
 	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index c8148ba..f484f97 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -61,7 +61,7 @@ EXPORT_SYMBOL_GPL(nft_af_ipv6);
 static int nf_tables_ipv6_init_net(struct net *net)
 {
 	net->nft.ipv6 = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
-	if (net->nft.ipv6 == NULL)
+	if (!net->nft.ipv6)
 		return -ENOMEM;
 
 	memcpy(net->nft.ipv6, &nft_af_ipv6, sizeof(nft_af_ipv6));
-- 
1.9.1
