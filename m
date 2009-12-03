From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/08: net/ipv[46]/netfilter: Move && and || to end of previous line
Date: Thu,  3 Dec 2009 21:19:42 +0100 (MET)
Message-ID: <20091203201942.8831.70569.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 3666ed1c4837fd6906da0224c5373d7a2186a193
Author: Joe Perches <joe@perches.com>
Date:   Mon Nov 23 23:17:06 2009 +0100

    netfilter: net/ipv[46]/netfilter: Move && and || to end of previous line
    
    Compile tested only.
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 27774c9..0663276 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -384,11 +384,11 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 				|= ((1 << hook) | (1 << NF_ARP_NUMHOOKS));
 
 			/* Unconditional return/END. */
-			if ((e->target_offset == sizeof(struct arpt_entry)
-			    && (strcmp(t->target.u.user.name,
-				       ARPT_STANDARD_TARGET) == 0)
-			    && t->verdict < 0
-			    && unconditional(&e->arp)) || visited) {
+			if ((e->target_offset == sizeof(struct arpt_entry) &&
+			     (strcmp(t->target.u.user.name,
+				     ARPT_STANDARD_TARGET) == 0) &&
+			     t->verdict < 0 && unconditional(&e->arp)) ||
+			    visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
@@ -427,8 +427,8 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   ARPT_STANDARD_TARGET) == 0
-				    && newpos >= 0) {
+					   ARPT_STANDARD_TARGET) == 0 &&
+				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct arpt_entry)) {
 						duprintf("mark_source_chains: "
@@ -559,8 +559,8 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 {
 	unsigned int h;
 
-	if ((unsigned long)e % __alignof__(struct arpt_entry) != 0
-	    || (unsigned char *)e + sizeof(struct arpt_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct arpt_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct arpt_entry) >= limit) {
 		duprintf("Bad offset %p\n", e);
 		return -EINVAL;
 	}
@@ -1251,8 +1251,8 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	int ret, off, h;
 
 	duprintf("check_compat_entry_size_and_hooks %p\n", e);
-	if ((unsigned long)e % __alignof__(struct compat_arpt_entry) != 0
-	    || (unsigned char *)e + sizeof(struct compat_arpt_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct compat_arpt_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct compat_arpt_entry) >= limit) {
 		duprintf("Bad offset %p, limit = %p\n", e, limit);
 		return -EINVAL;
 	}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index cde755d..572330a 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -89,9 +89,9 @@ ip_packet_match(const struct iphdr *ip,
 #define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
 
 	if (FWINV((ip->saddr&ipinfo->smsk.s_addr) != ipinfo->src.s_addr,
-		  IPT_INV_SRCIP)
-	    || FWINV((ip->daddr&ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
-		     IPT_INV_DSTIP)) {
+		  IPT_INV_SRCIP) ||
+	    FWINV((ip->daddr&ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
+		  IPT_INV_DSTIP)) {
 		dprintf("Source or dest mismatch.\n");
 
 		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
@@ -122,8 +122,8 @@ ip_packet_match(const struct iphdr *ip,
 	}
 
 	/* Check specific protocol */
-	if (ipinfo->proto
-	    && FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO)) {
+	if (ipinfo->proto &&
+	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO)) {
 		dprintf("Packet protocol %hi does not match %hi.%s\n",
 			ip->protocol, ipinfo->proto,
 			ipinfo->invflags&IPT_INV_PROTO ? " (INV)":"");
@@ -246,11 +246,11 @@ get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
 	} else if (s == e) {
 		(*rulenum)++;
 
-		if (s->target_offset == sizeof(struct ipt_entry)
-		   && strcmp(t->target.u.kernel.target->name,
-			     IPT_STANDARD_TARGET) == 0
-		   && t->verdict < 0
-		   && unconditional(&s->ip)) {
+		if (s->target_offset == sizeof(struct ipt_entry) &&
+		    strcmp(t->target.u.kernel.target->name,
+			   IPT_STANDARD_TARGET) == 0 &&
+		   t->verdict < 0 &&
+		   unconditional(&s->ip)) {
 			/* Tail of chains: STANDARD target (return/policy) */
 			*comment = *chainname == hookname
 				? comments[NF_IP_TRACE_COMMENT_POLICY]
@@ -388,8 +388,8 @@ ipt_do_table(struct sk_buff *skb,
 				back = get_entry(table_base, back->comefrom);
 				continue;
 			}
-			if (table_base + v != ipt_next_entry(e)
-			    && !(e->ip.flags & IPT_F_GOTO)) {
+			if (table_base + v != ipt_next_entry(e) &&
+			    !(e->ip.flags & IPT_F_GOTO)) {
 				/* Save old back ptr in next entry */
 				struct ipt_entry *next = ipt_next_entry(e);
 				next->comefrom = (void *)back - table_base;
@@ -473,11 +473,11 @@ mark_source_chains(struct xt_table_info *newinfo,
 			e->comefrom |= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
-			if ((e->target_offset == sizeof(struct ipt_entry)
-			    && (strcmp(t->target.u.user.name,
-				       IPT_STANDARD_TARGET) == 0)
-			    && t->verdict < 0
-			    && unconditional(&e->ip)) || visited) {
+			if ((e->target_offset == sizeof(struct ipt_entry) &&
+			     (strcmp(t->target.u.user.name,
+				     IPT_STANDARD_TARGET) == 0) &&
+			     t->verdict < 0 && unconditional(&e->ip)) ||
+			    visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
@@ -524,8 +524,8 @@ mark_source_chains(struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   IPT_STANDARD_TARGET) == 0
-				    && newpos >= 0) {
+					   IPT_STANDARD_TARGET) == 0 &&
+				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct ipt_entry)) {
 						duprintf("mark_source_chains: "
@@ -735,8 +735,8 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 {
 	unsigned int h;
 
-	if ((unsigned long)e % __alignof__(struct ipt_entry) != 0
-	    || (unsigned char *)e + sizeof(struct ipt_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct ipt_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct ipt_entry) >= limit) {
 		duprintf("Bad offset %p\n", e);
 		return -EINVAL;
 	}
@@ -1548,8 +1548,8 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	int ret, off, h;
 
 	duprintf("check_compat_entry_size_and_hooks %p\n", e);
-	if ((unsigned long)e % __alignof__(struct compat_ipt_entry) != 0
-	    || (unsigned char *)e + sizeof(struct compat_ipt_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct compat_ipt_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct compat_ipt_entry) >= limit) {
 		duprintf("Bad offset %p, limit = %p\n", e, limit);
 		return -EINVAL;
 	}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 2e4f98b..40ca2d2 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -303,9 +303,9 @@ clusterip_tg(struct sk_buff *skb, const struct xt_target_param *par)
 
 	/* special case: ICMP error handling. conntrack distinguishes between
 	 * error messages (RELATED) and information requests (see below) */
-	if (ip_hdr(skb)->protocol == IPPROTO_ICMP
-	    && (ctinfo == IP_CT_RELATED
-		|| ctinfo == IP_CT_RELATED+IP_CT_IS_REPLY))
+	if (ip_hdr(skb)->protocol == IPPROTO_ICMP &&
+	    (ctinfo == IP_CT_RELATED ||
+	     ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY))
 		return XT_CONTINUE;
 
 	/* ip_conntrack_icmp guarantees us that we only have ICMP_ECHO,
@@ -362,8 +362,8 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 		return false;
 
 	}
-	if (e->ip.dmsk.s_addr != htonl(0xffffffff)
-	    || e->ip.dst.s_addr == 0) {
+	if (e->ip.dmsk.s_addr != htonl(0xffffffff) ||
+	    e->ip.dst.s_addr == 0) {
 		printk(KERN_ERR "CLUSTERIP: Please specify destination IP\n");
 		return false;
 	}
@@ -495,14 +495,14 @@ arp_mangle(unsigned int hook,
 	struct clusterip_config *c;
 
 	/* we don't care about non-ethernet and non-ipv4 ARP */
-	if (arp->ar_hrd != htons(ARPHRD_ETHER)
-	    || arp->ar_pro != htons(ETH_P_IP)
-	    || arp->ar_pln != 4 || arp->ar_hln != ETH_ALEN)
+	if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
+	    arp->ar_pro != htons(ETH_P_IP) ||
+	    arp->ar_pln != 4 || arp->ar_hln != ETH_ALEN)
 		return NF_ACCEPT;
 
 	/* we only want to mangle arp requests and replies */
-	if (arp->ar_op != htons(ARPOP_REPLY)
-	    && arp->ar_op != htons(ARPOP_REQUEST))
+	if (arp->ar_op != htons(ARPOP_REPLY) &&
+	    arp->ar_op != htons(ARPOP_REQUEST))
 		return NF_ACCEPT;
 
 	payload = (void *)(arp+1);
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index f7e2fa0..549e206 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -85,8 +85,8 @@ ecn_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		if (!set_ect_ip(skb, einfo))
 			return NF_DROP;
 
-	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR)
-	    && ip_hdr(skb)->protocol == IPPROTO_TCP)
+	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR) &&
+	    ip_hdr(skb)->protocol == IPPROTO_TCP)
 		if (!set_ect_tcp(skb, einfo))
 			return NF_DROP;
 
@@ -108,8 +108,8 @@ static bool ecn_tg_check(const struct xt_tgchk_param *par)
 			einfo->ip_ect);
 		return false;
 	}
-	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR))
-	    && (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
+	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR)) &&
+	    (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
 		printk(KERN_WARNING "ECN: cannot use TCP operations on a "
 		       "non-tcp rule\n");
 		return false;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index acc44c6..ee128ef 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -74,8 +74,8 @@ static void dump_packet(const struct nf_loginfo *info,
 	if (ntohs(ih->frag_off) & IP_OFFSET)
 		printk("FRAG:%u ", ntohs(ih->frag_off) & IP_OFFSET);
 
-	if ((logflags & IPT_LOG_IPOPT)
-	    && ih->ihl * 4 > sizeof(struct iphdr)) {
+	if ((logflags & IPT_LOG_IPOPT) &&
+	    ih->ihl * 4 > sizeof(struct iphdr)) {
 		const unsigned char *op;
 		unsigned char _opt[4 * 15 - sizeof(struct iphdr)];
 		unsigned int i, optsize;
@@ -146,8 +146,8 @@ static void dump_packet(const struct nf_loginfo *info,
 		/* Max length: 11 "URGP=65535 " */
 		printk("URGP=%u ", ntohs(th->urg_ptr));
 
-		if ((logflags & IPT_LOG_TCPOPT)
-		    && th->doff * 4 > sizeof(struct tcphdr)) {
+		if ((logflags & IPT_LOG_TCPOPT) &&
+		    th->doff * 4 > sizeof(struct tcphdr)) {
 			unsigned char _opt[4 * 15 - sizeof(struct tcphdr)];
 			const unsigned char *op;
 			unsigned int i, optsize;
@@ -238,9 +238,9 @@ static void dump_packet(const struct nf_loginfo *info,
 		printk("TYPE=%u CODE=%u ", ich->type, ich->code);
 
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
-		if (ich->type <= NR_ICMP_TYPES
-		    && required_len[ich->type]
-		    && skb->len-iphoff-ih->ihl*4 < required_len[ich->type]) {
+		if (ich->type <= NR_ICMP_TYPES &&
+		    required_len[ich->type] &&
+		    skb->len-iphoff-ih->ihl*4 < required_len[ich->type]) {
 			printk("INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
@@ -276,8 +276,8 @@ static void dump_packet(const struct nf_loginfo *info,
 			}
 
 			/* Max length: 10 "MTU=65535 " */
-			if (ich->type == ICMP_DEST_UNREACH
-			    && ich->code == ICMP_FRAG_NEEDED)
+			if (ich->type == ICMP_DEST_UNREACH &&
+			    ich->code == ICMP_FRAG_NEEDED)
 				printk("MTU=%u ", ntohs(ich->un.frag.mtu));
 		}
 		break;
@@ -407,8 +407,8 @@ ipt_log_packet(u_int8_t pf,
 	if (in && !out) {
 		/* MAC logging for input chain only. */
 		printk("MAC=");
-		if (skb->dev && skb->dev->hard_header_len
-		    && skb->mac_header != skb->network_header) {
+		if (skb->dev && skb->dev->hard_header_len &&
+		    skb->mac_header != skb->network_header) {
 			int i;
 			const unsigned char *p = skb_mac_header(skb);
 			for (i = 0; i < skb->dev->hard_header_len; i++,p++)
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index dada086..650b540 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -59,8 +59,8 @@ masquerade_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	ct = nf_ct_get(skb, &ctinfo);
 	nat = nfct_nat(ct);
 
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED
-			    || ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY));
+	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
+			    ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY));
 
 	/* Source address is 0.0.0.0 - locally generated packet that is
 	 * probably not supposed to be masqueraded.
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index c93ae44..5113b8f 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -184,8 +184,8 @@ static bool reject_tg_check(const struct xt_tgchk_param *par)
 		return false;
 	} else if (rejinfo->with == IPT_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
-		if (e->ip.proto != IPPROTO_TCP
-		    || (e->ip.invflags & XT_INV_PROTO)) {
+		if (e->ip.proto != IPPROTO_TCP ||
+		    (e->ip.invflags & XT_INV_PROTO)) {
 			printk("ipt_REJECT: TCP_RESET invalid for non-tcp\n");
 			return false;
 		}
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index d32cc4b..399061c 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -226,9 +226,9 @@ static void ipt_ulog_packet(unsigned int hooknum,
 	else
 		*(pm->prefix) = '\0';
 
-	if (in && in->hard_header_len > 0
-	    && skb->mac_header != skb->network_header
-	    && in->hard_header_len <= ULOG_MAC_LEN) {
+	if (in && in->hard_header_len > 0 &&
+	    skb->mac_header != skb->network_header &&
+	    in->hard_header_len <= ULOG_MAC_LEN) {
 		memcpy(pm->mac, skb_mac_header(skb), in->hard_header_len);
 		pm->mac_len = in->hard_header_len;
 	} else
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index 6289b64..2a1e56b 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -96,8 +96,8 @@ static bool ecn_mt_check(const struct xt_mtchk_param *par)
 	if (info->invert & IPT_ECN_OP_MATCH_MASK)
 		return false;
 
-	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR)
-	    && ip->proto != IPPROTO_TCP) {
+	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR) &&
+	    ip->proto != IPPROTO_TCP) {
 		printk(KERN_WARNING "ipt_ecn: can't match TCP bits in rule for"
 		       " non-tcp packets\n");
 		return false;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 036047f..fae78c3 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -130,8 +130,8 @@ ipt_local_hook(unsigned int hook,
 	u_int32_t mark;
 
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr))
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
 	/* Save things which could affect route */
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 99eb76c..3bd3d63 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -94,8 +94,8 @@ ipt_local_out_hook(unsigned int hook,
 		   int (*okfn)(struct sk_buff *))
 {
 	/* Somebody is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr))
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 	return ipt_do_table(skb, hook, in, out,
 			    dev_net(out)->ipv4.iptable_security);
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index d71ba76..e3dd936 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -54,8 +54,8 @@ static const u_int8_t invmap[] = {
 static bool icmp_invert_tuple(struct nf_conntrack_tuple *tuple,
 			      const struct nf_conntrack_tuple *orig)
 {
-	if (orig->dst.u.icmp.type >= sizeof(invmap)
-	    || !invmap[orig->dst.u.icmp.type])
+	if (orig->dst.u.icmp.type >= sizeof(invmap) ||
+	    !invmap[orig->dst.u.icmp.type])
 		return false;
 
 	tuple->src.u.icmp.id = orig->src.u.icmp.id;
@@ -101,8 +101,8 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		[ICMP_ADDRESS] = 1
 	};
 
-	if (ct->tuplehash[0].tuple.dst.u.icmp.type >= sizeof(valid_new)
-	    || !valid_new[ct->tuplehash[0].tuple.dst.u.icmp.type]) {
+	if (ct->tuplehash[0].tuple.dst.u.icmp.type >= sizeof(valid_new) ||
+	    !valid_new[ct->tuplehash[0].tuple.dst.u.icmp.type]) {
 		/* Can't create a new ICMP `conn' with this. */
 		pr_debug("icmp: can't create new conn with type %u\n",
 			 ct->tuplehash[0].tuple.dst.u.icmp.type);
@@ -201,11 +201,11 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	}
 
 	/* Need to track icmp error message? */
-	if (icmph->type != ICMP_DEST_UNREACH
-	    && icmph->type != ICMP_SOURCE_QUENCH
-	    && icmph->type != ICMP_TIME_EXCEEDED
-	    && icmph->type != ICMP_PARAMETERPROB
-	    && icmph->type != ICMP_REDIRECT)
+	if (icmph->type != ICMP_DEST_UNREACH &&
+	    icmph->type != ICMP_SOURCE_QUENCH &&
+	    icmph->type != ICMP_TIME_EXCEEDED &&
+	    icmph->type != ICMP_PARAMETERPROB &&
+	    icmph->type != ICMP_REDIRECT)
 		return NF_ACCEPT;
 
 	return icmp_error_message(net, skb, ctinfo, hooknum);
@@ -238,17 +238,17 @@ static const struct nla_policy icmp_nla_policy[CTA_PROTO_MAX+1] = {
 static int icmp_nlattr_to_tuple(struct nlattr *tb[],
 				struct nf_conntrack_tuple *tuple)
 {
-	if (!tb[CTA_PROTO_ICMP_TYPE]
-	    || !tb[CTA_PROTO_ICMP_CODE]
-	    || !tb[CTA_PROTO_ICMP_ID])
+	if (!tb[CTA_PROTO_ICMP_TYPE] ||
+	    !tb[CTA_PROTO_ICMP_CODE] ||
+	    !tb[CTA_PROTO_ICMP_ID])
 		return -EINVAL;
 
 	tuple->dst.u.icmp.type = nla_get_u8(tb[CTA_PROTO_ICMP_TYPE]);
 	tuple->dst.u.icmp.code = nla_get_u8(tb[CTA_PROTO_ICMP_CODE]);
 	tuple->src.u.icmp.id = nla_get_be16(tb[CTA_PROTO_ICMP_ID]);
 
-	if (tuple->dst.u.icmp.type >= sizeof(invmap)
-	    || !invmap[tuple->dst.u.icmp.type])
+	if (tuple->dst.u.icmp.type >= sizeof(invmap) ||
+	    !invmap[tuple->dst.u.icmp.type])
 		return -EINVAL;
 
 	return 0;
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 5f41d01..5678e95 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -197,11 +197,11 @@ nf_nat_out(unsigned int hooknum,
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
-		if (ct->tuplehash[dir].tuple.src.u3.ip !=
-		    ct->tuplehash[!dir].tuple.dst.u3.ip
-		    || ct->tuplehash[dir].tuple.src.u.all !=
-		       ct->tuplehash[!dir].tuple.dst.u.all
-		    )
+		if ((ct->tuplehash[dir].tuple.src.u3.ip !=
+		     ct->tuplehash[!dir].tuple.dst.u3.ip) ||
+		    (ct->tuplehash[dir].tuple.src.u.all !=
+		     ct->tuplehash[!dir].tuple.dst.u.all)
+		   )
 			return ip_xfrm_me_harder(skb) == 0 ? ret : NF_DROP;
 	}
 #endif
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index cc9f8ef..480d7f8 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -105,9 +105,9 @@ ip6_packet_match(const struct sk_buff *skb,
 #define FWINV(bool, invflg) ((bool) ^ !!(ip6info->invflags & (invflg)))
 
 	if (FWINV(ipv6_masked_addr_cmp(&ipv6->saddr, &ip6info->smsk,
-				       &ip6info->src), IP6T_INV_SRCIP)
-	    || FWINV(ipv6_masked_addr_cmp(&ipv6->daddr, &ip6info->dmsk,
-					  &ip6info->dst), IP6T_INV_DSTIP)) {
+				       &ip6info->src), IP6T_INV_SRCIP) ||
+	    FWINV(ipv6_masked_addr_cmp(&ipv6->daddr, &ip6info->dmsk,
+				       &ip6info->dst), IP6T_INV_DSTIP)) {
 		dprintf("Source or dest mismatch.\n");
 /*
 		dprintf("SRC: %u. Mask: %u. Target: %u.%s\n", ip->saddr,
@@ -277,11 +277,11 @@ get_chainname_rulenum(struct ip6t_entry *s, struct ip6t_entry *e,
 	} else if (s == e) {
 		(*rulenum)++;
 
-		if (s->target_offset == sizeof(struct ip6t_entry)
-		   && strcmp(t->target.u.kernel.target->name,
-			     IP6T_STANDARD_TARGET) == 0
-		   && t->verdict < 0
-		   && unconditional(&s->ipv6)) {
+		if (s->target_offset == sizeof(struct ip6t_entry) &&
+		    strcmp(t->target.u.kernel.target->name,
+			   IP6T_STANDARD_TARGET) == 0 &&
+		    t->verdict < 0 &&
+		    unconditional(&s->ipv6)) {
 			/* Tail of chains: STANDARD target (return/policy) */
 			*comment = *chainname == hookname
 				? comments[NF_IP6_TRACE_COMMENT_POLICY]
@@ -418,8 +418,8 @@ ip6t_do_table(struct sk_buff *skb,
 				back = get_entry(table_base, back->comefrom);
 				continue;
 			}
-			if (table_base + v != ip6t_next_entry(e)
-			    && !(e->ipv6.flags & IP6T_F_GOTO)) {
+			if (table_base + v != ip6t_next_entry(e) &&
+			    !(e->ipv6.flags & IP6T_F_GOTO)) {
 				/* Save old back ptr in next entry */
 				struct ip6t_entry *next = ip6t_next_entry(e);
 				next->comefrom = (void *)back - table_base;
@@ -505,11 +505,11 @@ mark_source_chains(struct xt_table_info *newinfo,
 			e->comefrom |= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
-			if ((e->target_offset == sizeof(struct ip6t_entry)
-			    && (strcmp(t->target.u.user.name,
-				       IP6T_STANDARD_TARGET) == 0)
-			    && t->verdict < 0
-			    && unconditional(&e->ipv6)) || visited) {
+			if ((e->target_offset == sizeof(struct ip6t_entry) &&
+			     (strcmp(t->target.u.user.name,
+				     IP6T_STANDARD_TARGET) == 0) &&
+			     t->verdict < 0 &&
+			     unconditional(&e->ipv6)) || visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
@@ -556,8 +556,8 @@ mark_source_chains(struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   IP6T_STANDARD_TARGET) == 0
-				    && newpos >= 0) {
+					   IP6T_STANDARD_TARGET) == 0 &&
+				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct ip6t_entry)) {
 						duprintf("mark_source_chains: "
@@ -767,8 +767,8 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 {
 	unsigned int h;
 
-	if ((unsigned long)e % __alignof__(struct ip6t_entry) != 0
-	    || (unsigned char *)e + sizeof(struct ip6t_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct ip6t_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct ip6t_entry) >= limit) {
 		duprintf("Bad offset %p\n", e);
 		return -EINVAL;
 	}
@@ -1584,8 +1584,8 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	int ret, off, h;
 
 	duprintf("check_compat_entry_size_and_hooks %p\n", e);
-	if ((unsigned long)e % __alignof__(struct compat_ip6t_entry) != 0
-	    || (unsigned char *)e + sizeof(struct compat_ip6t_entry) >= limit) {
+	if ((unsigned long)e % __alignof__(struct compat_ip6t_entry) != 0 ||
+	    (unsigned char *)e + sizeof(struct compat_ip6t_entry) >= limit) {
 		duprintf("Bad offset %p, limit = %p\n", e, limit);
 		return -EINVAL;
 	}
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 7018cac..b285fdf 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -249,8 +249,8 @@ static void dump_packet(const struct nf_loginfo *info,
 		/* Max length: 11 "URGP=65535 " */
 		printk("URGP=%u ", ntohs(th->urg_ptr));
 
-		if ((logflags & IP6T_LOG_TCPOPT)
-		    && th->doff * 4 > sizeof(struct tcphdr)) {
+		if ((logflags & IP6T_LOG_TCPOPT) &&
+		    th->doff * 4 > sizeof(struct tcphdr)) {
 			u_int8_t _opt[60 - sizeof(struct tcphdr)];
 			const u_int8_t *op;
 			unsigned int i;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 5a7f00c..8311ca3 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -223,8 +223,8 @@ static bool reject_tg6_check(const struct xt_tgchk_param *par)
 		return false;
 	} else if (rejinfo->with == IP6T_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
-		if (e->ipv6.proto != IPPROTO_TCP
-		    || (e->ipv6.invflags & XT_INV_PROTO)) {
+		if (e->ipv6.proto != IPPROTO_TCP ||
+		    (e->ipv6.invflags & XT_INV_PROTO)) {
 			printk("ip6t_REJECT: TCP_RESET illegal for non-tcp\n");
 			return false;
 		}
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 3a82f24..ac0b7c6 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -77,17 +77,14 @@ static bool ah_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 		 ahinfo->hdrres, ah->reserved,
 		 !(ahinfo->hdrres && ah->reserved));
 
-	return (ah != NULL)
-	       &&
-	       spi_match(ahinfo->spis[0], ahinfo->spis[1],
-			 ntohl(ah->spi),
-			 !!(ahinfo->invflags & IP6T_AH_INV_SPI))
-	       &&
-	       (!ahinfo->hdrlen ||
-		(ahinfo->hdrlen == hdrlen) ^
-		!!(ahinfo->invflags & IP6T_AH_INV_LEN))
-	       &&
-	       !(ahinfo->hdrres && ah->reserved);
+	return (ah != NULL) &&
+		spi_match(ahinfo->spis[0], ahinfo->spis[1],
+			  ntohl(ah->spi),
+			  !!(ahinfo->invflags & IP6T_AH_INV_SPI)) &&
+		(!ahinfo->hdrlen ||
+		 (ahinfo->hdrlen == hdrlen) ^
+		 !!(ahinfo->invflags & IP6T_AH_INV_LEN)) &&
+		!(ahinfo->hdrres && ah->reserved);
 }
 
 static bool ah_mt6_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 673aa0a..7b91c25 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -70,41 +70,36 @@ frag_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	pr_debug("res %02X %02X%04X %02X ",
 		 fraginfo->flags & IP6T_FRAG_RES, fh->reserved,
 		 ntohs(fh->frag_off) & 0x6,
-		 !((fraginfo->flags & IP6T_FRAG_RES)
-		   && (fh->reserved || (ntohs(fh->frag_off) & 0x06))));
+		 !((fraginfo->flags & IP6T_FRAG_RES) &&
+		   (fh->reserved || (ntohs(fh->frag_off) & 0x06))));
 	pr_debug("first %02X %02X %02X ",
 		 fraginfo->flags & IP6T_FRAG_FST,
 		 ntohs(fh->frag_off) & ~0x7,
-		 !((fraginfo->flags & IP6T_FRAG_FST)
-		   && (ntohs(fh->frag_off) & ~0x7)));
+		 !((fraginfo->flags & IP6T_FRAG_FST) &&
+		   (ntohs(fh->frag_off) & ~0x7)));
 	pr_debug("mf %02X %02X %02X ",
 		 fraginfo->flags & IP6T_FRAG_MF,
 		 ntohs(fh->frag_off) & IP6_MF,
-		 !((fraginfo->flags & IP6T_FRAG_MF)
-		   && !((ntohs(fh->frag_off) & IP6_MF))));
+		 !((fraginfo->flags & IP6T_FRAG_MF) &&
+		   !((ntohs(fh->frag_off) & IP6_MF))));
 	pr_debug("last %02X %02X %02X\n",
 		 fraginfo->flags & IP6T_FRAG_NMF,
 		 ntohs(fh->frag_off) & IP6_MF,
-		 !((fraginfo->flags & IP6T_FRAG_NMF)
-		   && (ntohs(fh->frag_off) & IP6_MF)));
-
-	return (fh != NULL)
-	       &&
-	       id_match(fraginfo->ids[0], fraginfo->ids[1],
-			ntohl(fh->identification),
-			!!(fraginfo->invflags & IP6T_FRAG_INV_IDS))
-	       &&
-	       !((fraginfo->flags & IP6T_FRAG_RES)
-		 && (fh->reserved || (ntohs(fh->frag_off) & 0x6)))
-	       &&
-	       !((fraginfo->flags & IP6T_FRAG_FST)
-		 && (ntohs(fh->frag_off) & ~0x7))
-	       &&
-	       !((fraginfo->flags & IP6T_FRAG_MF)
-		 && !(ntohs(fh->frag_off) & IP6_MF))
-	       &&
-	       !((fraginfo->flags & IP6T_FRAG_NMF)
-		 && (ntohs(fh->frag_off) & IP6_MF));
+		 !((fraginfo->flags & IP6T_FRAG_NMF) &&
+		   (ntohs(fh->frag_off) & IP6_MF)));
+
+	return (fh != NULL) &&
+		id_match(fraginfo->ids[0], fraginfo->ids[1],
+			 ntohl(fh->identification),
+			 !!(fraginfo->invflags & IP6T_FRAG_INV_IDS)) &&
+		!((fraginfo->flags & IP6T_FRAG_RES) &&
+		  (fh->reserved || (ntohs(fh->frag_off) & 0x6))) &&
+		!((fraginfo->flags & IP6T_FRAG_FST) &&
+		  (ntohs(fh->frag_off) & ~0x7)) &&
+		!((fraginfo->flags & IP6T_FRAG_MF) &&
+		  !(ntohs(fh->frag_off) & IP6_MF)) &&
+		!((fraginfo->flags & IP6T_FRAG_NMF) &&
+		  (ntohs(fh->frag_off) & IP6_MF));
 }
 
 static bool frag_mt6_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index 356b8d6..b77307f 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -92,16 +92,13 @@ static bool rt_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 		 !((rtinfo->flags & IP6T_RT_RES) &&
 		   (((const struct rt0_hdr *)rh)->reserved)));
 
-	ret = (rh != NULL)
-	      &&
+	ret = (rh != NULL) &&
 	      (segsleft_match(rtinfo->segsleft[0], rtinfo->segsleft[1],
 			      rh->segments_left,
-			      !!(rtinfo->invflags & IP6T_RT_INV_SGS)))
-	      &&
+			      !!(rtinfo->invflags & IP6T_RT_INV_SGS))) &&
 	      (!(rtinfo->flags & IP6T_RT_LEN) ||
 	       ((rtinfo->hdrlen == hdrlen) ^
-		!!(rtinfo->invflags & IP6T_RT_INV_LEN)))
-	      &&
+		!!(rtinfo->invflags & IP6T_RT_INV_LEN))) &&
 	      (!(rtinfo->flags & IP6T_RT_TYP) ||
 	       ((rtinfo->rt_type == rh->type) ^
 		!!(rtinfo->invflags & IP6T_RT_INV_TYP)));
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 6f4383a..ad378ef 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -79,8 +79,8 @@ ip6t_local_out_hook(unsigned int hook,
 {
 #if 0
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 0ad9143..a929c19 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -102,8 +102,8 @@ ip6t_local_out_hook(unsigned int hook,
 
 #if 0
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
@@ -122,11 +122,11 @@ ip6t_local_out_hook(unsigned int hook,
 	ret = ip6t_do_table(skb, hook, in, out,
 			    dev_net(out)->ipv6.ip6table_mangle);
 
-	if (ret != NF_DROP && ret != NF_STOLEN
-		&& (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr))
-		    || memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr))
-		    || skb->mark != mark
-		    || ipv6_hdr(skb)->hop_limit != hop_limit))
+	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
+	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
+	     skb->mark != mark ||
+	     ipv6_hdr(skb)->hop_limit != hop_limit))
 		return ip6_route_me_harder(skb) == 0 ? ret : NF_DROP;
 
 	return ret;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 642dcb1..0f3df45 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -244,18 +244,18 @@ static const struct nla_policy icmpv6_nla_policy[CTA_PROTO_MAX+1] = {
 static int icmpv6_nlattr_to_tuple(struct nlattr *tb[],
 				struct nf_conntrack_tuple *tuple)
 {
-	if (!tb[CTA_PROTO_ICMPV6_TYPE]
-	    || !tb[CTA_PROTO_ICMPV6_CODE]
-	    || !tb[CTA_PROTO_ICMPV6_ID])
+	if (!tb[CTA_PROTO_ICMPV6_TYPE] ||
+	    !tb[CTA_PROTO_ICMPV6_CODE] ||
+	    !tb[CTA_PROTO_ICMPV6_ID])
 		return -EINVAL;
 
 	tuple->dst.u.icmp.type = nla_get_u8(tb[CTA_PROTO_ICMPV6_TYPE]);
 	tuple->dst.u.icmp.code = nla_get_u8(tb[CTA_PROTO_ICMPV6_CODE]);
 	tuple->src.u.icmp.id = nla_get_be16(tb[CTA_PROTO_ICMPV6_ID]);
 
-	if (tuple->dst.u.icmp.type < 128
-	    || tuple->dst.u.icmp.type - 128 >= sizeof(invmap)
-	    || !invmap[tuple->dst.u.icmp.type - 128])
+	if (tuple->dst.u.icmp.type < 128 ||
+	    tuple->dst.u.icmp.type - 128 >= sizeof(invmap) ||
+	    !invmap[tuple->dst.u.icmp.type - 128])
 		return -EINVAL;
 
 	return 0;
