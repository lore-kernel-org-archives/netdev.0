From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: ipv6: netfilter: replace explicit NULL comparison with
 ! operator
Date: Wed, 29 Mar 2017 11:22:21 +0530
Message-ID: <20170329055221.GA21064@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel@googlegroups.com,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace explicit NULL comparison with ! operator to simplify code.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/ip6_tables.c                |  4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 16 ++++++++--------
 net/ipv6/netfilter/ip6t_ah.c                   |  2 +-
 net/ipv6/netfilter/ip6t_frag.c                 |  2 +-
 net/ipv6/netfilter/ip6t_hbh.c                  |  6 +++---
 net/ipv6/netfilter/ip6t_mh.c                   |  2 +-
 net/ipv6/netfilter/ip6t_rt.c                   |  2 +-
 net/ipv6/netfilter/ip6table_filter.c           |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  2 +-
 net/ipv6/netfilter/ip6table_nat.c              |  2 +-
 net/ipv6/netfilter/ip6table_raw.c              |  2 +-
 net/ipv6/netfilter/ip6table_security.c         |  2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  8 ++++----
 net/ipv6/netfilter/nf_dup_ipv6.c               |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c               | 12 ++++++------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c            |  2 +-
 net/ipv6/netfilter/nf_socket_ipv6.c            |  8 ++++----
 net/ipv6/netfilter/nf_tables_ipv6.c            |  2 +-
 net/ipv6/netfilter/nft_dup_ipv6.c              |  2 +-
 22 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 754e911bdafd..b8cb61c27aa1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -830,7 +830,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	countersize = sizeof(struct xt_counters) * private->number;
 	counters = vzalloc(countersize);
 
-	if (counters == NULL)
+	if (!counters)
 		return ERR_PTR(-ENOMEM);
 
 	get_counters(private, counters);
