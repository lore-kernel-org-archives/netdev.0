From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 2/2] ipv6: netfilter: Simplify NULL comparisons
Date: Sat,  1 Apr 2017 21:43:20 +0530
Message-ID: <20170401161320.8247-3-arushisinghal19971997@gmail.com>
References: <20170401161320.8247-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170401161320.8247-1-arushisinghal19971997@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove instances of explicit NULL comparisons for code compaction.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 16 ++++++++--------
 net/ipv6/netfilter/ip6t_ipv6header.c           |  2 +-
 net/ipv6/netfilter/ip6table_filter.c           |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  2 +-
 net/ipv6/netfilter/ip6table_nat.c              |  2 +-
 net/ipv6/netfilter/ip6table_raw.c              |  2 +-
 net/ipv6/netfilter/ip6table_security.c         |  2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 12 ++++++------
 net/ipv6/netfilter/nf_dup_ipv6.c               |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c               | 12 ++++++------
 net/ipv6/netfilter/nf_reject_ipv6.c            |  4 ++--
 net/ipv6/netfilter/nf_socket_ipv6.c            |  8 ++++----
 net/ipv6/netfilter/nf_tables_ipv6.c            |  2 +-
 net/ipv6/netfilter/nft_dup_ipv6.c              |  2 +-
 16 files changed, 38 insertions(+), 38 deletions(-)

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
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 8b147440fbdc..c53ce6928130 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -65,7 +65,7 @@ ipv6header_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		}
 
 		hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
-		BUG_ON(hp == NULL);
+		BUG_ON(!hp);
 
 		/* Calculate the header length */
 		if (nexthdr == NEXTHDR_FRAGMENT)
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
index 2b1a9dcdbcb3..7d7ed25ff568 100644
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
index 4e3402486833..b88b98105c61 100644
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
index d2c2ccbfbe72..46892d085c25 100644
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
index 986d4ca38832..042bcbb11f00 100644
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
@@ -279,7 +279,7 @@ static int nf_ct_frag6_queue(struct frag_queue *fq, struct sk_buff *skb,
 		goto err;
 
 	/* Point into the IP datagram 'data' part. */
-	if (!pskb_pull(skb, (u8 *) (fhdr + 1) - skb->data)) {
+	if (!pskb_pull(skb, (u8 *)(fhdr + 1) - skb->data)) {
 		pr_debug("queue: message is too short.\n");
 		goto err;
 	}
@@ -379,7 +379,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 
 	inet_frag_kill(&fq->q, &nf_frags);
 
-	WARN_ON(head == NULL);
+	WARN_ON(!head);
 	WARN_ON(NFCT_FRAG6_CB(head)->offset != 0);
 
 	ecn = ip_frag_ecn_table[fq->ecn];
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
index 97c724224da7..d8a88b81893b 100644
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
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index eedee5d108d9..c97ed15df5c2 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -44,7 +44,7 @@ const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
 
 	otcph = skb_header_pointer(oldskb, tcphoff, sizeof(struct tcphdr),
 				   otcph);
-	if (otcph == NULL)
+	if (!otcph)
 		return NULL;
 
 	/* No RST for RST. */
@@ -241,7 +241,7 @@ void nf_send_unreach6(struct net *net, struct sk_buff *skb_in,
 	if (!reject6_csum_ok(skb_in, hooknum))
 		return;
 
-	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
+	if (hooknum == NF_INET_LOCAL_OUT && !skb_in->dev)
 		skb_in->dev = net->loopback_dev;
 
 	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
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
