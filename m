From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] ipv4: netfilter: Comparison to NULL could be written
Date: Sat, 1 Apr 2017 14:05:21 +0530
Message-ID: <20170401083520.GA2037@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style for null comparisons to be more
consistant with the rest of the kernel coding style.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv4/netfilter/arp_tables.c                |  2 +-
 net/ipv4/netfilter/arptable_filter.c           |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 16 ++++++++--------
 net/ipv4/netfilter/iptable_filter.c            |  2 +-
 net/ipv4/netfilter/iptable_mangle.c            |  2 +-
 net/ipv4/netfilter/iptable_nat.c               |  2 +-
 net/ipv4/netfilter/iptable_raw.c               |  2 +-
 net/ipv4/netfilter/iptable_security.c          |  2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 ++--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  4 ++--
 net/ipv4/netfilter/nf_dup_ipv4.c               |  2 +-
 net/ipv4/netfilter/nf_log_arp.c                |  4 ++--
 net/ipv4/netfilter/nf_log_ipv4.c               | 10 +++++-----
 net/ipv4/netfilter/nf_nat_snmp_basic.c         | 22 +++++++++++-----------
 net/ipv4/netfilter/nf_reject_ipv4.c            |  2 +-
 net/ipv4/netfilter/nf_socket_ipv4.c            |  8 ++++----
 net/ipv4/netfilter/nf_tables_arp.c             |  2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c            |  2 +-
 net/ipv4/netfilter/nft_dup_ipv4.c              |  2 +-
 20 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 6241a81fd7f5..7a35f3070fce 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -653,7 +653,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
 	countersize = sizeof(struct xt_counters) * private->number;
 	counters = vzalloc(countersize);
 