@@ -1846,7 +1846,7 @@ icmp6_match(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 
 	ic = skb_header_pointer(skb, par->thoff, sizeof(_icmph), &_icmph);
-	if (ic == NULL) {
+	if (!ic) {
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 4ef1ddd4bbbd..e0fa78085ad7 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -98,7 +98,7 @@ synproxy_send_client_synack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -140,7 +140,7 @@ synproxy_send_server_syn(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -185,7 +185,7 @@ synproxy_send_server_ack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -223,7 +223,7 @@ synproxy_send_client_ack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -285,7 +285,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 
 	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	if (!synproxy_parse_options(skb, par->thoff, th, &opts))
@@ -335,11 +335,11 @@ static unsigned int ipv6_synproxy_hook(void *priv,
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
@@ -352,7 +352,7 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 		return NF_ACCEPT;
 
 	th = skb_header_pointer(skb, thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	state = &ct->proto.tcp;
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index dc6f03794815..7c15c727d7c9 100644
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
index 806989642ac3..b3485584b9b2 100644
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
index 5823349c7c6b..3e955fb0fc35 100644
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
 
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index a703367fd130..5b059faba707 100644
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
index cc9d33cfcf78..66919c18de3d 100644
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
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 1343077dde93..5c645fbf62ec 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -56,7 +56,7 @@ static int __net_init ip6table_filter_table_init(struct net *net)
 		return 0;
 
 	repl = ip6t_alloc_initial_table(&packet_filter);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	/* Entry 1 is the FORWARD hook */
 	((struct ip6t_standard *)repl->entries)[1].target.verdict =
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 84ea969aa630..a99445db23b3 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -96,7 +96,7 @@ static int __net_init ip6table_mangle_table_init(struct net *net)
 		return 0;
 
 	repl = ip6t_alloc_initial_table(&packet_mangler);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ip6t_register_table(net, &packet_mangler, repl, mangle_ops,
 				  &net->ipv6.ip6table_mangle);
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 7d2bd940291f..ec7f82a65a33 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -109,7 +109,7 @@ static int __net_init ip6table_nat_table_init(struct net *net)
 		return 0;
 
 	repl = ip6t_alloc_initial_table(&nf_nat_ipv6_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ip6t_register_table(net, &nf_nat_ipv6_table, repl,
 				  nf_nat_ipv6_ops, &net->ipv6.ip6table_nat);
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index d4bc56443dc1..39d61bc9f888 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -39,7 +39,7 @@ static int __net_init ip6table_raw_table_init(struct net *net)
 		return 0;
 
 	repl = ip6t_alloc_initial_table(&packet_raw);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ip6t_register_table(net, &packet_raw, repl, rawtable_ops,
 				  &net->ipv6.ip6table_raw);
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index cf26ccb04056..fad7d03e2553 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -56,7 +56,7 @@ static int __net_init ip6table_security_table_init(struct net *net)
 		return 0;
 
 	repl = ip6t_alloc_initial_table(&security_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ip6t_register_table(net, &security_table, repl, sectbl_ops,
 				  &net->ipv6.ip6table_security);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 3d3bc20952c7..92ad62f37ca5 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -49,7 +49,7 @@ static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 
 	ap = skb_header_pointer(skb, nhoff + offsetof(struct ipv6hdr, saddr),
 				sizeof(_addrs), _addrs);
-	if (ap == NULL)
+	if (!ap)
 		return false;
 
 	memcpy(tuple->src.u3.ip6, ap, sizeof(tuple->src.u3.ip6));
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 1bf81e07d8a0..bb8b7be8028e 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -43,7 +43,7 @@ static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 	struct icmp6hdr _hdr;
 
 	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
-	if (hp == NULL)
+	if (!hp)
 		return false;
 	tuple->dst.u.icmp.type = hp->icmp6_type;
 	tuple->src.u.icmp.id = hp->icmp6_identifier;
@@ -203,7 +203,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	int type;
 
 	icmp6h = skb_header_pointer(skb, dataoff, sizeof(_ih), &_ih);
-	if (icmp6h == NULL) {
+	if (!icmp6h) {
 		if (LOG_INVALID(net, IPPROTO_ICMPV6))
 			nf_log_packet(net, PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: short packet ");
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 986d4ca38832..fdde76e8a16a 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -102,7 +102,7 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(nf_ct_frag6_sysctl_table),
 				GFP_KERNEL);
-		if (table == NULL)
+		if (!table)
 			goto err_alloc;
 
 		table[0].data = &net->nf_frag.frags.timeout;
@@ -114,7 +114,7 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 	}
 
 	hdr = register_net_sysctl(net, "net/netfilter", table);
-	if (hdr == NULL)
+	if (!hdr)
 		goto err_reg;
 
 	net->nf_frag.sysctl.frags_hdr = hdr;
@@ -408,7 +408,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 		int i, plen = 0;
 
 		clone = alloc_skb(0, GFP_ATOMIC);
-		if (clone == NULL)
+		if (!clone)
 			return false;
 
 		clone->next = head->next;
@@ -592,7 +592,7 @@ int nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 user)
 	skb_orphan(skb);
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
 		     skb->dev ? skb->dev->ifindex : 0, ip6_frag_ecn(hdr));
-	if (fq == NULL) {
+	if (!fq) {
 		pr_debug("Can't find and can't create new queue\n");
 		return -ENOMEM;
 	}
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 888ecd106e5f..b77896b2a9bd 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -53,7 +53,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	if (this_cpu_read(nf_skb_duplicated))
 		return;
 	skb = pskb_copy(skb, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index e4e940b02b31..738f5a9a4508 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -55,7 +55,7 @@ static void dump_ipv6_packet(struct nf_log_buf *m,
 		logflags = NF_LOG_DEFAULT_MASK;
 
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
index e0be97e636a4..2ba570e54891 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -278,7 +278,7 @@ nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 		return NF_ACCEPT;
 
 	nat = nf_ct_nat_ext_add(ct);
-	if (nat == NULL)
+	if (!nat)
 		return NF_ACCEPT;
 
 	switch (ctinfo) {
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index eedee5d108d9..2f67aa4900ab 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -44,7 +44,7 @@ const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
 
 	otcph = skb_header_pointer(oldskb, tcphoff, sizeof(struct tcphdr),
 				   otcph);
-	if (otcph == NULL)
+	if (!otcph)
 		return NULL;
 
 	/* No RST for RST. */
diff --git a/net/ipv6/netfilter/nf_socket_ipv6.c b/net/ipv6/netfilter/nf_socket_ipv6.c
index ebb2bf84232a..e7e85795edec 100644
--- a/net/ipv6/netfilter/nf_socket_ipv6.c
+++ b/net/ipv6/netfilter/nf_socket_ipv6.c
@@ -41,7 +41,7 @@ extract_icmp6_fields(const struct sk_buff *skb,
 
 	icmph = skb_header_pointer(skb, outside_hdrlen,
 				   sizeof(_icmph), &_icmph);
-	if (icmph == NULL)
+	if (!icmph)
 		return 1;
 
 	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
@@ -49,7 +49,7 @@ extract_icmp6_fields(const struct sk_buff *skb,
 
 	inside_iph = skb_header_pointer(skb, outside_hdrlen + sizeof(_icmph),
 					sizeof(*ipv6_var), ipv6_var);
-	if (inside_iph == NULL)
+	if (!inside_iph)
 		return 1;
 	inside_nexthdr = inside_iph->nexthdr;
 
@@ -65,7 +65,7 @@ extract_icmp6_fields(const struct sk_buff *skb,
 
 	ports = skb_header_pointer(skb, inside_hdrlen,
 				   sizeof(_ports), &_ports);
-	if (ports == NULL)
+	if (!ports)
 		return 1;
 
 	/* the inside IP packet is the one quoted from our side, thus
@@ -119,7 +119,7 @@ struct sock *nf_sk_lookup_slow_v6(struct net *net, const struct sk_buff *skb,
 		struct udphdr _hdr, *hp;
 
 		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
-		if (hp == NULL)
+		if (!hp)
 			return NULL;
 
 		saddr = &iph->saddr;
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index d6e4ba5de916..7a3d1b5017a1 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -59,7 +59,7 @@ EXPORT_SYMBOL_GPL(nft_af_ipv6);
 static int nf_tables_ipv6_init_net(struct net *net)
 {
 	net->nft.ipv6 = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
-	if (net->nft.ipv6 == NULL)
+	if (!net->nft.ipv6)
 		return -ENOMEM;
 
 	memcpy(net->nft.ipv6, &nft_af_ipv6, sizeof(nft_af_ipv6));
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
index d8b5b60b7d53..2badafe43db9 100644
--- a/net/ipv6/netfilter/nft_dup_ipv6.c
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -38,7 +38,7 @@ static int nft_dup_ipv6_init(const struct nft_ctx *ctx,
 	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
 	int err;
 
-	if (tb[NFTA_DUP_SREG_ADDR] == NULL)
+	if (!tb[NFTA_DUP_SREG_ADDR])
 		return -EINVAL;
 
 	priv->sreg_addr = nft_parse_register(tb[NFTA_DUP_SREG_ADDR]);
-- 
2.11.0
