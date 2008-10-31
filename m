From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/7] net: replace NIPQUAD() in net/ipv4/ net/ipv6/
Date: Thu, 30 Oct 2008 17:13:44 -0700
Message-ID: <1225412024.5574.33.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:39632 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYJaANs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:48 -0400
Received: by wf-out-1314.google.com with SMTP id 27so879384wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/ipv4/af_inet.c            |    7 ++-----
 net/ipv4/arp.c                |    4 ++--
 net/ipv4/fib_trie.c           |    6 +++---
 net/ipv4/icmp.c               |   24 ++++++++++--------------
 net/ipv4/ip_fragment.c        |    5 ++---
 net/ipv4/ip_input.c           |    6 ++----
 net/ipv4/ipcomp.c             |    4 ++--
 net/ipv4/ipconfig.c           |   40 ++++++++++++++++++----------------------
 net/ipv4/route.c              |   40 +++++++++++++++++-----------------------
 net/ipv4/tcp_input.c          |    4 ++--
 net/ipv4/tcp_ipv4.c           |   13 +++++--------
 net/ipv4/tcp_probe.c          |    7 +++----
 net/ipv4/tcp_timer.c          |    4 ++--
 net/ipv4/udp.c                |   12 ++++++------
 net/ipv6/netfilter/ip6t_LOG.c |    5 ++---
 15 files changed, 78 insertions(+), 103 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1fbff5f..e328681 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1070,11 +1070,8 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		return 0;
 
 	if (sysctl_ip_dynaddr > 1) {
-		printk(KERN_INFO "%s(): shifting inet->"
-				 "saddr from " NIPQUAD_FMT " to " NIPQUAD_FMT "\n",
-		       __func__,
-		       NIPQUAD(old_saddr),
-		       NIPQUAD(new_saddr));
+		printk(KERN_INFO "%s(): shifting inet->saddr from %pI4 to %pI4\n",
+		       __func__, &old_saddr, &new_saddr);
 	}
 
 	inet->saddr = inet->rcv_saddr = new_saddr;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9dd66..051a62f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1308,7 +1308,7 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	}
 #endif
-	sprintf(tbuf, NIPQUAD_FMT, NIPQUAD(*(u32*)n->primary_key));
+	sprintf(tbuf, "%pI4", n->primary_key);
 	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
 		   tbuf, hatype, arp_state_to_flags(n), hbuffer, dev->name);
 	read_unlock(&n->lock);
@@ -1321,7 +1321,7 @@ static void arp_format_pneigh_entry(struct seq_file *seq,
 	int hatype = dev ? dev->type : 0;
 	char tbuf[16];
 
-	sprintf(tbuf, NIPQUAD_FMT, NIPQUAD(*(u32*)n->key));
+	sprintf(tbuf, "%pI4", n->key);
 	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
 		   tbuf, hatype, ATF_PUBL | ATF_PERM, "00:00:00:00:00:00",
 		   dev ? dev->name : "*");
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5cb7278..ec0ae49 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2399,8 +2399,8 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
 		seq_indent(seq, iter->depth-1);
-		seq_printf(seq, "  +-- " NIPQUAD_FMT "/%d %d %d %d\n",
-			   NIPQUAD(prf), tn->pos, tn->bits, tn->full_children,
+		seq_printf(seq, "  +-- %pI4/%d %d %d %d\n",
+			   &prf, tn->pos, tn->bits, tn->full_children,
 			   tn->empty_children);
 
 	} else {
@@ -2410,7 +2410,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		__be32 val = htonl(l->key);
 
 		seq_indent(seq, iter->depth);
-		seq_printf(seq, "  |-- " NIPQUAD_FMT "\n", NIPQUAD(val));
+		seq_printf(seq, "  |-- %pI4\n", &val);
 
 		hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
 			struct fib_alias *fa;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e9d6ea0..21e497e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -683,10 +683,8 @@ static void icmp_unreach(struct sk_buff *skb)
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				LIMIT_NETDEBUG(KERN_INFO "ICMP: " NIPQUAD_FMT ": "
-							 "fragmentation needed "
-							 "and DF set.\n",
-					       NIPQUAD(iph->daddr));
+				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: fragmentation needed and DF set.\n",
+					       &iph->daddr);
 			} else {
 				info = ip_rt_frag_needed(net, iph,
 							 ntohs(icmph->un.frag.mtu),
@@ -696,9 +694,8 @@ static void icmp_unreach(struct sk_buff *skb)
 			}
 			break;
 		case ICMP_SR_FAILED:
-			LIMIT_NETDEBUG(KERN_INFO "ICMP: " NIPQUAD_FMT ": Source "
-						 "Route Failed.\n",
-				       NIPQUAD(iph->daddr));
+			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: Source Route Failed.\n",
+				       &iph->daddr);
 			break;
 		default:
 			break;