-	if (counters == NULL)
+	if (!counters)
 		return ERR_PTR(-ENOMEM);
 
 	get_counters(private, counters);
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 8f8713b4388f..1e44006215d1 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -47,7 +47,7 @@ static int __net_init arptable_filter_table_init(struct net *net)
 		return 0;
 
 	repl = arpt_alloc_initial_table(&packet_filter);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	err = arpt_register_table(net, &packet_filter, repl, arpfilter_ops,
 				  &net->ipv4.arptable_filter);
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 52f26459efc3..559a783d5b3f 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -328,7 +328,7 @@ clusterip_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	 * that the ->target() function isn't called after ->destroy() */
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (!ct)
 		return NF_DROP;
 
 	/* special case: ICMP error handling. conntrack distinguishes between
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 3240a2614e82..10c970e32d5e 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -84,7 +84,7 @@ synproxy_send_client_synack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -126,7 +126,7 @@ synproxy_send_server_syn(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -171,7 +171,7 @@ synproxy_send_server_ack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -209,7 +209,7 @@ synproxy_send_client_ack(struct net *net,
 	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
 	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + MAX_TCP_HEADER,
 			 GFP_ATOMIC);
-	if (nskb == NULL)
+	if (!nskb)
 		return;
 	skb_reserve(nskb, MAX_TCP_HEADER);
 
@@ -271,7 +271,7 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 		return NF_DROP;
 
 	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	if (!synproxy_parse_options(skb, par->thoff, th, &opts))
@@ -319,11 +319,11 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 	unsigned int thoff;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (!ct)
 		return NF_ACCEPT;
 
 	synproxy = nfct_synproxy(ct);
-	if (synproxy == NULL)
+	if (!synproxy)
 		return NF_ACCEPT;
 
 	if (nf_is_loopback_packet(skb))
@@ -331,7 +331,7 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 
 	thoff = ip_hdrlen(skb);
 	th = skb_header_pointer(skb, thoff, sizeof(_th), &_th);
-	if (th == NULL)
+	if (!th)
 		return NF_DROP;
 
 	state = &ct->proto.tcp;
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 7667f223d7f8..83983c7c156d 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -62,7 +62,7 @@ static int __net_init iptable_filter_table_init(struct net *net)
 		return 0;
 
 	repl = ipt_alloc_initial_table(&packet_filter);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	/* Entry 1 is the FORWARD hook */
 	((struct ipt_standard *)repl->entries)[1].target.verdict =
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index aebdb337fd7e..64a6d0c531d7 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -100,7 +100,7 @@ static int __net_init iptable_mangle_table_init(struct net *net)
 		return 0;
 
 	repl = ipt_alloc_initial_table(&packet_mangler);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ipt_register_table(net, &packet_mangler, repl, mangle_ops,
 				 &net->ipv4.iptable_mangle);
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 138a24bc76ad..b7c9317fbae0 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -107,7 +107,7 @@ static int __net_init iptable_nat_table_init(struct net *net)
 		return 0;
 
 	repl = ipt_alloc_initial_table(&nf_nat_ipv4_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ipt_register_table(net, &nf_nat_ipv4_table, repl,
 				 nf_nat_ipv4_ops, &net->ipv4.nat_table);
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 2642ecd2645c..691c807b8afa 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -46,7 +46,7 @@ static int __net_init iptable_raw_table_init(struct net *net)
 		return 0;
 
 	repl = ipt_alloc_initial_table(&packet_raw);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ipt_register_table(net, &packet_raw, repl, rawtable_ops,
 				 &net->ipv4.iptable_raw);
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index ff226596e4b5..578de5ca922a 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -63,7 +63,7 @@ static int __net_init iptable_security_table_init(struct net *net)
 		return 0;
 
 	repl = ipt_alloc_initial_table(&security_table);
-	if (repl == NULL)
+	if (!repl)
 		return -ENOMEM;
 	ret = ipt_register_table(net, &security_table, repl, sectbl_ops,
 				 &net->ipv4.iptable_security);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2e14ed11a35c..670b65947e54 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -45,7 +45,7 @@ static bool ipv4_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 	__be32 _addrs[2];
 	ap = skb_header_pointer(skb, nhoff + offsetof(struct iphdr, saddr),
 				sizeof(u_int32_t) * 2, _addrs);
-	if (ap == NULL)
+	if (!ap)
 		return false;
 
 	tuple->src.u3.ip = ap[0];
@@ -77,7 +77,7 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	struct iphdr _iph;
 
 	iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
-	if (iph == NULL)
+	if (!iph)
 		return -NF_ACCEPT;
 
 	/* Conntrack defragments packets, we might still see fragments
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 73c591d8a9a8..fc4b89f23a96 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -36,7 +36,7 @@ static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 	struct icmphdr _hdr;
 
 	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
-	if (hp == NULL)
+	if (!hp)
 		return false;
 
 	tuple->dst.u.icmp.type = hp->type;
@@ -187,7 +187,7 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 
 	/* Not enough header? */
 	icmph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_ih), &_ih);
