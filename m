From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/7] net: replace NIPQUAD() in net/ipv4/netfilter/
Date: Thu, 30 Oct 2008 17:13:43 -0700
Message-ID: <1225412024.5574.32.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:39632 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbYJaANq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:46 -0400
Received: by wf-out-1314.google.com with SMTP id 27so879384wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, these should all be _exact_ replacements, the few remaining in
tree occurences of NIPQUAD will need looking at, especially the
ones using %u,%u,%u,%u (note the commas)

 net/ipv4/netfilter/arp_tables.c                |   16 +++---
 net/ipv4/netfilter/ip_tables.c                 |   12 ++---
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    9 ++--
 net/ipv4/netfilter/ipt_LOG.c                   |    7 +--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   15 +++---
 net/ipv4/netfilter/nf_nat_h323.c               |   58 +++++++++++-------------
 net/ipv4/netfilter/nf_nat_irc.c                |    4 +-
 net/ipv4/netfilter/nf_nat_rule.c               |    6 +--
 net/ipv4/netfilter/nf_nat_sip.c                |   18 +++----
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |    9 ++--
 10 files changed, 69 insertions(+), 85 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 8d70d29..7ea88b6 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -142,15 +142,15 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 		  ARPT_INV_TGTIP)) {
 		dprintf("Source or target IP address mismatch.\n");
 
-		dprintf("SRC: %u.%u.%u.%u. Mask: %u.%u.%u.%u. Target: %u.%u.%u.%u.%s\n",
-			NIPQUAD(src_ipaddr),
-			NIPQUAD(arpinfo->smsk.s_addr),
-			NIPQUAD(arpinfo->src.s_addr),
+		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
+			&src_ipaddr,
+			&arpinfo->smsk.s_addr,
+			&arpinfo->src.s_addr,
 			arpinfo->invflags & ARPT_INV_SRCIP ? " (INV)" : "");
-		dprintf("TGT: %u.%u.%u.%u Mask: %u.%u.%u.%u Target: %u.%u.%u.%u.%s\n",
-			NIPQUAD(tgt_ipaddr),
-			NIPQUAD(arpinfo->tmsk.s_addr),
-			NIPQUAD(arpinfo->tgt.s_addr),
+		dprintf("TGT: %pI4 Mask: %pI4 Target: %pI4.%s\n",
+			&tgt_ipaddr,
+			&arpinfo->tmsk.s_addr,
+			&arpinfo->tgt.s_addr,
 			arpinfo->invflags & ARPT_INV_TGTIP ? " (INV)" : "");
 		return 0;
 	}
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 213fb27..ef8b6ca 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -94,15 +94,11 @@ ip_packet_match(const struct iphdr *ip,
 		     IPT_INV_DSTIP)) {
 		dprintf("Source or dest mismatch.\n");
 
-		dprintf("SRC: %u.%u.%u.%u. Mask: %u.%u.%u.%u. Target: %u.%u.%u.%u.%s\n",
-			NIPQUAD(ip->saddr),
-			NIPQUAD(ipinfo->smsk.s_addr),
-			NIPQUAD(ipinfo->src.s_addr),
+		dprintf("SRC: %pI4. Mask: %pI4. Target: %pI4.%s\n",
+			&ip->saddr, &ipinfo->smsk.s_addr, &ipinfo->src.s_addr,
 			ipinfo->invflags & IPT_INV_SRCIP ? " (INV)" : "");
-		dprintf("DST: %u.%u.%u.%u Mask: %u.%u.%u.%u Target: %u.%u.%u.%u.%s\n",
-			NIPQUAD(ip->daddr),
-			NIPQUAD(ipinfo->dmsk.s_addr),
-			NIPQUAD(ipinfo->dst.s_addr),
+		dprintf("DST: %pI4 Mask: %pI4 Target: %pI4.%s\n",
+			&ip->daddr, &ipinfo->dmsk.s_addr, &ipinfo->dst.s_addr,
 			ipinfo->invflags & IPT_INV_DSTIP ? " (INV)" : "");
 		return false;
 	}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 7ac1677..2e4f98b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -168,7 +168,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 		char buffer[16];
 
 		/* create proc dir entry */
-		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
+		sprintf(buffer, "%pI4", &ip);
 		c->pde = proc_create_data(buffer, S_IWUSR|S_IRUSR,
 					  clusterip_procdir,
 					  &clusterip_proc_fops, c);
@@ -373,7 +373,7 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 	config = clusterip_config_find_get(e->ip.dst.s_addr, 1);
 	if (!config) {
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
-			printk(KERN_WARNING "CLUSTERIP: no config found for %u.%u.%u.%u, need 'new'\n", NIPQUAD(e->ip.dst.s_addr));
+			printk(KERN_WARNING "CLUSTERIP: no config found for %pI4, need 'new'\n", &e->ip.dst.s_addr);
 			return false;
 		} else {
 			struct net_device *dev;
@@ -478,9 +478,8 @@ static void arp_print(struct arp_payload *payload)
 	}
 	hbuffer[--k]='\0';
 
-	printk("src %u.%u.%u.%u@%s, dst %u.%u.%u.%u\n",
-		NIPQUAD(payload->src_ip), hbuffer,
-		NIPQUAD(payload->dst_ip));
+	printk("src %pI4@%s, dst %pI4\n",
+		&payload->src_ip, hbuffer, &payload->dst_ip);
 }
 #endif
 
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index fc6ce04..4614a69 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -54,8 +54,8 @@ static void dump_packet(const struct nf_loginfo *info,
 	/* Important fields:
 	 * TOS, len, DF/MF, fragment offset, TTL, src, dst, options. */
 	/* Max length: 40 "SRC=255.255.255.255 DST=255.255.255.255 " */
-	printk("SRC=%u.%u.%u.%u DST=%u.%u.%u.%u ",
-	       NIPQUAD(ih->saddr), NIPQUAD(ih->daddr));
+	printk("SRC=%pI4 DST=%pI4 ",
+	       &ih->saddr, &ih->daddr);
 
 	/* Max length: 46 "LEN=65535 TOS=0xFF PREC=0xFF TTL=255 ID=65535 " */
 	printk("LEN=%u TOS=0x%02X PREC=0x%02X TTL=%u ID=%u ",
@@ -262,8 +262,7 @@ static void dump_packet(const struct nf_loginfo *info,
 			break;
 		case ICMP_REDIRECT:
 			/* Max length: 24 "GATEWAY=255.255.255.255 " */
-			printk("GATEWAY=%u.%u.%u.%u ",
-			       NIPQUAD(ich->un.gateway));
+			printk("GATEWAY=%pI4 ", &ich->un.gateway);
 			/* Fall through */
 		case ICMP_DEST_UNREACH:
 		case ICMP_SOURCE_QUENCH:
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 4a7c352..bddadea 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -60,9 +60,8 @@ static bool ipv4_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int ipv4_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "src=%u.%u.%u.%u dst=%u.%u.%u.%u ",
-			  NIPQUAD(tuple->src.u3.ip),
-			  NIPQUAD(tuple->dst.u3.ip));
+	return seq_printf(s, "src=%pI4 dst=%pI4 ",
+			  &tuple->src.u3.ip, &tuple->dst.u3.ip);
 }
 
 static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
@@ -284,17 +283,17 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 			.tuple.dst.u3.ip;
 		memset(sin.sin_zero, 0, sizeof(sin.sin_zero));
 
-		pr_debug("SO_ORIGINAL_DST: %u.%u.%u.%u %u\n",
-			 NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
+		pr_debug("SO_ORIGINAL_DST: %pI4 %u\n",
+			 &sin.sin_addr.s_addr, ntohs(sin.sin_port));
 		nf_ct_put(ct);
 		if (copy_to_user(user, &sin, sizeof(sin)) != 0)
 			return -EFAULT;
 		else
 			return 0;
 	}
-	pr_debug("SO_ORIGINAL_DST: Can't find %u.%u.%u.%u/%u-%u.%u.%u.%u/%u.\n",
-		 NIPQUAD(tuple.src.u3.ip), ntohs(tuple.src.u.tcp.port),
-		 NIPQUAD(tuple.dst.u3.ip), ntohs(tuple.dst.u.tcp.port));
+	pr_debug("SO_ORIGINAL_DST: Can't find %pI4/%u-%pI4/%u.\n",
+		 &tuple.src.u3.ip, ntohs(tuple.src.u.tcp.port),
+		 &tuple.dst.u3.ip, ntohs(tuple.dst.u.tcp.port));
 	return -ENOENT;
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index ee47bf2..7e8e6fc 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -119,10 +119,9 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 				    (ntohl(addr.ip) & 0xff000000) == 0x7f000000)
 					i = 0;
 
-				pr_debug("nf_nat_ras: set signal address "
-					 "%u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-					 NIPQUAD(addr.ip), port,
-					 NIPQUAD(ct->tuplehash[!dir].tuple.dst.u3.ip),
+				pr_debug("nf_nat_ras: set signal address %pI4:%hu->%pI4:%hu\n",
+					 &addr.ip, port,
+					 &ct->tuplehash[!dir].tuple.dst.u3.ip,
 					 info->sig_port[!dir]);
 				return set_h225_addr(skb, data, 0, &taddr[i],
 						     &ct->tuplehash[!dir].
@@ -131,10 +130,9 @@ static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 			} else if (addr.ip == ct->tuplehash[dir].tuple.dst.u3.ip &&
 				   port == info->sig_port[dir]) {
 				/* GK->GW */
-				pr_debug("nf_nat_ras: set signal address "
-					 "%u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-					 NIPQUAD(addr.ip), port,
-					 NIPQUAD(ct->tuplehash[!dir].tuple.src.u3.ip),
+				pr_debug("nf_nat_ras: set signal address %pI4:%hu->%pI4:%hu\n",
+					 &addr.ip, port,
+					 &ct->tuplehash[!dir].tuple.src.u3.ip,
 					 info->sig_port[!dir]);
 				return set_h225_addr(skb, data, 0, &taddr[i],
 						     &ct->tuplehash[!dir].
@@ -162,10 +160,9 @@ static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 		if (get_h225_addr(ct, *data, &taddr[i], &addr, &port) &&
 		    addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
 		    port == ct->tuplehash[dir].tuple.src.u.udp.port) {
-			pr_debug("nf_nat_ras: set rasAddress "
-				 "%u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-				 NIPQUAD(addr.ip), ntohs(port),
-				 NIPQUAD(ct->tuplehash[!dir].tuple.dst.u3.ip),
+			pr_debug("nf_nat_ras: set rasAddress %pI4:%hu->%pI4:%hu\n",
+				 &addr.ip, ntohs(port),
+				 &ct->tuplehash[!dir].tuple.dst.u3.ip,
 				 ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port));
 			return set_h225_addr(skb, data, 0, &taddr[i],
 					     &ct->tuplehash[!dir].tuple.dst.u3,
@@ -257,15 +254,15 @@ static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Success */
-	pr_debug("nf_nat_h323: expect RTP %u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(rtp_exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_h323: expect RTP %pI4:%hu->%pI4:%hu\n",
+		 &rtp_exp->tuple.src.u3.ip,
 		 ntohs(rtp_exp->tuple.src.u.udp.port),
-		 NIPQUAD(rtp_exp->tuple.dst.u3.ip),
+		 &rtp_exp->tuple.dst.u3.ip,
 		 ntohs(rtp_exp->tuple.dst.u.udp.port));
-	pr_debug("nf_nat_h323: expect RTCP %u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(rtcp_exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_h323: expect RTCP %pI4:%hu->%pI4:%hu\n",
+		 &rtcp_exp->tuple.src.u3.ip,
 		 ntohs(rtcp_exp->tuple.src.u.udp.port),
-		 NIPQUAD(rtcp_exp->tuple.dst.u3.ip),
+		 &rtcp_exp->tuple.dst.u3.ip,
 		 ntohs(rtcp_exp->tuple.dst.u.udp.port));
 
 	return 0;
@@ -307,10 +304,10 @@ static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 		return -1;
 	}
 
-	pr_debug("nf_nat_h323: expect T.120 %u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_h323: expect T.120 %pI4:%hu->%pI4:%hu\n",
+		 &exp->tuple.src.u3.ip,
 		 ntohs(exp->tuple.src.u.tcp.port),
-		 NIPQUAD(exp->tuple.dst.u3.ip),
+		 &exp->tuple.dst.u3.ip,
 		 ntohs(exp->tuple.dst.u.tcp.port));
 
 	return 0;
@@ -361,10 +358,10 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 		return -1;
 	}
 
-	pr_debug("nf_nat_q931: expect H.245 %u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_q931: expect H.245 %pI4:%hu->%pI4:%hu\n",
+		 &exp->tuple.src.u3.ip,
 		 ntohs(exp->tuple.src.u.tcp.port),
-		 NIPQUAD(exp->tuple.dst.u3.ip),
+		 &exp->tuple.dst.u3.ip,
 		 ntohs(exp->tuple.dst.u.tcp.port));
 
 	return 0;
@@ -455,10 +452,10 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Success */
-	pr_debug("nf_nat_ras: expect Q.931 %u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_ras: expect Q.931 %pI4:%hu->%pI4:%hu\n",
+		 &exp->tuple.src.u3.ip,
 		 ntohs(exp->tuple.src.u.tcp.port),
-		 NIPQUAD(exp->tuple.dst.u3.ip),
+		 &exp->tuple.dst.u3.ip,
 		 ntohs(exp->tuple.dst.u.tcp.port));
 
 	return 0;
@@ -524,11 +521,10 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	/* Success */
-	pr_debug("nf_nat_q931: expect Call Forwarding "
-		 "%u.%u.%u.%u:%hu->%u.%u.%u.%u:%hu\n",
-		 NIPQUAD(exp->tuple.src.u3.ip),
+	pr_debug("nf_nat_q931: expect Call Forwarding %pI4:%hu->%pI4:%hu\n",
+		 &exp->tuple.src.u3.ip,
 		 ntohs(exp->tuple.src.u.tcp.port),
-		 NIPQUAD(exp->tuple.dst.u3.ip),
+		 &exp->tuple.dst.u3.ip,
 		 ntohs(exp->tuple.dst.u.tcp.port));
 
 	return 0;
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
index fe6f9ce..ea83a88 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/ipv4/netfilter/nf_nat_irc.c
@@ -55,8 +55,8 @@ static unsigned int help(struct sk_buff *skb,
 
 	ip = ntohl(exp->master->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip);
 	sprintf(buffer, "%u %u", ip, port);
-	pr_debug("nf_nat_irc: inserting '%s' == %u.%u.%u.%u, port %u\n",
-		 buffer, NIPQUAD(ip), port);
+	pr_debug("nf_nat_irc: inserting '%s' == %pI4, port %u\n",
+		 buffer, &ip, port);
 
 	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
 				       matchoff, matchlen, buffer,
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index bea54a6..a4f1c34 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -98,8 +98,7 @@ static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
 
 	if (rt->rt_src != srcip && !warned) {
 		printk("NAT: no longer support implicit source local NAT\n");
-		printk("NAT: packet src %u.%u.%u.%u -> dst %u.%u.%u.%u\n",
-		       NIPQUAD(srcip), NIPQUAD(dstip));
+		printk("NAT: packet src %pI4 -> dst %pI4\n", &srcip, &dstip);
 		warned = 1;
 	}
 	ip_rt_put(rt);
@@ -166,8 +165,7 @@ alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 	struct nf_nat_range range
 		= { IP_NAT_RANGE_MAP_IPS, ip, ip, { 0 }, { 0 } };
 
-	pr_debug("Allocating NULL binding for %p (%u.%u.%u.%u)\n",
-		 ct, NIPQUAD(ip));
+	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct, &ip);
 	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 1454432..07d61a5 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -74,8 +74,7 @@ static int map_addr(struct sk_buff *skb,
 	if (newaddr == addr->ip && newport == port)
 		return 1;
 
-	buflen = sprintf(buffer, "%u.%u.%u.%u:%u",
-			 NIPQUAD(newaddr), ntohs(newport));
+	buflen = sprintf(buffer, "%pI4:%u", &newaddr, ntohs(newport));
 
 	return mangle_packet(skb, dptr, datalen, matchoff, matchlen,
 			     buffer, buflen);
@@ -152,8 +151,8 @@ static unsigned int ip_nat_sip(struct sk_buff *skb,
 					       &addr) > 0 &&
 		    addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
 		    addr.ip != ct->tuplehash[!dir].tuple.dst.u3.ip) {
-			__be32 ip = ct->tuplehash[!dir].tuple.dst.u3.ip;
-			buflen = sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
+			buflen = sprintf(buffer, "%pI4",
+					&ct->tuplehash[!dir].tuple.dst.u3.ip);
 			if (!mangle_packet(skb, dptr, datalen, poff, plen,
 					   buffer, buflen))
 				return NF_DROP;
@@ -166,8 +165,8 @@ static unsigned int ip_nat_sip(struct sk_buff *skb,
 					       &addr) > 0 &&
 		    addr.ip == ct->tuplehash[dir].tuple.dst.u3.ip &&
 		    addr.ip != ct->tuplehash[!dir].tuple.src.u3.ip) {
-			__be32 ip = ct->tuplehash[!dir].tuple.src.u3.ip;
-			buflen = sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
+			buflen = sprintf(buffer, "%pI4",
+					&ct->tuplehash[!dir].tuple.src.u3.ip);
 			if (!mangle_packet(skb, dptr, datalen, poff, plen,
 					   buffer, buflen))
 				return NF_DROP;
@@ -279,8 +278,7 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb,
 
 	if (exp->tuple.dst.u3.ip != exp->saved_ip ||
 	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
-		buflen = sprintf(buffer, "%u.%u.%u.%u:%u",
-				 NIPQUAD(newip), port);
+		buflen = sprintf(buffer, "%pI4:%u", &newip, port);
 		if (!mangle_packet(skb, dptr, datalen, matchoff, matchlen,
 				   buffer, buflen))
 			goto err;
@@ -345,7 +343,7 @@ static unsigned int ip_nat_sdp_addr(struct sk_buff *skb, const char **dptr,
 	char buffer[sizeof("nnn.nnn.nnn.nnn")];
 	unsigned int buflen;
 
-	buflen = sprintf(buffer, NIPQUAD_FMT, NIPQUAD(addr->ip));
+	buflen = sprintf(buffer, "%pI4", &addr->ip);
 	if (mangle_sdp_packet(skb, dptr, dataoff, datalen, type, term,
 			      buffer, buflen))
 		return 0;
@@ -380,7 +378,7 @@ static unsigned int ip_nat_sdp_session(struct sk_buff *skb, const char **dptr,
 	unsigned int buflen;
 
 	/* Mangle session description owner and contact addresses */
-	buflen = sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(addr->ip));
+	buflen = sprintf(buffer, "%pI4", &addr->ip);
 	if (mangle_sdp_packet(skb, dptr, dataoff, datalen,
 			       SDP_HDR_OWNER_IP4, SDP_HDR_MEDIA,
 			       buffer, buflen))
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 8303e4b..182f845 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -930,8 +930,8 @@ static inline void mangle_address(unsigned char *begin,
 		}
 
 		if (debug)
-			printk(KERN_DEBUG "bsalg: mapped %u.%u.%u.%u to "
-			       "%u.%u.%u.%u\n", NIPQUAD(old), NIPQUAD(*addr));
+			printk(KERN_DEBUG "bsalg: mapped %pI4 to %pI4\n",
+			       &old, addr);
 	}
 }
 
@@ -1267,9 +1267,8 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 	 */
 	if (ntohs(udph->len) != skb->len - (iph->ihl << 2)) {
 		 if (net_ratelimit())
-			 printk(KERN_WARNING "SNMP: dropping malformed packet "
-				"src=%u.%u.%u.%u dst=%u.%u.%u.%u\n",
-				NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+			 printk(KERN_WARNING "SNMP: dropping malformed packet src=%pI4 dst=%pI4\n",
+				&iph->saddr, &iph->daddr);
 		 return NF_DROP;
 	}
 
-- 
1.6.0.3.756.gb776d


