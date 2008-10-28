From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 4/6v2] netfilter: replace uses of NIP6_FMT with %p6
Date: Tue, 28 Oct 2008 13:13:35 -0700
Message-ID: <1225224815.11483.56.camel@brick>
References: <1225223641.11483.42.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:36920 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbYJ1UNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:13:44 -0400
Received: by wx-out-0506.google.com with SMTP id h27so939210wxd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 13:13:40 -0700 (PDT)
In-Reply-To: <1225223641.11483.42.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
This has the other fix left in my working tree, sorry.

 net/netfilter/ipvs/ip_vs_conn.c         |   20 ++++++++------------
 net/netfilter/ipvs/ip_vs_core.c         |    8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c          |    8 ++++----
 net/netfilter/ipvs/ip_vs_proto.c        |   19 +++++++------------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    5 ++---
 net/netfilter/ipvs/ip_vs_xmit.c         |   17 ++++++++---------
 net/netfilter/nf_conntrack_ftp.c        |    8 +++-----
 net/netfilter/nf_conntrack_h323_main.c  |   12 ++++--------
 net/netfilter/xt_hashlimit.c            |    7 +++----
 net/netfilter/xt_recent.c               |    5 ++---
 10 files changed, 45 insertions(+), 64 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 9a24332..89bf65b 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -820,13 +820,11 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq,
-				"%-3s " NIP6_FMT " %04X " NIP6_FMT
-				" %04X " NIP6_FMT " %04X %-11s %7lu\n",
+			seq_printf(seq, "%-3s %p6 %04X %p6 %04X %p6 %04X %-11s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
-				NIP6(cp->caddr.in6), ntohs(cp->cport),
-				NIP6(cp->vaddr.in6), ntohs(cp->vport),
-				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				&cp->caddr.in6, ntohs(cp->cport),
+				&cp->vaddr.in6, ntohs(cp->vport),
+				&cp->daddr.in6, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ);
 		else
@@ -883,13 +881,11 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq,
-				"%-3s " NIP6_FMT " %04X " NIP6_FMT
-				" %04X " NIP6_FMT " %04X %-11s %-6s %7lu\n",
+			seq_printf(seq, "%-3s %p6 %04X %p6 %04X %p6 %04X %-11s %-6s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
-				NIP6(cp->caddr.in6), ntohs(cp->cport),
-				NIP6(cp->vaddr.in6), ntohs(cp->vport),
-				NIP6(cp->daddr.in6), ntohs(cp->dport),
+				&cp->caddr.in6, ntohs(cp->cport),
+				&cp->vaddr.in6, ntohs(cp->vport),
+				&cp->daddr.in6, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				ip_vs_origin_name(cp->flags),
 				(cp->timer.expires-jiffies)/HZ);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 958abf3..9400587 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -805,9 +805,9 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