@@ -729,12 +726,12 @@ static void icmp_unreach(struct sk_buff *skb)
 	if (!net->ipv4.sysctl_icmp_ignore_bogus_error_responses &&
 	    inet_addr_type(net, iph->daddr) == RTN_BROADCAST) {
 		if (net_ratelimit())
-			printk(KERN_WARNING NIPQUAD_FMT " sent an invalid ICMP "
+			printk(KERN_WARNING "%pI4 sent an invalid ICMP "
 					    "type %u, code %u "
-					    "error to a broadcast: " NIPQUAD_FMT " on %s\n",
-			       NIPQUAD(ip_hdr(skb)->saddr),
+					    "error to a broadcast: %pI4 on %s\n",
+			       &ip_hdr(skb)->saddr,
 			       icmph->type, icmph->code,
-			       NIPQUAD(iph->daddr),
+			       &iph->daddr,
 			       skb->dev->name);
 		goto out;
 	}
@@ -952,9 +949,8 @@ static void icmp_address_reply(struct sk_buff *skb)
 				break;
 		}
 		if (!ifa && net_ratelimit()) {
-			printk(KERN_INFO "Wrong address mask " NIPQUAD_FMT " from "
-					 "%s/" NIPQUAD_FMT "\n",
-			       NIPQUAD(*mp), dev->name, NIPQUAD(rt->rt_src));
+			printk(KERN_INFO "Wrong address mask %pI4 from %s/%pI4\n",
+			       mp, dev->name, &rt->rt_src);
 		}
 	}
 	rcu_read_unlock();
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e4f81f5..8c495e3 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -559,9 +559,8 @@ out_nomem:
 	goto out_fail;
 out_oversize:
 	if (net_ratelimit())
-		printk(KERN_INFO
-			"Oversized IP packet from " NIPQUAD_FMT ".\n",
-			NIPQUAD(qp->saddr));
+		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
+			&qp->saddr);
 out_fail:
 	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
 	return err;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 861978a..1b6475c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -294,10 +294,8 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 			if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
 				if (IN_DEV_LOG_MARTIANS(in_dev) &&
 				    net_ratelimit())
-					printk(KERN_INFO "source route option "
-					       NIPQUAD_FMT " -> " NIPQUAD_FMT "\n",
-					       NIPQUAD(iph->saddr),
-					       NIPQUAD(iph->daddr));
+					printk(KERN_INFO "source route option %pI4 -> %pI4\n",
+					       &iph->saddr, &iph->daddr);
 				in_dev_put(in_dev);
 				goto drop;
 			}
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 38ccb6d..ec8264a 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -39,8 +39,8 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/" NIPQUAD_FMT "\n",
-		 spi, NIPQUAD(iph->daddr));
+	NETDEBUG(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%pI4\n",
+		 spi, &iph->daddr);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 42065ff..42a0f3d 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -374,7 +374,7 @@ static int __init ic_defaults(void)
 	 */
 
 	if (!ic_host_name_set)
-		sprintf(init_utsname()->nodename, NIPQUAD_FMT, NIPQUAD(ic_myaddr));
+		sprintf(init_utsname()->nodename, "%pI4", &ic_myaddr);
 
 	if (root_server_addr == NONE)
 		root_server_addr = ic_servaddr;
@@ -387,11 +387,11 @@ static int __init ic_defaults(void)
 		else if (IN_CLASSC(ntohl(ic_myaddr)))
 			ic_netmask = htonl(IN_CLASSC_NET);
 		else {
-			printk(KERN_ERR "IP-Config: Unable to guess netmask for address " NIPQUAD_FMT "\n",
-				NIPQUAD(ic_myaddr));
+			printk(KERN_ERR "IP-Config: Unable to guess netmask for address %pI4\n",
+				&ic_myaddr);
 			return -1;
 		}
