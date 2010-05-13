From: kaber@trash.net
Subject: [PATCH 11/12] netfilter: cleanup printk messages
Date: Thu, 13 May 2010 18:16:24 +0200
Message-ID: <1273767385-18225-12-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>

Make sure all printk messages have a severity level.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c                |    4 ++--
 net/ipv4/netfilter/ip_tables.c                 |    2 +-
 net/ipv4/netfilter/iptable_filter.c            |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +++++-----
 net/ipv4/netfilter/nf_nat_h323.c               |   16 ++++++++--------
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   16 ++++++++--------
 net/ipv4/netfilter/nf_nat_standalone.c         |    4 ++--
 net/ipv6/netfilter/ip6_tables.c                |    2 +-
 net/ipv6/netfilter/ip6table_filter.c           |    2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |    2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   14 +++++++-------
 net/netfilter/nf_conntrack_amanda.c            |    2 +-
 net/netfilter/nf_conntrack_core.c              |    2 +-
 net/netfilter/nf_conntrack_ftp.c               |    4 ++--
 net/netfilter/nf_conntrack_h323_main.c         |    6 +++---
 net/netfilter/nf_conntrack_irc.c               |    4 ++--
 net/netfilter/nf_conntrack_netlink.c           |   12 ++++++------
 net/netfilter/nf_conntrack_proto_sctp.c        |    4 ++--
 net/netfilter/nf_conntrack_sip.c               |    4 ++--
 net/netfilter/nf_conntrack_standalone.c        |    2 +-
 net/netfilter/nf_conntrack_tftp.c              |    4 ++--
 net/netfilter/nf_internals.h                   |    2 +-
 net/netfilter/nfnetlink.c                      |    4 ++--
 net/netfilter/nfnetlink_log.c                  |    4 ++--
 24 files changed, 64 insertions(+), 64 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 65f2944..1ac01b1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -222,7 +222,7 @@ static unsigned int
 arpt_error(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	if (net_ratelimit())
-		printk("arp_tables: error: '%s'\n",
+		pr_err("arp_tables: error: '%s'\n",
 		       (const char *)par->targinfo);
 
 	return NF_DROP;
@@ -385,7 +385,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_ARP_NUMHOOKS)) {
-				printk("arptables: loop hook %u pos %u %08X.\n",
+				pr_notice("arptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index ad702bc..63958f3 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -466,7 +466,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
-				printk("iptables: loop hook %u pos %u %08X.\n",
+				pr_err("iptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 5539246..c37641e 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -89,7 +89,7 @@ static int __init iptable_filter_init(void)
 	int ret;
 
 	if (forward < 0 || forward > NF_MAX_VERDICT) {
-		printk("iptables forward must be 0 or 1\n");
+		pr_err("iptables forward must be 0 or 1\n");
 		return -EINVAL;
 	}
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2bb1f87..5a03c02 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -382,32 +382,32 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register tcp.\n");
+		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
 		goto cleanup_sockopt;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register udp.\n");
+		pr_err("nf_conntrack_ipv4: can't register udp.\n");
 		goto cleanup_tcp;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register icmp.\n");
+		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
 		goto cleanup_udp;
 	}
 
 	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register ipv4\n");
+		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
 		goto cleanup_icmp;
 	}
 
 	ret = nf_register_hooks(ipv4_conntrack_ops,
 				ARRAY_SIZE(ipv4_conntrack_ops));
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register hooks.\n");
+		pr_err("nf_conntrack_ipv4: can't register hooks.\n");
 		goto cleanup_ipv4;
 	}
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index d4c0618..5045196 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -43,7 +43,7 @@ static int set_addr(struct sk_buff *skb,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
-				printk("nf_nat_h323: nf_nat_mangle_tcp_packet"
+				pr_notice("nf_nat_h323: nf_nat_mangle_tcp_packet"
 				       " error\n");
 			return -1;
 		}
@@ -59,7 +59,7 @@ static int set_addr(struct sk_buff *skb,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
-				printk("nf_nat_h323: nf_nat_mangle_udp_packet"
+				pr_notice("nf_nat_h323: nf_nat_mangle_udp_packet"
 				       " error\n");
 			return -1;
 		}
@@ -215,7 +215,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	/* Run out of expectations */
 	if (i >= H323_RTP_CHANNEL_MAX) {
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of expectations\n");
+			pr_notice("nf_nat_h323: out of expectations\n");
 		return 0;
 	}
 
@@ -234,7 +234,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of RTP ports\n");
+			pr_notice("nf_nat_h323: out of RTP ports\n");
 		return 0;
 	}
 
@@ -291,7 +291,7 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of TCP ports\n");
+			pr_notice("nf_nat_h323: out of TCP ports\n");
 		return 0;
 	}
 
@@ -341,7 +341,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_q931: out of TCP ports\n");
+			pr_notice("nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
@@ -425,7 +425,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_ras: out of TCP ports\n");
+			pr_notice("nf_nat_ras: out of TCP ports\n");
 		return 0;
 	}
 
@@ -507,7 +507,7 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_q931: out of TCP ports\n");
+			pr_notice("nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 4d85b6e..1679e2c 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -401,7 +401,7 @@ static unsigned char asn1_octets_decode(struct asn1_ctx *ctx,
 	*octets = kmalloc(eoc - ctx->pointer, GFP_ATOMIC);
 	if (*octets == NULL) {
 		if (net_ratelimit())
-			printk("OOM in bsalg (%d)\n", __LINE__);
+			pr_notice("OOM in bsalg (%d)\n", __LINE__);
 		return 0;
 	}
 
@@ -452,7 +452,7 @@ static unsigned char asn1_oid_decode(struct asn1_ctx *ctx,
 	*oid = kmalloc(size * sizeof(unsigned long), GFP_ATOMIC);
 	if (*oid == NULL) {
 		if (net_ratelimit())
-			printk("OOM in bsalg (%d)\n", __LINE__);
+			pr_notice("OOM in bsalg (%d)\n", __LINE__);
 		return 0;
 	}
 
@@ -729,7 +729,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			(*obj)->syntax.l[0] = l;
@@ -746,7 +746,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 				kfree(p);
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.c, p, len);
@@ -761,7 +761,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			if (!asn1_null_decode(ctx, end)) {
@@ -782,7 +782,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 				kfree(lp);
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.ul, lp, len);
@@ -803,7 +803,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 				kfree(p);
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.uc, p, len);
@@ -821,7 +821,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					pr_notice("OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			(*obj)->syntax.ul[0] = ul;
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 84c7974..beb2581 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -293,12 +293,12 @@ static int __init nf_nat_standalone_init(void)
 #endif
 	ret = nf_nat_rule_init();
 	if (ret < 0) {
-		printk("nf_nat_init: can't setup rules.\n");
+		pr_err("nf_nat_init: can't setup rules.\n");
 		goto cleanup_decode_session;
 	}
 	ret = nf_register_hooks(nf_nat_ops, ARRAY_SIZE(nf_nat_ops));
 	if (ret < 0) {
-		printk("nf_nat_init: can't register hooks.\n");
+		pr_err("nf_nat_init: can't register hooks.\n");
 		goto cleanup_rule_init;
 	}
 	return ret;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 02a7db0..6f517bd 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -481,7 +481,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
-				printk("iptables: loop hook %u pos %u %08X.\n",
+				pr_err("iptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index d6fc9af..c9e37c8 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -81,7 +81,7 @@ static int __init ip6table_filter_init(void)
 	int ret;
 
 	if (forward < 0 || forward > NF_MAX_VERDICT) {
-		printk("iptables forward must be 0 or 1\n");
+		pr_err("iptables forward must be 0 or 1\n");
 		return -EINVAL;
 	}
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 6a102b5..679a0a3 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -43,7 +43,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("ip6t_hook: happy cracking.\n");
+			pr_warning("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 996c3f4..ff43461 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -280,7 +280,7 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct ipv6hdr)) {
 		if (net_ratelimit())
-			printk("ipv6_conntrack_local: packet too short\n");
+			pr_notice("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
 	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, okfn);
@@ -406,37 +406,37 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 
 	ret = nf_ct_frag6_init();
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't initialize frag6.\n");
+		pr_err("nf_conntrack_ipv6: can't initialize frag6.\n");
 		return ret;
 	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't register tcp.\n");
+		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
 		goto cleanup_frag6;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't register udp.\n");
+		pr_err("nf_conntrack_ipv6: can't register udp.\n");
 		goto cleanup_tcp;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't register icmpv6.\n");
+		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
 		goto cleanup_udp;
 	}
 
 	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't register ipv6\n");
+		pr_err("nf_conntrack_ipv6: can't register ipv6\n");
 		goto cleanup_icmpv6;
 	}
 
 	ret = nf_register_hooks(ipv6_conntrack_ops,
 				ARRAY_SIZE(ipv6_conntrack_ops));
 	if (ret < 0) {
-		printk("nf_conntrack_ipv6: can't register pre-routing defrag "
+		pr_err("nf_conntrack_ipv6: can't register pre-routing defrag "
 		       "hook.\n");
 		goto cleanup_ipv6;
 	}
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 372e80f..13fd2c5 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -108,7 +108,7 @@ static int amanda_help(struct sk_buff *skb,
 	dataoff = protoff + sizeof(struct udphdr);
 	if (dataoff >= skb->len) {
 		if (net_ratelimit())
-			printk("amanda_help: skblen = %u\n", skb->len);
+			printk(KERN_ERR "amanda_help: skblen = %u\n", skb->len);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3907efb..b83c530 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1335,7 +1335,7 @@ static int nf_conntrack_init_init_net(void)
 	}
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
-	printk("nf_conntrack version %s (%u buckets, %d max)\n",
+	printk(KERN_INFO "nf_conntrack version %s (%u buckets, %d max)\n",
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 2ae3169..e17cb7c 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -573,8 +573,8 @@ static int __init nf_conntrack_ftp_init(void)
 				 ftp[i][j].tuple.src.l3num, ports[i]);
 			ret = nf_conntrack_helper_register(&ftp[i][j]);
 			if (ret) {
-				printk("nf_ct_ftp: failed to register helper "
-				       " for pf: %d port: %d\n",
+				printk(KERN_ERR "nf_ct_ftp: failed to register"
+				       " helper for pf: %d port: %d\n",
 					ftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_ftp_fini();
 				return ret;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 48bf150..6eaee7c 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -607,7 +607,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_h245: packet dropped\n");
+		pr_info("nf_ct_h245: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1152,7 +1152,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_q931: packet dropped\n");
+		pr_info("nf_ct_q931: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1727,7 +1727,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_ras: packet dropped\n");
+		pr_info("nf_ct_ras: packet dropped\n");
 	return NF_DROP;
 }
 
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 7673930..b394aa3 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -235,7 +235,7 @@ static int __init nf_conntrack_irc_init(void)
 	char *tmpname;
 
 	if (max_dcc_channels < 1) {
-		printk("nf_ct_irc: max_dcc_channels must not be zero\n");
+		printk(KERN_ERR "nf_ct_irc: max_dcc_channels must not be zero\n");
 		return -EINVAL;
 	}
 
@@ -267,7 +267,7 @@ static int __init nf_conntrack_irc_init(void)
 
 		ret = nf_conntrack_helper_register(&irc[i]);
 		if (ret) {
-			printk("nf_ct_irc: failed to register helper "
+			printk(KERN_ERR "nf_ct_irc: failed to register helper "
 			       "for pf: %u port: %u\n",
 			       irc[i].tuple.src.l3num, ports[i]);
 			nf_conntrack_irc_fini();
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e55403..961fb6a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2057,29 +2057,29 @@ static int __init ctnetlink_init(void)
 {
 	int ret;
 
-	printk("ctnetlink v%s: registering with nfnetlink.\n", version);
+	pr_info("ctnetlink v%s: registering with nfnetlink.\n", version);
 	ret = nfnetlink_subsys_register(&ctnl_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register with nfnetlink.\n");
+		pr_err("ctnetlink_init: cannot register with nfnetlink.\n");
 		goto err_out;
 	}
 
 	ret = nfnetlink_subsys_register(&ctnl_exp_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register exp with nfnetlink.\n");
+		pr_err("ctnetlink_init: cannot register exp with nfnetlink.\n");
 		goto err_unreg_subsys;
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	ret = nf_conntrack_register_notifier(&ctnl_notifier);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register notifier.\n");
+		pr_err("ctnetlink_init: cannot register notifier.\n");
 		goto err_unreg_exp_subsys;
 	}
 
 	ret = nf_ct_expect_register_notifier(&ctnl_notifier_exp);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot expect register notifier.\n");
+		pr_err("ctnetlink_init: cannot expect register notifier.\n");
 		goto err_unreg_notifier;
 	}
 #endif
@@ -2100,7 +2100,7 @@ err_out:
 
 static void __exit ctnetlink_exit(void)
 {
-	printk("ctnetlink: unregistering from nfnetlink.\n");
+	pr_info("ctnetlink: unregistering from nfnetlink.\n");
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	nf_ct_expect_unregister_notifier(&ctnl_notifier_exp);
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index b68ff15..c6049c2 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -717,12 +717,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp4: protocol register failed\n");
+		pr_err("nf_conntrack_l4proto_sctp4: protocol register failed\n");
 		goto out;
 	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp6: protocol register failed\n");
+		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
 		goto cleanup_sctp4;
 	}
 
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index c6cd1b8..b20f427 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1549,8 +1549,8 @@ static int __init nf_conntrack_sip_init(void)
 
 			ret = nf_conntrack_helper_register(&sip[i][j]);
 			if (ret) {
-				printk("nf_ct_sip: failed to register helper "
-				       "for pf: %u port: %u\n",
+				printk(KERN_ERR "nf_ct_sip: failed to register"
+				       " helper for pf: %u port: %u\n",
 				       sip[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_sip_fini();
 				return ret;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index ea4a8d3..eb973fc 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -446,7 +446,7 @@ out_kmemdup:
 	if (net_eq(net, &init_net))
 		unregister_sysctl_table(nf_ct_netfilter_header);
 out:
-	printk("nf_conntrack: can't register to sysctl.\n");
+	printk(KERN_ERR "nf_conntrack: can't register to sysctl.\n");
 	return -ENOMEM;
 }
 
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 46e646b..75466fd 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -138,8 +138,8 @@ static int __init nf_conntrack_tftp_init(void)
 
 			ret = nf_conntrack_helper_register(&tftp[i][j]);
 			if (ret) {
-				printk("nf_ct_tftp: failed to register helper "
-				       "for pf: %u port: %u\n",
+				printk(KERN_ERR "nf_ct_tftp: failed to register"
+				       " helper for pf: %u port: %u\n",
 					tftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_tftp_fini();
 				return ret;
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index bf66099..770f764 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -6,7 +6,7 @@
 #include <linux/netdevice.h>
 
 #ifdef CONFIG_NETFILTER_DEBUG
-#define NFDEBUG(format, args...)  printk(format , ## args)
+#define NFDEBUG(format, args...)  printk(KERN_DEBUG format , ## args)
 #else
 #define NFDEBUG(format, args...)
 #endif
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 39b0e31..b4a4532 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -212,13 +212,13 @@ static struct pernet_operations nfnetlink_net_ops = {
 
 static int __init nfnetlink_init(void)
 {
-	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+	pr_info("Netfilter messages via NETLINK v%s.\n", nfversion);
 	return register_pernet_subsys(&nfnetlink_net_ops);
 }
 
 static void __exit nfnetlink_exit(void)
 {
-	printk("Removing netfilter NETLINK layer.\n");
+	pr_info("Removing netfilter NETLINK layer.\n");
 	unregister_pernet_subsys(&nfnetlink_net_ops);
 }
 module_init(nfnetlink_init);
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 203643f..fc9a211 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -297,7 +297,7 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	n = max(inst_size, pkt_size);
 	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
-		PRINTR("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
+		pr_notice("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
 			inst_size);
 
 		if (n > pkt_size) {
@@ -306,7 +306,7 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 
 			skb = alloc_skb(pkt_size, GFP_ATOMIC);
 			if (!skb)
-				PRINTR("nfnetlink_log: can't even alloc %u "
+				pr_err("nfnetlink_log: can't even alloc %u "
 				       "bytes\n", pkt_size);
 		}
 	}
-- 
1.7.0.4