+	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %p6->%p6\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
-		  NIP6(iph->saddr), NIP6(iph->daddr));
+		  &iph->saddr, &iph->daddr);
 
 	/*
 	 * Work through seeing if this is for us.
@@ -1175,9 +1175,9 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (ic == NULL)
 		return NF_DROP;
 
-	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
+	IP_VS_DBG(12, "Incoming ICMPv6 (%d,%d) %p6->%p6\n",
 		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
-		  NIP6(iph->saddr), NIP6(iph->daddr));
+		  &iph->saddr, &iph->daddr);
 
 	/*
 	 * Work through seeing if this is for us.
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 0302cf3..28c47c0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1867,9 +1867,9 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
-				seq_printf(seq, "%s  [" NIP6_FMT "]:%04X %s ",
+				seq_printf(seq, "%s  [%p6]:%04X %s ",
 					   ip_vs_proto_name(svc->protocol),
-					   NIP6(svc->addr.in6),
+					   &svc->addr.in6,
 					   ntohs(svc->port),
 					   svc->scheduler->name);
 			else
@@ -1895,9 +1895,9 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 #ifdef CONFIG_IP_VS_IPV6
 			if (dest->af == AF_INET6)
 				seq_printf(seq,
-					   "  -> [" NIP6_FMT "]:%04X"
+					   "  -> [%p6]:%04X"
 					   "      %-7s %-6d %-10d %-10d\n",
-					   NIP6(dest->addr.in6),
+					   &dest->addr.in6,
 					   ntohs(dest->port),
 					   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
 					   atomic_read(&dest->weight),
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 0791f9e..dff5f38 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -203,26 +203,21 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT " frag",
-			pp->name, NIP6(ih->saddr),
-			NIP6(ih->daddr));
+		sprintf(buf, "%s %p6->%p6 frag",
+			pp->name, &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
 
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED " NIP6_FMT "->" NIP6_FMT,
-				pp->name,
-				NIP6(ih->saddr),
-				NIP6(ih->daddr));
+			sprintf(buf, "%s TRUNCATED %p6->%p6",
+				pp->name, &ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s " NIP6_FMT ":%u->" NIP6_FMT ":%u",
+			sprintf(buf, "%s %p6:%u->%p6:%u",
 				pp->name,
-				NIP6(ih->saddr),
-				ntohs(pptr[0]),
-				NIP6(ih->daddr),
-				ntohs(pptr[1]));
+				&ih->saddr, ntohs(pptr[0]),
+				&ih->daddr, ntohs(pptr[1]));
 	}
 
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 80ab0c8..59f2d11 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -154,9 +154,8 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
 	else
-		sprintf(buf, "%s " NIP6_FMT "->" NIP6_FMT,
-			pp->name, NIP6(ih->saddr),
-			NIP6(ih->daddr));
+		sprintf(buf, "%s %p6->%p6",
+			pp->name, &ih->saddr, &ih->daddr);
 
 	printk(KERN_DEBUG "IPVS: %s: %s\n", msg, buf);
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 02ddc2b..be34c33 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -141,14 +141,13 @@ __ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
 								 NULL, &fl);
 			if (!rt) {
 				spin_unlock(&dest->dst_lock);
-				IP_VS_DBG_RL("ip6_route_output error, "
-					     "dest: " NIP6_FMT "\n",
-					     NIP6(dest->addr.in6));
+				IP_VS_DBG_RL("ip6_route_output error, dest: %p6\n",
+					     &dest->addr.in6);
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, 0, dst_clone(&rt->u.dst));
-			IP_VS_DBG(10, "new dst " NIP6_FMT ", refcnt=%d\n",
-				  NIP6(dest->addr.in6),
+			IP_VS_DBG(10, "new dst %p6, refcnt=%d\n",
+				  &dest->addr.in6,
 				  atomic_read(&rt->u.dst.__refcnt));
 		}
 		spin_unlock(&dest->dst_lock);
@@ -167,8 +166,8 @@ __ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
 
 		rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
 		if (!rt) {
-			IP_VS_DBG_RL("ip6_route_output error, dest: "
-				     NIP6_FMT "\n", NIP6(cp->daddr.in6));
+			IP_VS_DBG_RL("ip6_route_output error, dest: %p6\n",
+				     &cp->daddr.in6);
 			return NULL;
 		}
 	}
@@ -301,8 +300,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
 	if (!rt) {
-		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, "
-			     "dest: " NIP6_FMT "\n", NIP6(iph->daddr));
+		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, dest: %p6\n",
+			     &iph->daddr);
 		goto tx_error_icmp;
 	}
 
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 4f71071..a90d463 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -467,11 +467,9 @@ static int help(struct sk_buff *skb,
 				 NIPQUAD(cmd.u3.ip),
 				 NIPQUAD(ct->tuplehash[dir].tuple.src.u3.ip));
 		} else {
-			pr_debug("conntrack_ftp: NOT RECORDING: " NIP6_FMT
-				 " != " NIP6_FMT "\n",
-				 NIP6(*((struct in6_addr *)cmd.u3.ip6)),
-				 NIP6(*((struct in6_addr *)
-					ct->tuplehash[dir].tuple.src.u3.ip6)));
+			pr_debug("conntrack_ftp: NOT RECORDING: %p6 != %p6\n",
+				 cmd.u3.ip6, 
+				 ct->tuplehash[dir].tuple.src.u3.ip6);
 		}
 
 		/* Thanks to Cristiano Lincoln Mattos
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index c1504f7..29e49b1 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -850,10 +850,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set destCallSignalAddress "
-			 NIP6_FMT ":%hu->" NIP6_FMT ":%hu\n",
-			 NIP6(*(struct in6_addr *)&addr), ntohs(port),
-			 NIP6(*(struct in6_addr *)&ct->tuplehash[!dir].tuple.src.u3),
+		pr_debug("nf_ct_q931: set destCallSignalAddress %p6:%hu->%p6:%hu\n",
+			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
 				    &setup->destCallSignalAddress,
@@ -868,10 +866,8 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set sourceCallSignalAddress "
-			 NIP6_FMT ":%hu->" NIP6_FMT ":%hu\n",
-			 NIP6(*(struct in6_addr *)&addr), ntohs(port),
-			 NIP6(*(struct in6_addr *)&ct->tuplehash[!dir].tuple.dst.u3),
+		pr_debug("nf_ct_q931: set sourceCallSignalAddress %p6:%hu->%p6:%hu\n",
+			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
 				    &setup->sourceCallSignalAddress,
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 6fc4292..f04c6ed 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -904,12 +904,11 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 				 ent->rateinfo.cost);
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	case NFPROTO_IPV6:
-		return seq_printf(s, "%ld " NIP6_FMT ":%u->"
-				     NIP6_FMT ":%u %u %u %u\n",
+		return seq_printf(s, "%ld %p6:%u->%p6:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
-				 NIP6(*(struct in6_addr *)&ent->dst.ip6.src),
+				 &ent->dst.ip6.src,
 				 ntohs(ent->dst.src_port),
-				 NIP6(*(struct in6_addr *)&ent->dst.ip6.dst),
+				 &ent->dst.ip6.dst,
 				 ntohs(ent->dst.dst_port),
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 280c471..a377ea3 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -426,9 +426,8 @@ static int recent_seq_show(struct seq_file *seq, void *v)
 			   "oldest_pkt: %u", NIPQUAD(e->addr.ip), e->ttl,
 			   e->stamps[i], e->index);
 	else
-		seq_printf(seq, "src=" NIP6_FMT " ttl: %u last_seen: %lu "
-			   "oldest_pkt: %u", NIP6(e->addr.in6), e->ttl,
-			   e->stamps[i], e->index);
+		seq_printf(seq, "src=%p6 ttl: %u last_seen: %lu oldest_pkt: %u",
+			   &e->addr.in6, e->ttl, e->stamps[i], e->index);
 	for (i = 0; i < e->nstamps; i++)
 		seq_printf(seq, "%s %lu", i ? "," : "", e->stamps[i]);
 	seq_printf(seq, "\n");
-- 
1.6.0.3.729.g6ea410

