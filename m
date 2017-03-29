From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: bridge: netfilter: Comparison to NULL could be written
Date: Wed, 29 Mar 2017 12:05:20 +0530
Message-ID: <20170329063520.GA21948@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Stephen Hemminger <stephen@networkplumber.org>,
        davem@davemloft.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, bridge@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style for null comparisons to be more
consistant with the rest of the kernel coding style.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/bridge/netfilter/ebt_among.c         | 12 ++++++------
 net/bridge/netfilter/ebt_arp.c           | 10 +++++-----
 net/bridge/netfilter/ebt_arpreply.c      |  8 ++++----
 net/bridge/netfilter/ebt_ip.c            |  4 ++--
 net/bridge/netfilter/ebt_ip6.c           |  4 ++--
 net/bridge/netfilter/ebt_log.c           | 10 +++++-----
 net/bridge/netfilter/ebt_snat.c          |  2 +-
 net/bridge/netfilter/ebt_stp.c           |  4 ++--
 net/bridge/netfilter/ebt_vlan.c          |  2 +-
 net/bridge/netfilter/ebtables.c          | 18 ++++++++++--------
 net/bridge/netfilter/nf_tables_bridge.c  |  2 +-
 net/bridge/netfilter/nft_meta_bridge.c   |  6 +++---
 net/bridge/netfilter/nft_reject_bridge.c |  4 ++--
 13 files changed, 44 insertions(+), 42 deletions(-)

diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 279527f8b1fe..7c5f435c2f87 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -74,7 +74,7 @@ static int get_ip_dst(const struct sk_buff *skb, __be32 *addr)
 		struct iphdr _iph;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
-		if (ih == NULL)
+		if (!ih)
 			return -1;
 		*addr = ih->daddr;
 	} else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
@@ -84,14 +84,14 @@ static int get_ip_dst(const struct sk_buff *skb, __be32 *addr)
 		__be32 buf;
 
 		ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
-		if (ah == NULL ||
+		if (!ah ||
 		    ah->ar_pln != sizeof(__be32) ||
 		    ah->ar_hln != ETH_ALEN)
 			return -1;
 		bp = skb_header_pointer(skb, sizeof(struct arphdr) +
 					2 * ETH_ALEN + sizeof(__be32),
 					sizeof(__be32), &buf);
-		if (bp == NULL)
+		if (!bp)
 			return -1;
 		*addr = *bp;
 	}
@@ -105,7 +105,7 @@ static int get_ip_src(const struct sk_buff *skb, __be32 *addr)
 		struct iphdr _iph;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
