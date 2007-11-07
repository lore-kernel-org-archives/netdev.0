From: FNST-Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] [IPv4] printk() includes KERN_* constant in net/ipv4/
Date: Wed, 07 Nov 2007 11:10:24 +0800
Message-ID: <47312CA0.4040105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: trivial@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:63941 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754232AbXKGDMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 22:12:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the printk() without KERN_* constant in net/ipv4.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 af_inet.c                             |    4 ++--
 devinet.c                             |    2 +-
 fib_hash.c                            |    2 +-
 fib_semantics.c                       |    2 +-
 ipconfig.c                            |   18 +++++++++---------
 netfilter/arp_tables.c                |    6 +++---
 netfilter/ip_tables.c                 |    8 ++++----
 netfilter/ipt_CLUSTERIP.c             |    4 ++--
 netfilter/ipt_MASQUERADE.c            |    2 +-
 netfilter/ipt_REJECT.c                |    4 ++--
 netfilter/ipt_owner.c                 |    2 +-
 netfilter/iptable_filter.c            |    4 ++--
 netfilter/iptable_mangle.c            |    2 +-
 netfilter/iptable_raw.c               |    2 +-
 netfilter/nf_conntrack_l3proto_ipv4.c |   12 ++++++------
 netfilter/nf_nat_h323.c               |   16 ++++++++--------
 netfilter/nf_nat_rule.c               |    8 ++++----
 netfilter/nf_nat_snmp_basic.c         |   16 ++++++++--------
 18 files changed, 57 insertions(+), 57 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d2f22e7..dd73e78 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -136,12 +136,12 @@ void inet_sock_destruct(struct sock *sk)
 	__skb_queue_purge(&sk->sk_error_queue);
 
 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
-		printk("Attempt to release TCP socket in state %d %p\n",
+		printk(KERN_ERR "Attempt to release TCP socket in state %d %p\n",
 		       sk->sk_state, sk);
 		return;
 	}
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive inet socket %p\n", sk);
+		printk(KERN_ERR "Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 55d199e..350bf14 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -141,7 +141,7 @@ void in_dev_finish_destroy(struct in_device *idev)
 #endif
 	dev_put(dev);
 	if (!idev->dead)
-		printk("Freeing alive in_device %p\n", idev);
+		printk(KERN_ERR "Freeing alive in_device %p\n", idev);
 	else {
 		kfree(idev);
 	}
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..aef7830 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -168,7 +168,7 @@ static void fn_rehash_zone(struct fn_zone *fz)
 	new_hashmask = (new_divisor - 1);
 
 #if RT_CACHE_DEBUG >= 2
-	printk("fn_rehash_zone: hash for zone %d grows from %d\n", fz->fz_order, old_divisor);
+	printk(KERN_DEBUG "fn_rehash_zone: hash for zone %d grows from %d\n", fz->fz_order, old_divisor);
 #endif
 
 	ht = fz_hash_alloc(new_divisor);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1351a26..e350b00 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -145,7 +145,7 @@ static const struct
 void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
-		printk("Freeing alive fib_info %p\n", fi);
+		printk(KERN_ERR "Freeing alive fib_info %p\n", fi);
 		return;
 	}
 	change_nexthops(fi) {
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index c5c107a..c0bc86c 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -208,7 +208,7 @@ static int __init ic_open_devs(void)
 			if (dev->mtu >= 364)
 				able |= IC_BOOTP;
 			else
-				printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small", dev->name, dev->mtu);
+				printk(KERN_WARNING "DHCP/BOOTP: Ignoring device %s, MTU %d too small\n", dev->name, dev->mtu);
 			if (!(dev->flags & IFF_NOARP))
 				able |= IC_RARP;
 			able &= ic_proto_enabled;
@@ -389,7 +389,7 @@ static int __init ic_defaults(void)
 				NIPQUAD(ic_myaddr));
 			return -1;
 		}