-	if (icmph == NULL) {
+	if (!icmph) {
 		if (LOG_INVALID(net, IPPROTO_ICMP))
 			nf_log_packet(net, PF_INET, 0, skb, NULL, NULL,
 				      NULL, "nf_ct_icmp: short packet ");
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index f0dbff05fc28..1c95300b5a8b 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -63,7 +63,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	 * happened. The copy should be independently delivered to the gateway.
 	 */
 	skb = pskb_copy(skb, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index 2f3895ddc275..88104f102b9e 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -52,7 +52,7 @@ static void dump_arp_packet(struct nf_log_buf *m,
 	struct arppayload _arpp;
 
 	ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
-	if (ah == NULL) {
+	if (!ah) {
 		nf_log_buf_add(m, "TRUNCATED");
 		return;
 	}
@@ -68,7 +68,7 @@ static void dump_arp_packet(struct nf_log_buf *m,
 		return;
 
 	ap = skb_header_pointer(skb, sizeof(_arph), sizeof(_arpp), &_arpp);
-	if (ap == NULL) {
+	if (!ap) {
 		nf_log_buf_add(m, " INCOMPLETE [%zu bytes]",
 			       skb->len - sizeof(_arph));
 		return;
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index c83a9963269b..9099972bcdae 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -49,7 +49,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 		logflags = NF_LOG_DEFAULT_MASK;
 
 	ih = skb_header_pointer(skb, iphoff, sizeof(_iph), &_iph);
-	if (ih == NULL) {
+	if (!ih) {
 		nf_log_buf_add(m, "TRUNCATED");
 		return;
 	}
@@ -85,7 +85,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 		optsize = ih->ihl * 4 - sizeof(struct iphdr);
 		op = skb_header_pointer(skb, iphoff+sizeof(_iph),
 					optsize, _opt);
-		if (op == NULL) {
+		if (!op) {
 			nf_log_buf_add(m, "TRUNCATED");
 			return;
 		}
@@ -141,7 +141,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		ich = skb_header_pointer(skb, iphoff + ih->ihl * 4,
 					 sizeof(_icmph), &_icmph);
-		if (ich == NULL) {
+		if (!ich) {
 			nf_log_buf_add(m, "INCOMPLETE [%u bytes] ",
 				       skb->len - iphoff - ih->ihl*4);
 			break;
@@ -211,7 +211,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		ah = skb_header_pointer(skb, iphoff+ih->ihl*4,
 					sizeof(_ahdr), &_ahdr);
-		if (ah == NULL) {
+		if (!ah) {
 			nf_log_buf_add(m, "INCOMPLETE [%u bytes] ",
 				       skb->len - iphoff - ih->ihl*4);
 			break;
@@ -234,7 +234,7 @@ static void dump_ipv4_packet(struct nf_log_buf *m,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		eh = skb_header_pointer(skb, iphoff+ih->ihl*4,
 					sizeof(_esph), &_esph);
-		if (eh == NULL) {
+		if (!eh) {
 			nf_log_buf_add(m, "INCOMPLETE [%u bytes] ",
 				       skb->len - iphoff - ih->ihl*4);
 			break;
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index c9b52c361da2..890960552c97 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -273,7 +273,7 @@ static unsigned char asn1_eoc_decode(struct asn1_ctx *ctx, unsigned char *eoc)
 {
 	unsigned char ch;
 
-	if (eoc == NULL) {
+	if (!eoc) {
 		if (!asn1_octet_decode(ctx, &ch))
 			return 0;
 
@@ -401,7 +401,7 @@ static unsigned char asn1_octets_decode(struct asn1_ctx *ctx,
 	*len = 0;
 
 	*octets = kmalloc(eoc - ctx->pointer, GFP_ATOMIC);
-	if (*octets == NULL)
+	if (!*octets)
 		return 0;
 
 	ptr = *octets;
@@ -449,7 +449,7 @@ static unsigned char asn1_oid_decode(struct asn1_ctx *ctx,
 		return 0;
 
 	*oid = kmalloc(size * sizeof(unsigned long), GFP_ATOMIC);
-	if (*oid == NULL)
+	if (!*oid)
 		return 0;
 
 	optr = *oid;
@@ -721,7 +721,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			return 0;
 		}
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(id);
 			return 0;
 		}
@@ -734,7 +734,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			return 0;
 		}
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(p);
 			kfree(id);
 			return 0;
@@ -748,7 +748,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 	case SNMP_ENDOFMIBVIEW:
 		len = 0;
 		*obj = kmalloc(sizeof(struct snmp_object), GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(id);
 			return 0;
 		}
@@ -766,7 +766,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 		}
 		len *= sizeof(unsigned long);
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(lp);
 			kfree(id);
 			return 0;
@@ -785,7 +785,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			return 0;
 		}
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(p);
 			kfree(id);
 			return 0;
@@ -802,7 +802,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			return 0;
 		}
 		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-		if (*obj == NULL) {
+		if (!*obj) {
 			kfree(id);
 			return 0;
 		}
@@ -1045,7 +1045,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 		return 0;
 	if (cls != ASN1_UNI || con != ASN1_PRI || tag != ASN1_INT)
 		return 0;
-	if (!asn1_uint_decode (&ctx, end, &vers))
+	if (!asn1_uint_decode(&ctx, end, &vers))
 		return 0;
 	if (debug > 1)
 		pr_debug("bsalg: snmp version: %u\n", vers + 1);
@@ -1055,7 +1055,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 	/*
 	 * Community.
 	 */
-	if (!asn1_header_decode (&ctx, &end, &cls, &con, &tag))
+	if (!asn1_header_decode(&ctx, &end, &cls, &con, &tag))
 		return 0;
 	if (cls != ASN1_UNI || con != ASN1_PRI || tag != ASN1_OTS)
 		return 0;
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 146d86105183..ea1d860c0040 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -29,7 +29,7 @@ const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
 
 	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
 				 sizeof(struct tcphdr), _oth);
-	if (oth == NULL)
+	if (!oth)
 		return NULL;
 
 	/* No RST for RST. */
diff --git a/net/ipv4/netfilter/nf_socket_ipv4.c b/net/ipv4/netfilter/nf_socket_ipv4.c
index a83d558e1aae..777888e742f7 100644
--- a/net/ipv4/netfilter/nf_socket_ipv4.c
+++ b/net/ipv4/netfilter/nf_socket_ipv4.c
@@ -32,7 +32,7 @@ extract_icmp4_fields(const struct sk_buff *skb, u8 *protocol,
 
 	icmph = skb_header_pointer(skb, outside_hdrlen,
 				   sizeof(_icmph), &_icmph);
-	if (icmph == NULL)
+	if (!icmph)
 		return 1;
 
 	switch (icmph->type) {
@@ -49,7 +49,7 @@ extract_icmp4_fields(const struct sk_buff *skb, u8 *protocol,
 	inside_iph = skb_header_pointer(skb, outside_hdrlen +
 					sizeof(struct icmphdr),
 					sizeof(_inside_iph), &_inside_iph);
-	if (inside_iph == NULL)
+	if (!inside_iph)
 		return 1;
 
 	if (inside_iph->protocol != IPPROTO_TCP &&
@@ -60,7 +60,7 @@ extract_icmp4_fields(const struct sk_buff *skb, u8 *protocol,
 				   sizeof(struct icmphdr) +
 				   (inside_iph->ihl << 2),
 				   sizeof(_ports), &_ports);
-	if (ports == NULL)
+	if (!ports)
 		return 1;
 
 	/* the inside IP packet is the one quoted from our side, thus
@@ -112,7 +112,7 @@ struct sock *nf_sk_lookup_slow_v4(struct net *net, const struct sk_buff *skb,
 
 		hp = skb_header_pointer(skb, ip_hdrlen(skb),
 					sizeof(_hdr), &_hdr);
-		if (hp == NULL)
+		if (!hp)
 			return NULL;
 
 		protocol = iph->protocol;
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 805c8ddfe860..3634f0df42f7 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -41,7 +41,7 @@ static struct nft_af_info nft_af_arp __read_mostly = {
 static int nf_tables_arp_init_net(struct net *net)
 {
 	net->nft.arp = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
-	if (net->nft.arp== NULL)
+	if (!net->nft.arp)
 		return -ENOMEM;
 
 	memcpy(net->nft.arp, &nft_af_arp, sizeof(nft_af_arp));
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 2840a29b2e04..bedbd62ab755 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL_GPL(nft_af_ipv4);
 static int nf_tables_ipv4_init_net(struct net *net)
 {
 	net->nft.ipv4 = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
-	if (net->nft.ipv4 == NULL)
+	if (!net->nft.ipv4)
 		return -ENOMEM;
 
 	memcpy(net->nft.ipv4, &nft_af_ipv4, sizeof(nft_af_ipv4));
diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
index 0af3d8df70dd..362c4eaa8187 100644
--- a/net/ipv4/netfilter/nft_dup_ipv4.c
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -40,7 +40,7 @@ static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
 	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
 	int err;
 
-	if (tb[NFTA_DUP_SREG_ADDR] == NULL)
+	if (!tb[NFTA_DUP_SREG_ADDR])
 		return -EINVAL;
 
 	priv->sreg_addr = nft_parse_register(tb[NFTA_DUP_SREG_ADDR]);
-- 
2.11.0