-		printk("IP-Config: Guessing netmask " NIPQUAD_FMT "\n", NIPQUAD(ic_netmask));
+		printk("IP-Config: Guessing netmask %pI4\n", &ic_netmask);
 	}
 
 	return 0;
@@ -979,10 +979,8 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 				ic_myaddr = b->your_ip;
 				ic_servaddr = server_id;
 #ifdef IPCONFIG_DEBUG
-				printk("DHCP: Offered address " NIPQUAD_FMT,
-				       NIPQUAD(ic_myaddr));
-				printk(" by server " NIPQUAD_FMT "\n",
-				       NIPQUAD(ic_servaddr));
+				printk("DHCP: Offered address %pI4 by server %pI4\n",
+				       &ic_myaddr, &ic_servaddr);
 #endif
 				/* The DHCP indicated server address takes
 				 * precedence over the bootp header one if
@@ -1177,11 +1175,11 @@ static int __init ic_dynamic(void)
 		return -1;
 	}
 
-	printk("IP-Config: Got %s answer from " NIPQUAD_FMT ", ",
+	printk("IP-Config: Got %s answer from %pI4, ",
 		((ic_got_reply & IC_RARP) ? "RARP"
 		 : (ic_proto_enabled & IC_USE_DHCP) ? "DHCP" : "BOOTP"),
-		NIPQUAD(ic_servaddr));
-	printk("my address is " NIPQUAD_FMT "\n", NIPQUAD(ic_myaddr));
+		&ic_servaddr);
+	printk("my address is %pI4\n", &ic_myaddr);
 
 	return 0;
 }
@@ -1206,14 +1204,12 @@ static int pnp_seq_show(struct seq_file *seq, void *v)
 			   "domain %s\n", ic_domain);
 	for (i = 0; i < CONF_NAMESERVERS_MAX; i++) {
 		if (ic_nameservers[i] != NONE)
-			seq_printf(seq,
-				   "nameserver " NIPQUAD_FMT "\n",
-				   NIPQUAD(ic_nameservers[i]));
+			seq_printf(seq, "nameserver %pI4\n",
+				   &ic_nameservers[i]);
 	}
 	if (ic_servaddr != NONE)
-		seq_printf(seq,
-			   "bootserver " NIPQUAD_FMT "\n",
-			   NIPQUAD(ic_servaddr));
+		seq_printf(seq, "bootserver %pI4\n",
+			   &ic_servaddr);
 	return 0;
 }
 
@@ -1387,13 +1383,13 @@ static int __init ip_auto_config(void)
 	 */
 	printk("IP-Config: Complete:");
 	printk("\n     device=%s", ic_dev->name);
-	printk(", addr=" NIPQUAD_FMT, NIPQUAD(ic_myaddr));
-	printk(", mask=" NIPQUAD_FMT, NIPQUAD(ic_netmask));
-	printk(", gw=" NIPQUAD_FMT, NIPQUAD(ic_gateway));
+	printk(", addr=%pI4", &ic_myaddr);
+	printk(", mask=%pI4", &ic_netmask);
+	printk(", gw=%pI4", &ic_gateway);
 	printk(",\n     host=%s, domain=%s, nis-domain=%s",
 	       utsname()->nodename, ic_domain, utsname()->domainname);
-	printk(",\n     bootserver=" NIPQUAD_FMT, NIPQUAD(ic_servaddr));
-	printk(", rootserver=" NIPQUAD_FMT, NIPQUAD(root_server_addr));
+	printk(",\n     bootserver=%pI4", &ic_servaddr);
+	printk(", rootserver=%pI4", &root_server_addr);
 	printk(", rootpath=%s", root_server_path);
 	printk("\n");
 #endif /* !SILENT */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e59b4dc..f47b9db 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1214,10 +1214,9 @@ restart:
 #if RT_CACHE_DEBUG >= 2
 	if (rt->u.dst.rt_next) {
 		struct rtable *trt;
-		printk(KERN_DEBUG "rt_cache @%02x: " NIPQUAD_FMT, hash,
-		       NIPQUAD(rt->rt_dst));
+		printk(KERN_DEBUG "rt_cache @%02x: %pI4", hash, &rt->rt_dst);
 		for (trt = rt->u.dst.rt_next; trt; trt = trt->u.dst.rt_next)
-			printk(" . " NIPQUAD_FMT, NIPQUAD(trt->rt_dst));
+			printk(" . %pI4", &trt->rt_dst);
 		printk("\n");
 	}
 #endif