-		printk("IP-Config: Guessing netmask %u.%u.%u.%u\n", NIPQUAD(ic_netmask));
+		printk(KERN_INFO "IP-Config: Guessing netmask %u.%u.%u.%u\n", NIPQUAD(ic_netmask));
 	}
 
 	return 0;
@@ -590,7 +590,7 @@ ic_dhcp_init_options(u8 *options)
 	u8 *e = options;
 
 #ifdef IPCONFIG_DEBUG
-	printk("DHCP: Sending message type %d\n", mt);
+	printk(KERN_DEBUG "DHCP: Sending message type %d\n", mt);
 #endif
 
 	memcpy(e, ic_bootp_cookie, 4);	/* RFC1048 Magic Cookie */
@@ -736,7 +736,7 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	else if (dev->type == ARPHRD_FDDI)
 		b->htype = ARPHRD_ETHER;
 	else {
-		printk("Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
+		printk(KERN_WARNING "Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
 		b->htype = dev->type; /* can cause undefined behavior */
 	}
 	b->hlen = dev->addr_len;
@@ -790,7 +790,7 @@ static void __init ic_do_bootp_ext(u8 *ext)
 #ifdef IPCONFIG_DEBUG
 	u8 *c;
 
-	printk("DHCP/BOOTP: Got extension %d:",*ext);
+	printk(KERN_DEBUG "DHCP/BOOTP: Got extension %d:",*ext);
 	for (c=ext+2; c<ext+2+ext[1]; c++)
 		printk(" %02x", *c);
 	printk("\n");
@@ -954,7 +954,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 			}
 
 #ifdef IPCONFIG_DEBUG
-			printk("DHCP: Got message type %d\n", mt);
+			printk(KERN_DEBUG "DHCP: Got message type %d\n", mt);
 #endif
 
 			switch (mt) {
@@ -969,7 +969,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				ic_myaddr = b->your_ip;
 				ic_servaddr = server_id;
 #ifdef IPCONFIG_DEBUG
-				printk("DHCP: Offered address %u.%u.%u.%u",
+				printk(KERN_DEBUG "DHCP: Offered address %u.%u.%u.%u",
 				       NIPQUAD(ic_myaddr));
 				printk(" by server %u.%u.%u.%u\n",
 				       NIPQUAD(ic_servaddr));
@@ -1167,7 +1167,7 @@ static int __init ic_dynamic(void)
 		return -1;
 	}
 
-	printk("IP-Config: Got %s answer from %u.%u.%u.%u, ",
+	printk(KERN_INFO "IP-Config: Got %s answer from %u.%u.%u.%u, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
 		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
 		NIPQUAD(ic_servaddr));
@@ -1375,7 +1375,7 @@ static int __init ip_auto_config(void)
 	/*
 	 * Clue in the operator.
 	 */
-	printk("IP-Config: Complete:");
+	printk(KERN_INFO "IP-Config: Complete:");
 	printk("\n      device=%s", ic_dev->name);
 	printk(", addr=%u.%u.%u.%u", NIPQUAD(ic_myaddr));
 	printk(", mask=%u.%u.%u.%u", NIPQUAD(ic_netmask));
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2909c92..1e60653 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -49,7 +49,7 @@ MODULE_DESCRIPTION("arptables core");
 #define ARP_NF_ASSERT(x)					\
 do {								\
 	if (!(x))						\
-		printk("ARP_NF_ASSERT: %s:%s:%u\n",		\
+		printk(KERN_DEBUG "ARP_NF_ASSERT: %s:%s:%u\n",		\
 		       __FUNCTION__, __FILE__, __LINE__);	\
 } while(0)
 #else
@@ -205,7 +205,7 @@ static unsigned int arpt_error(struct sk_buff *skb,
 			       const void *targinfo)
 {
 	if (net_ratelimit())
-		printk("arp_tables: error: '%s'\n", (char *)targinfo);
+		printk(KERN_ERR "arp_tables: '%s'\n", (char *)targinfo);
 
 	return NF_DROP;
 }
@@ -357,7 +357,7 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_ARP_NUMHOOKS)) {
-				printk("arptables: loop hook %u pos %u %08X.\n",
+				printk(KERN_INFO "arptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 4b10b98..59b41c1 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -51,7 +51,7 @@ MODULE_DESCRIPTION("IPv4 packet filter");
 #define IP_NF_ASSERT(x)						\
 do {								\
 	if (!(x))						\
-		printk("IP_NF_ASSERT: %s:%s:%u\n",		\
+		printk(KERN_DEBUG "IP_NF_ASSERT: %s:%s:%u\n",		\
 		       __FUNCTION__, __FILE__, __LINE__);	\
 } while(0)
 #else
@@ -177,7 +177,7 @@ ipt_error(struct sk_buff *skb,
 	  const void *targinfo)
 {
 	if (net_ratelimit())
-		printk("ip_tables: error: `%s'\n", (char *)targinfo);
+		printk(KERN_ERR "ip_tables: `%s'\n", (char *)targinfo);
 
 	return NF_DROP;
 }
@@ -420,7 +420,7 @@ ipt_do_table(struct sk_buff *skb,
 				if (((struct ipt_entry *)table_base)->comefrom
 				    != 0xeeeeeeec
 				    && verdict == IPT_CONTINUE) {
-					printk("Target %s reentered!\n",
+					printk(KERN_DEBUG "Target %s reentered!\n",
 					       t->u.kernel.target->name);
 					verdict = NF_DROP;
 				}
@@ -482,7 +482,7 @@ mark_source_chains(struct xt_table_info *newinfo,
 			int visited = e->comefrom & (1 << hook);
 
 			if (e->comefrom & (1 << NF_IP_NUMHOOKS)) {
-				printk("iptables: loop hook %u pos %u %08X.\n",
+				printk(KERN_INFO "iptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 2f544da..ac2bde8 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -269,7 +269,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 		hashval = 0;
 		/* This cannot happen, unless the check function wasn't called
 		 * at rule load time */
-		printk("CLUSTERIP: unknown mode `%u'\n", config->hash_mode);
+		printk(KERN_NOTICE "CLUSTERIP: unknown mode `%u'\n", config->hash_mode);
 		BUG();
 		break;
 	}
@@ -497,7 +497,7 @@ static void arp_print(struct arp_payload *payload)
 	}
 	hbuffer[--k]='\0';
 
-	printk("src %u.%u.%u.%u@%s, dst %u.%u.%u.%u\n",
+	printk(KERN_DEBUG "src %u.%u.%u.%u@%s, dst %u.%u.%u.%u\n",
 		NIPQUAD(payload->src_ip), hbuffer,
 		NIPQUAD(payload->dst_ip));
 }
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 44b516e..156b843 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -85,7 +85,7 @@ masquerade_target(struct sk_buff *skb,
 	rt = (struct rtable *)skb->dst;
 	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
-		printk("MASQUERADE: %s ate my IP address\n", out->name);
+		printk(KERN_WARNING "MASQUERADE: %s ate my IP address\n", out->name);
 		return NF_DROP;
 	}
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index dcf4d21..16de76a 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -221,13 +221,13 @@ static bool check(const char *tablename,
 	const struct ipt_entry *e = e_void;
 
 	if (rejinfo->with == IPT_ICMP_ECHOREPLY) {
-		printk("ipt_REJECT: ECHOREPLY no longer supported.\n");
+		printk(KERN_WARNING "ipt_REJECT: ECHOREPLY no longer supported.\n");
 		return false;
 	} else if (rejinfo->with == IPT_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
 		if (e->ip.proto != IPPROTO_TCP
 		    || (e->ip.invflags & XT_INV_PROTO)) {
-			printk("ipt_REJECT: TCP_RESET invalid for non-tcp\n");
+			printk(KERN_WARNING "ipt_REJECT: TCP_RESET invalid for non-tcp\n");
 			return false;
 		}
 	}
diff --git a/net/ipv4/netfilter/ipt_owner.c b/net/ipv4/netfilter/ipt_owner.c
index b14e77d..13cfc7f 100644
--- a/net/ipv4/netfilter/ipt_owner.c
+++ b/net/ipv4/netfilter/ipt_owner.c
@@ -61,7 +61,7 @@ checkentry(const char *tablename,
 	const struct ipt_owner_info *info = matchinfo;
 
 	if (info->match & (IPT_OWNER_PID|IPT_OWNER_SID|IPT_OWNER_COMM)) {
-		printk("ipt_owner: pid, sid and command matching "
+		printk(KERN_WARNING "ipt_owner: pid, sid and command matching "
 		       "not supported anymore\n");
 		return false;
 	}
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index ba3262c..6a0b7cf 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -81,7 +81,7 @@ ipt_local_out_hook(unsigned int hook,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("iptable_filter: ignoring short SOCK_RAW "
+			printk(KERN_WARNING "iptable_filter: ignoring short SOCK_RAW "
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
@@ -122,7 +122,7 @@ static int __init iptable_filter_init(void)
 	int ret;
 
 	if (forward < 0 || forward > NF_MAX_VERDICT) {
-		printk("iptables forward must be 0 or 1\n");
+		printk(KERN_ERR "iptables forward must be 0 or 1\n");
 		return -EINVAL;
 	}
 
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index b4360a6..9bab631 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -100,7 +100,7 @@ ipt_local_hook(unsigned int hook,
 	if (skb->len < sizeof(struct iphdr)
 	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("iptable_mangle: ignoring short SOCK_RAW "
+			printk(KERN_WARNING "iptable_mangle: ignoring short SOCK_RAW "
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 5de6e57..a8ce34f 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -66,7 +66,7 @@ ipt_local_hook(unsigned int hook,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("iptable_raw: ignoring short SOCK_RAW"
+			printk(KERN_WARNING "iptable_raw: ignoring short SOCK_RAW"
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 831e9b2..531c2fa 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -177,7 +177,7 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
-			printk("ipt_hook: happy cracking.\n");
+			printk(KERN_DEBUG "ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
 	return nf_conntrack_in(PF_INET, hooknum, skb);
@@ -437,32 +437,32 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register tcp.\n");
+		printk(KERN_ERR "nf_conntrack_ipv4: can't register tcp.\n");
 		goto cleanup_sockopt;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register udp.\n");
+		printk(KERN_ERR "nf_conntrack_ipv4: can't register udp.\n");
 		goto cleanup_tcp;
 	}
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register icmp.\n");
+		printk(KERN_ERR "nf_conntrack_ipv4: can't register icmp.\n");
 		goto cleanup_udp;
 	}
 
 	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register ipv4\n");
+		printk(KERN_ERR "nf_conntrack_ipv4: can't register ipv4\n");
 		goto cleanup_icmp;
 	}
 
 	ret = nf_register_hooks(ipv4_conntrack_ops,
 				ARRAY_SIZE(ipv4_conntrack_ops));
 	if (ret < 0) {
-		printk("nf_conntrack_ipv4: can't register hooks.\n");
+		printk(KERN_ERR "nf_conntrack_ipv4: can't register hooks.\n");
 		goto cleanup_ipv4;
 	}
 #if defined(CONFIG_PROC_FS) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index a868c8c..4446369 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -43,7 +43,7 @@ static int set_addr(struct sk_buff *skb,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
-				printk("nf_nat_h323: nf_nat_mangle_tcp_packet"
+				printk(KERN_ERR "nf_nat_h323: nf_nat_mangle_tcp_packet"
 				       " error\n");
 			return -1;
 		}
@@ -59,7 +59,7 @@ static int set_addr(struct sk_buff *skb,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
-				printk("nf_nat_h323: nf_nat_mangle_udp_packet"
+				printk(KERN_ERR "nf_nat_h323: nf_nat_mangle_udp_packet"
 				       " error\n");
 			return -1;
 		}
@@ -218,7 +218,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	/* Run out of expectations */
 	if (i >= H323_RTP_CHANNEL_MAX) {
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of expectations\n");
+			printk(KERN_WARNING "nf_nat_h323: out of expectations\n");
 		return 0;
 	}
 
@@ -237,7 +237,7 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of RTP ports\n");
+			printk(KERN_WARNING "nf_nat_h323: out of RTP ports\n");
 		return 0;
 	}
 
@@ -294,7 +294,7 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_h323: out of TCP ports\n");
+			printk(KERN_WARNING "nf_nat_h323: out of TCP ports\n");
 		return 0;
 	}
 
@@ -344,7 +344,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_q931: out of TCP ports\n");
+			printk(KERN_WARNING "nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
@@ -432,7 +432,7 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_ras: out of TCP ports\n");
+			printk(KERN_WARNING "nf_nat_ras: out of TCP ports\n");
 		return 0;
 	}
 
@@ -518,7 +518,7 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 
 	if (nated_port == 0) {	/* No port available */
 		if (net_ratelimit())
-			printk("nf_nat_q931: out of TCP ports\n");
+			printk(KERN_WARNING "nf_nat_q931: out of TCP ports\n");
 		return 0;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 46b25ab..7fa78c8 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -99,8 +99,8 @@ static void warn_if_extra_mangle(__be32 dstip, __be32 srcip)
 		return;
 
 	if (rt->rt_src != srcip && !warned) {
-		printk("NAT: no longer support implicit source local NAT\n");
-		printk("NAT: packet src %u.%u.%u.%u -> dst %u.%u.%u.%u\n",
+		printk(KERN_WARNING "NAT: no longer support implicit source local NAT\n");
+		printk(KERN_WARNING "NAT: packet src %u.%u.%u.%u -> dst %u.%u.%u.%u\n",
 		       NIPQUAD(srcip), NIPQUAD(dstip));
 		warned = 1;
 	}
@@ -144,7 +144,7 @@ static bool ipt_snat_checkentry(const char *tablename,
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
-		printk("SNAT: multiple ranges no longer supported\n");
+		printk(KERN_ERR "SNAT: multiple ranges no longer supported\n");
 		return false;
 	}
 	return true;
@@ -160,7 +160,7 @@ static bool ipt_dnat_checkentry(const char *tablename,
 
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
-		printk("DNAT: multiple ranges no longer supported\n");
+		printk(KERN_ERR "DNAT: multiple ranges no longer supported\n");
 		return false;
 	}
 	return true;
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 03709d6..1be8350 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -390,7 +390,7 @@ static unsigned char asn1_octets_decode(struct asn1_ctx *ctx,
 	*octets = kmalloc(eoc - ctx->pointer, GFP_ATOMIC);
 	if (*octets == NULL) {
 		if (net_ratelimit())
-			printk("OOM in bsalg (%d)\n", __LINE__);
+			printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 		return 0;
 	}
 
@@ -436,7 +436,7 @@ static unsigned char asn1_oid_decode(struct asn1_ctx *ctx,
 	*oid = kmalloc(size * sizeof(unsigned long), GFP_ATOMIC);
 	if (*oid == NULL) {
 		if (net_ratelimit())
-			printk("OOM in bsalg (%d)\n", __LINE__);
+			printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 		return 0;
 	}
 
@@ -714,7 +714,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			(*obj)->syntax.l[0] = l;
@@ -730,7 +730,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.c, p, len);
@@ -745,7 +745,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			if (!asn1_null_decode(ctx, end)) {
@@ -766,7 +766,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 				kfree(lp);
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.ul, lp, len);
@@ -787,7 +787,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 				kfree(p);
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			memcpy((*obj)->syntax.uc, p, len);
@@ -805,7 +805,7 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 			if (*obj == NULL) {
 				kfree(id);
 				if (net_ratelimit())
-					printk("OOM in bsalg (%d)\n", __LINE__);
+					printk(KERN_WARNING "OOM in bsalg (%d)\n", __LINE__);
 				return 0;
 			}
 			(*obj)->syntax.ul[0] = ul;