-		if (ih == NULL)
+		if (!ih)
 			return -1;
 		*addr = ih->saddr;
 	} else if (eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
@@ -115,13 +115,13 @@ static int get_ip_src(const struct sk_buff *skb, __be32 *addr)
 		__be32 buf;
 
 		ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
-		if (ah == NULL ||
+		if (!ah ||
 		    ah->ar_pln != sizeof(__be32) ||
 		    ah->ar_hln != ETH_ALEN)
 			return -1;
 		bp = skb_header_pointer(skb, sizeof(struct arphdr) +
 					ETH_ALEN, sizeof(__be32), &buf);
-		if (bp == NULL)
+		if (!bp)
 			return -1;
 		*addr = *bp;
 	}
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index 227142282b45..ac1ec9458d73 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -23,7 +23,7 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct arphdr _arph;
 
 	ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
-	if (ah == NULL)
+	if (!ah)
 		return false;
 	if ((info->bitmask & EBT_ARP_OPCODE) &&
 	    NF_INVF(info, EBT_ARP_OPCODE, info->opcode != ah->ar_op))
@@ -44,12 +44,12 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		sap = skb_header_pointer(skb, sizeof(struct arphdr) +
 					ah->ar_hln, sizeof(saddr),
 					&saddr);
-		if (sap == NULL)
+		if (!sap)
 			return false;
 		dap = skb_header_pointer(skb, sizeof(struct arphdr) +
 					2*ah->ar_hln+sizeof(saddr),
 					sizeof(daddr), &daddr);
-		if (dap == NULL)
+		if (!dap)
 			return false;
 		if ((info->bitmask & EBT_ARP_SRC_IP) &&
 		    NF_INVF(info, EBT_ARP_SRC_IP,
@@ -73,7 +73,7 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		if (info->bitmask & EBT_ARP_SRC_MAC) {
 			mp = skb_header_pointer(skb, sizeof(struct arphdr),
 						sizeof(_mac), &_mac);
-			if (mp == NULL)
+			if (!mp)
 				return false;
 			if (NF_INVF(info, EBT_ARP_SRC_MAC,
 				    !ether_addr_equal_masked(mp, info->smaddr,
@@ -85,7 +85,7 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			mp = skb_header_pointer(skb, sizeof(struct arphdr) +
 						ah->ar_hln + ah->ar_pln,
 						sizeof(_mac), &_mac);
-			if (mp == NULL)
+			if (!mp)
 				return false;
 			if (NF_INVF(info, EBT_ARP_DST_MAC,
 				    !ether_addr_equal_masked(mp, info->dmaddr,
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index 5929309beaa1..1efc0faf9f4c 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -27,7 +27,7 @@ ebt_arpreply_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	unsigned char _sha[ETH_ALEN];
 
 	ap = skb_header_pointer(skb, 0, sizeof(_ah), &_ah);
-	if (ap == NULL)
+	if (!ap)
 		return EBT_DROP;
 
 	if (ap->ar_op != htons(ARPOP_REQUEST) ||
@@ -37,18 +37,18 @@ ebt_arpreply_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		return EBT_CONTINUE;
 
 	shp = skb_header_pointer(skb, sizeof(_ah), ETH_ALEN, &_sha);
-	if (shp == NULL)
+	if (!shp)
 		return EBT_DROP;
 
 	siptr = skb_header_pointer(skb, sizeof(_ah) + ETH_ALEN,
 				   sizeof(_sip), &_sip);
-	if (siptr == NULL)
+	if (!siptr)
 		return EBT_DROP;
 
 	diptr = skb_header_pointer(skb,
 				   sizeof(_ah) + 2 * ETH_ALEN + sizeof(_sip),
 				   sizeof(_dip), &_dip);
-	if (diptr == NULL)
+	if (!diptr)
 		return EBT_DROP;
 
 	arp_send(ARPOP_REPLY, ETH_P_ARP, *siptr,
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index d06968bdf5ec..d807096a5d53 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -34,7 +34,7 @@ ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct tcpudphdr _ports;
 
 	ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
-	if (ih == NULL)
+	if (!ih)
 		return false;
 	if ((info->bitmask & EBT_IP_TOS) &&
 	    NF_INVF(info, EBT_IP_TOS, info->tos != ih->tos))
@@ -57,7 +57,7 @@ ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return false;
 		pptr = skb_header_pointer(skb, ih->ihl*4,
 					  sizeof(_ports), &_ports);
-		if (pptr == NULL)
+		if (!pptr)
 			return false;
 		if (info->bitmask & EBT_IP_DPORT) {
 			u32 dst = ntohs(pptr->dst);
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 4617491be41e..e85c52517653 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -43,7 +43,7 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	union pkthdr _pkthdr;
 
 	ih6 = skb_header_pointer(skb, 0, sizeof(_ip6h), &_ip6h);
-	if (ih6 == NULL)
+	if (!ih6)
 		return false;
 	if ((info->bitmask & EBT_IP6_TCLASS) &&
 	    NF_INVF(info, EBT_IP6_TCLASS,
@@ -75,7 +75,7 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		/* min icmpv6 headersize is 4, so sizeof(_pkthdr) is ok. */
 		pptr = skb_header_pointer(skb, offset_ph, sizeof(_pkthdr),
 					  &_pkthdr);
-		if (pptr == NULL)
+		if (!pptr)
 			return false;
 		if (info->bitmask & EBT_IP6_DPORT) {
 			u16 dst = ntohs(pptr->tcpudphdr.dst);
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 98b9c8e8615e..1b48aabd9d1f 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -61,7 +61,7 @@ print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 
 		pptr = skb_header_pointer(skb, offset,
 					  sizeof(_ports), &_ports);
-		if (pptr == NULL) {
+		if (!pptr) {
 			printk(" INCOMPLETE TCP/UDP header");
 			return;
 		}
@@ -99,7 +99,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 		struct iphdr _iph;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
-		if (ih == NULL) {
+		if (!ih) {
 			printk(" INCOMPLETE IP header");
 			goto out;
 		}
@@ -119,7 +119,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 		int offset_ph;
 
 		ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
-		if (ih == NULL) {
+		if (!ih) {
 			printk(" INCOMPLETE IPv6 header");
 			goto out;
 		}
@@ -141,7 +141,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 		struct arphdr _arph;
 
 		ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
-		if (ah == NULL) {
+		if (!ah) {
 			printk(" INCOMPLETE ARP header");
 			goto out;
 		}
@@ -160,7 +160,7 @@ ebt_log_packet(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 			ap = skb_header_pointer(skb, sizeof(_arph),
 						sizeof(_arpp), &_arpp);
-			if (ap == NULL) {
+			if (!ap) {
 				printk(" INCOMPLETE ARP payload");
 				goto out;
 			}
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index e56ccd060d26..0158ed7aa354 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -31,7 +31,7 @@ ebt_snat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		struct arphdr _ah;
 
 		ap = skb_header_pointer(skb, 0, sizeof(_ah), &_ah);
-		if (ap == NULL)
+		if (!ap)
 			return EBT_DROP;
 		if (ap->ar_hln != ETH_ALEN)
 			goto out;
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 3140eb912d7e..d617c90c110b 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -125,7 +125,7 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const u8 header[6] = {0x42, 0x42, 0x03, 0x00, 0x00, 0x00};
 
 	sp = skb_header_pointer(skb, 0, sizeof(_stph), &_stph);
-	if (sp == NULL)
+	if (!sp)
 		return false;
 
 	/* The stp code only considers these */
@@ -143,7 +143,7 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 		st = skb_header_pointer(skb, sizeof(_stph),
 					sizeof(_stpc), &_stpc);
-		if (st == NULL)
+		if (!st)
 			return false;
 		return ebt_filter_config(info, st);
 	}
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 98c221dbf059..b9b9f2f06dce 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -53,7 +53,7 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		struct vlan_hdr _frame;
 
 		fp = skb_header_pointer(skb, 0, sizeof(_frame), &_frame);
-		if (fp == NULL)
+		if (!fp)
 			return false;
 
 		TCI = ntohs(fp->h_vlan_TCI);
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 79b69917f521..0f1647a3ec9c 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -596,7 +596,7 @@ ebt_cleanup_match(struct ebt_entry_match *m, struct net *net, unsigned int *i)
 	par.match     = m->u.match;
 	par.matchinfo = m->data;
 	par.family    = NFPROTO_BRIDGE;
-	if (par.match->destroy != NULL)
+	if (par.match->destroy)
 		par.match->destroy(&par);
 	module_put(par.match->me);
 	return 0;
@@ -614,7 +614,7 @@ ebt_cleanup_watcher(struct ebt_entry_watcher *w, struct net *net, unsigned int *
 	par.target   = w->u.watcher;
 	par.targinfo = w->data;
 	par.family   = NFPROTO_BRIDGE;
-	if (par.target->destroy != NULL)
+	if (par.target->destroy)
 		par.target->destroy(&par);
 	module_put(par.target->me);
 	return 0;
@@ -639,7 +639,7 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 	par.target   = t->u.target;
 	par.targinfo = t->data;
 	par.family   = NFPROTO_BRIDGE;
-	if (par.target->destroy != NULL)
+	if (par.target->destroy)
 		par.target->destroy(&par);
 	module_put(par.target->me);
 	return 0;
@@ -1166,9 +1166,11 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 	int ret, i, countersize;
 	void *p;
 
-	if (input_table == NULL || (repl = input_table->table) == NULL ||
-	    repl->entries == NULL || repl->entries_size == 0 ||
-	    repl->counters != NULL || input_table->private != NULL) {
+	repl = input_table->table;
+
+	if (!input_table || !repl || !repl->entries ||
+	    repl->entries_size == 0 || repl->counters ||
+	    input_table->private) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
 		return ERR_PTR(-EINVAL);
 	}
@@ -1889,7 +1891,7 @@ static int ebt_buf_count(struct ebt_entries_buf_state *state, unsigned int sz)
 static int ebt_buf_add(struct ebt_entries_buf_state *state,
 		       void *data, unsigned int sz)
 {
-	if (state->buf_kern_start == NULL)
+	if (!state->buf_kern_start)
 		goto count_only;
 
 	BUG_ON(state->buf_kern_offset + sz > state->buf_kern_len);
@@ -2121,7 +2123,7 @@ static int size_entry_mwt(struct ebt_entry *entry, const unsigned char *base,
 		}
 	}
 
-	if (state->buf_kern_start == NULL) {
+	if (!state->buf_kern_start) {
 		unsigned int offset = buf_start - (char *) base;
 
 		ret = xt_compat_add_offset(NFPROTO_BRIDGE, offset, new_offset);
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 97afdc0744e6..e4732567d097 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -57,7 +57,7 @@ static struct nft_af_info nft_af_bridge __read_mostly = {
 static int nf_tables_bridge_init_net(struct net *net)
 {
 	net->nft.bridge = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
-	if (net->nft.bridge == NULL)
+	if (!net->nft.bridge)
 		return -ENOMEM;
 
 	memcpy(net->nft.bridge, &nft_af_bridge, sizeof(nft_af_bridge));
diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 5974dbc1ea24..244a16254e33 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -29,11 +29,11 @@ static void nft_meta_bridge_get_eval(const struct nft_expr *expr,
 
 	switch (priv->key) {
 	case NFT_META_BRI_IIFNAME:
-		if (in == NULL || (p = br_port_get_rcu(in)) == NULL)
+		if (!in || !(p = br_port_get_rcu(in)))
 			goto err;
 		break;
 	case NFT_META_BRI_OIFNAME:
-		if (out == NULL || (p = br_port_get_rcu(out)) == NULL)
+		if (!out || !(p = br_port_get_rcu(out)))
 			goto err;
 		break;
 	default:
@@ -93,7 +93,7 @@ static const struct nft_expr_ops *
 nft_meta_bridge_select_ops(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
-	if (tb[NFTA_META_KEY] == NULL)
+	if (!tb[NFTA_META_KEY])
 		return ERR_PTR(-EINVAL);
 
 	if (tb[NFTA_META_DREG] && tb[NFTA_META_SREG])
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 206dc266ecd2..874f60df3260 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -381,14 +381,14 @@ static int nft_reject_bridge_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	if (tb[NFTA_REJECT_TYPE] == NULL)
+	if (!tb[NFTA_REJECT_TYPE])
 		return -EINVAL;
 
 	priv->type = ntohl(nla_get_be32(tb[NFTA_REJECT_TYPE]));
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
 	case NFT_REJECT_ICMPX_UNREACH:
-		if (tb[NFTA_REJECT_ICMP_CODE] == NULL)
+		if (!tb[NFTA_REJECT_ICMP_CODE])
 			return -EINVAL;
 
 		icmp_code = nla_get_u8(tb[NFTA_REJECT_ICMP_CODE]);
-- 
2.11.0