@@ -1444,11 +1443,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 reject_redirect:
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		printk(KERN_INFO "Redirect from " NIPQUAD_FMT " on %s about "
-			NIPQUAD_FMT " ignored.\n"
-			"  Advised path = " NIPQUAD_FMT " -> " NIPQUAD_FMT "\n",
-		       NIPQUAD(old_gw), dev->name, NIPQUAD(new_gw),
-		       NIPQUAD(saddr), NIPQUAD(daddr));
+		printk(KERN_INFO "Redirect from %pI4 on %s about %pI4 ignored.\n"
+			"  Advised path = %pI4 -> %pI4\n",
+		       &old_gw, dev->name, &new_gw,
+		       &saddr, &daddr);
 #endif
 	in_dev_put(in_dev);
 }
@@ -1468,9 +1466,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 						rt->fl.oif,
 						rt_genid(dev_net(dst->dev)));
 #if RT_CACHE_DEBUG >= 1
-			printk(KERN_DEBUG "ipv4_negative_advice: redirect to "
-					  NIPQUAD_FMT "/%02x dropped\n",
-				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
+			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
+				&rt->rt_dst, rt->fl.fl4_tos);
 #endif
 			rt_del(hash, rt);
 			ret = NULL;
@@ -1534,10 +1531,9 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		if (IN_DEV_LOG_MARTIANS(in_dev) &&
 		    rt->u.dst.rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
-			printk(KERN_WARNING "host " NIPQUAD_FMT "/if%d ignores "
-				"redirects for " NIPQUAD_FMT " to " NIPQUAD_FMT ".\n",
-				NIPQUAD(rt->rt_src), rt->rt_iif,
-				NIPQUAD(rt->rt_dst), NIPQUAD(rt->rt_gateway));
+			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
+				&rt->rt_src, rt->rt_iif,
+				&rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
 out:
@@ -1730,8 +1726,8 @@ static void ipv4_link_failure(struct sk_buff *skb)
 
 static int ip_rt_bug(struct sk_buff *skb)
 {
-	printk(KERN_DEBUG "ip_rt_bug: " NIPQUAD_FMT " -> " NIPQUAD_FMT ", %s\n",
-		NIPQUAD(ip_hdr(skb)->saddr), NIPQUAD(ip_hdr(skb)->daddr),
+	printk(KERN_DEBUG "ip_rt_bug: %pI4 -> %pI4, %s\n",
+		&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
 		skb->dev ? skb->dev->name : "?");
 	kfree_skb(skb);
 	return 0;
@@ -1908,9 +1904,8 @@ static void ip_handle_martian_source(struct net_device *dev,
 		 *	RFC1812 recommendation, if source is martian,
 		 *	the only hint is MAC header.
 		 */
-		printk(KERN_WARNING "martian source " NIPQUAD_FMT " from "
-			NIPQUAD_FMT", on dev %s\n",
-			NIPQUAD(daddr), NIPQUAD(saddr), dev->name);
+		printk(KERN_WARNING "martian source %pI4 from %pI4, on dev %s\n",
+			&daddr, &saddr, dev->name);
 		if (dev->hard_header_len && skb_mac_header_was_set(skb)) {
 			int i;
 			const unsigned char *p = skb_mac_header(skb);
@@ -2219,9 +2214,8 @@ martian_destination:
 	RT_CACHE_STAT_INC(in_martian_dst);
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 	if (IN_DEV_LOG_MARTIANS(in_dev) && net_ratelimit())
-		printk(KERN_WARNING "martian destination " NIPQUAD_FMT " from "
-			NIPQUAD_FMT ", dev %s\n",
-			NIPQUAD(daddr), NIPQUAD(saddr), dev->name);
+		printk(KERN_WARNING "martian destination %pI4 from %pI4, dev %s\n",
+			&daddr, &saddr, dev->name);
 #endif
 
 e_hostunreach:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 04909e4..097294b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2336,9 +2336,9 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 	struct inet_sock *inet = inet_sk(sk);
 
 	if (sk->sk_family == AF_INET) {
-		printk(KERN_DEBUG "Undo %s " NIPQUAD_FMT "/%u c%u l%u ss%u/%u p%u\n",
+		printk(KERN_DEBUG "Undo %s %pI4/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
-		       NIPQUAD(inet->daddr), ntohs(inet->dport),
+		       &inet->daddr, ntohs(inet->dport),
 		       tp->snd_cwnd, tcp_left_out(tp),
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5c8fa7f..ef33246 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1139,10 +1139,9 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash failed for "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)%s\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest),
+			printk(KERN_INFO "MD5 Hash failed for (%pI4, %d)->(%pI4, %d)%s\n",
+			       &iph->saddr, ntohs(th->source),
+			       &iph->daddr, ntohs(th->dest),
 			       genhash ? " tcp_v4_calc_md5_hash failed" : "");
 		}
 		return 1;
@@ -1297,10 +1296,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			 * to destinations, already remembered
 			 * to the moment of synflood.
 			 */
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open "
-				       "request from " NIPQUAD_FMT "/%u\n",
-				       NIPQUAD(saddr),
-				       ntohs(tcp_hdr(skb)->source));
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open request from %pI4/%u\n",
+				       &saddr, ntohs(tcp_hdr(skb)->source));
 			goto drop_and_release;
 		}
 
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 7ddc30f..25524d4 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -153,12 +153,11 @@ static int tcpprobe_sprint(char *tbuf, int n)
 		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
 
 	return snprintf(tbuf, n,
-			"%lu.%09lu " NIPQUAD_FMT ":%u " NIPQUAD_FMT ":%u"
-			" %d %#x %#x %u %u %u %u\n",
+			"%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u\n",
 			(unsigned long) tv.tv_sec,
 			(unsigned long) tv.tv_nsec,
-			NIPQUAD(p->saddr), ntohs(p->sport),
-			NIPQUAD(p->daddr), ntohs(p->dport),
+			&p->saddr, ntohs(p->sport),
+			&p->daddr, ntohs(p->dport),
 			p->length, p->snd_nxt, p->snd_una,
 			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt);
 }
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 979c9d6..9843f6c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -299,8 +299,8 @@ static void tcp_retransmit_timer(struct sock *sk)
 #ifdef TCP_DEBUG
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
-			       NIPQUAD(inet->daddr), ntohs(inet->dport),
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %pI4:%u/%u shrinks window %u:%u. Repaired.\n",
+			       &inet->daddr, ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f760b86..bcb5def 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1263,13 +1263,13 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From " NIPQUAD_FMT ":%u %d/%d to " NIPQUAD_FMT ":%u\n",
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %pI4:%u %d/%d to %pI4:%u\n",
 		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
-		       NIPQUAD(saddr),
+		       &saddr,
 		       ntohs(uh->source),
 		       ulen,
 		       skb->len,
-		       NIPQUAD(daddr),
+		       &daddr,
 		       ntohs(uh->dest));
 	goto drop;
 
@@ -1278,11 +1278,11 @@ csum_error:
 	 * RFC1122: OK.  Discards the bad packet silently (as far as
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
 	 */
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From " NIPQUAD_FMT ":%u to " NIPQUAD_FMT ":%u ulen %d\n",
+	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %pI4:%u to %pI4:%u ulen %d\n",
 		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
-		       NIPQUAD(saddr),
+		       &saddr,
 		       ntohs(uh->source),
-		       NIPQUAD(daddr),
+		       &daddr,
 		       ntohs(uh->dest),
 		       ulen);
 drop:
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 02885e8..7c668c6 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -424,9 +424,8 @@ ip6t_log_packet(u_int8_t pf,
 			if (skb->dev->type == ARPHRD_SIT) {
 				const struct iphdr *iph =
 					(struct iphdr *)skb_mac_header(skb);
-				printk("TUNNEL=%u.%u.%u.%u->%u.%u.%u.%u ",
-				       NIPQUAD(iph->saddr),
-				       NIPQUAD(iph->daddr));
+				printk("TUNNEL=%pI4->%pI4 ",
+				       &iph->saddr, &iph->daddr);
 			}
 		} else
 			printk(" ");
-- 
1.6.0.3.756.gb776d


