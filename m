From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 5/6v2] net: replace uses of NIP6_FMT with %p6
Date: Tue, 28 Oct 2008 13:05:25 -0700
Message-ID: <1225224325.11483.52.camel@brick>
References: <1225223645.11483.43.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.179]:27385 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbYJ1UFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:05:30 -0400
Received: by el-out-1112.google.com with SMTP id z25so885043ele.1
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 13:05:29 -0700 (PDT)
In-Reply-To: <1225223645.11483.43.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Sorry, left two fixes in my working tree, not in the commit,
this is a fixed patch.

 include/linux/sunrpc/svc_xprt.h                |    4 +-
 include/net/ip_vs.h                            |    4 +-
 include/net/netfilter/nf_conntrack_tuple.h     |    6 ++--
 include/net/sctp/sctp.h                        |    4 +-
 net/ipv4/tcp_input.c                           |    4 +-
 net/ipv4/tcp_timer.c                           |    4 +-
 net/ipv6/addrlabel.c                           |   34 +++++++----------------
 net/ipv6/ah6.c                                 |    4 +-
 net/ipv6/esp6.c                                |    4 +-
 net/ipv6/exthdrs.c                             |    2 +-
 net/ipv6/icmp.c                                |    4 +-
 net/ipv6/ip6mr.c                               |    5 +--
 net/ipv6/ipcomp6.c                             |    4 +-
 net/ipv6/ndisc.c                               |    7 +---
 net/ipv6/netfilter/ip6t_LOG.c                  |    2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    5 +--
 net/ipv6/tcp_ipv6.c                            |    8 ++---
 17 files changed, 43 insertions(+), 62 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 6fd7b01..42e01c9 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -145,8 +145,8 @@ static inline char *__svc_print_addr(struct sockaddr *addr,
 		break;
 
 	case AF_INET6:
-		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
-			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
+		snprintf(buf, len, "%p6, port=%u",
+			 &((struct sockaddr_in6 *)addr)->sin6_addr,
 			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
 		break;
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fe9fcf7..6a66920 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -87,8 +87,8 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 	int len;
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		len = snprintf(&buf[*idx], buf_len - *idx, "[" NIP6_FMT "]",
-			       NIP6(addr->in6)) + 1;
+		len = snprintf(&buf[*idx], buf_len - *idx, "[%p6]",
+			       &addr->in6) + 1;
 	else
 #endif
 		len = snprintf(&buf[*idx], buf_len - *idx, NIPQUAD_FMT,
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index a6874ba..303efaf 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -122,10 +122,10 @@ static inline void nf_ct_dump_tuple_ip(const struct nf_conntrack_tuple *t)
 static inline void nf_ct_dump_tuple_ipv6(const struct nf_conntrack_tuple *t)
 {
 #ifdef DEBUG
-	printk("tuple %p: %u " NIP6_FMT " %hu -> " NIP6_FMT " %hu\n",
+	printk("tuple %p: %u %p6 %hu -> %p6 %hu\n",
 	       t, t->dst.protonum,
-	       NIP6(*(struct in6_addr *)t->src.u3.all), ntohs(t->src.u.all),
-	       NIP6(*(struct in6_addr *)t->dst.u3.all), ntohs(t->dst.u.all));
+	       t->src.u3.all, ntohs(t->src.u.all),
+	       t->dst.u3.all, ntohs(t->dst.u.all));
 #endif
 }
 
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ed71b11..85e9157 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -285,9 +285,9 @@ extern int sctp_debug_flag;
 	if (sctp_debug_flag) { \
 		if (saddr->sa.sa_family == AF_INET6) { \
 			printk(KERN_DEBUG \
-			       lead NIP6_FMT trail, \
+			       lead %p6 trail, \
 			       leadparm, \
-			       NIP6(saddr->v6.sin6_addr), \
+			       &saddr->v6.sin6_addr, \
 			       otherparms); \
 		} else { \
 			printk(KERN_DEBUG \
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d77c0d2..191c06b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2346,9 +2346,9 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	else if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
-		printk(KERN_DEBUG "Undo %s " NIP6_FMT "/%u c%u l%u ss%u/%u p%u\n",
+		printk(KERN_DEBUG "Undo %s %p6/%u c%u l%u ss%u/%u p%u\n",
 		       msg,
-		       NIP6(np->daddr), ntohs(inet->dport),
+		       &np->daddr, ntohs(inet->dport),
 		       tp->snd_cwnd, tcp_left_out(tp),
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 6b6dff1..4e6ee52 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -306,8 +306,8 @@ static void tcp_retransmit_timer(struct sock *sk)
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIP6_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
-			       NIP6(np->daddr), ntohs(inet->dport),
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %p6:%u/%u shrinks window %u:%u. Repaired.\n",
+			       &np->daddr, ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 0890903..d280366 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -186,10 +186,8 @@ u32 ipv6_addr_label(struct net *net,
 	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
 	rcu_read_unlock();
 
-	ADDRLABEL(KERN_DEBUG "%s(addr=" NIP6_FMT ", type=%d, ifindex=%d) => %08x\n",
-			__func__,
-			NIP6(*addr), type, ifindex,
-			label);
+	ADDRLABEL(KERN_DEBUG "%s(addr=%p6, type=%d, ifindex=%d) => %08x\n",
+		  __func__, addr, type, ifindex, label);
 
 	return label;
 }
@@ -203,11 +201,8 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	struct ip6addrlbl_entry *newp;
 	int addrtype;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
-			__func__,
-			NIP6(*prefix), prefixlen,
-			ifindex,
-			(unsigned int)label);
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d, label=%u)\n",
+		  __func__, prefix, prefixlen, ifindex, (unsigned int)label);
 
 	addrtype = ipv6_addr_type(prefix) & (IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK);
 
@@ -294,12 +289,9 @@ static int ip6addrlbl_add(struct net *net,
 	struct ip6addrlbl_entry *newp;
 	int ret = 0;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
-			__func__,
-			NIP6(*prefix), prefixlen,
-			ifindex,
-			(unsigned int)label,
-			replace);
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
+		  __func__, prefix, prefixlen, ifindex, (unsigned int)label,
+		  replace);
 
 	newp = ip6addrlbl_alloc(net, prefix, prefixlen, ifindex, label);
 	if (IS_ERR(newp))
@@ -321,10 +313,8 @@ static int __ip6addrlbl_del(struct net *net,
 	struct hlist_node *pos, *n;
 	int ret = -ESRCH;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
-			__func__,
-			NIP6(*prefix), prefixlen,
-			ifindex);
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d)\n",
+		  __func__, prefix, prefixlen, ifindex);
 
 	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
 		if (p->prefixlen == prefixlen &&
@@ -347,10 +337,8 @@ static int ip6addrlbl_del(struct net *net,
 	struct in6_addr prefix_buf;
 	int ret;
 
-	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
-			__func__,
-			NIP6(*prefix), prefixlen,
-			ifindex);
+	ADDRLABEL(KERN_DEBUG "%s(prefix=%p6, prefixlen=%d, ifindex=%d)\n",
+		  __func__, prefix, prefixlen, ifindex);
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
 	spin_lock(&ip6addrlbl_table.lock);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 2ff0c82..9bc43f2 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -419,8 +419,8 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/" NIP6_FMT "\n",
-		 ntohl(ah->spi), NIP6(iph->daddr));
+	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/%p6\n",
+		 ntohl(ah->spi), &iph->daddr);
 
 	xfrm_state_put(x);
 }
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b181b08..ec4be18 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -367,8 +367,8 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/" NIP6_FMT "\n",
-			ntohl(esph->spi), NIP6(iph->daddr));
+	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%p6\n",
+			ntohl(esph->spi), &iph->daddr);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 6bfffec..a890514 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -219,7 +219,7 @@ static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
 
 	if (!(ipv6_addr_type(&hao->addr) & IPV6_ADDR_UNICAST)) {
 		LIMIT_NETDEBUG(
-			KERN_DEBUG "hao is not an unicast addr: " NIP6_FMT "\n", NIP6(hao->addr));
+			KERN_DEBUG "hao is not an unicast addr: %p6\n", &hao->addr);
 		goto discard;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9b7d19a..1b72446 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -680,8 +680,8 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		skb->csum = ~csum_unfold(csum_ipv6_magic(saddr, daddr, skb->len,
 					     IPPROTO_ICMPV6, 0));
 		if (__skb_checksum_complete(skb)) {
-			LIMIT_NETDEBUG(KERN_DEBUG "ICMPv6 checksum failed [" NIP6_FMT " > " NIP6_FMT "]\n",
-				       NIP6(*saddr), NIP6(*daddr));
+			LIMIT_NETDEBUG(KERN_DEBUG "ICMPv6 checksum failed [%p6 > %p6]\n",
+				       saddr, daddr);
 			goto discard_it;
 		}
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 182f8a1..798e6a2 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -297,9 +297,8 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 		const struct mfc6_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq,
-			   NIP6_FMT " " NIP6_FMT " %-3d %8ld %8ld %8ld",
-			   NIP6(mfc->mf6c_mcastgrp), NIP6(mfc->mf6c_origin),
+		seq_printf(seq, "%p6 %p6 %-3d %8ld %8ld %8ld",
+			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
 			   mfc->mf6c_parent,
 			   mfc->mfc_un.res.pkt,
 			   mfc->mfc_un.res.bytes,
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 4545e43..9566d8f 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -67,8 +67,8 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/" NIP6_FMT "\n",
-			spi, NIP6(iph->daddr));
+	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%p6\n",
+			spi, &iph->daddr);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1724383..191bb07 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -647,11 +647,8 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
-			ND_PRINTK1(KERN_DEBUG
-				   "%s(): trying to ucast probe in NUD_INVALID: "
-				   NIP6_FMT "\n",
-				   __func__,
-				   NIP6(*target));
+			ND_PRINTK1(KERN_DEBUG "%s(): trying to ucast probe in NUD_INVALID: %p6\n",
+				   __func__, target);
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index caa441d..a61ce30 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -61,7 +61,7 @@ static void dump_packet(const struct nf_loginfo *info,
 	}
 
 	/* Max length: 88 "SRC=0000.0000.0000.0000.0000.0000.0000.0000 DST=0000.0000.0000.0000.0000.0000.0000.0000 " */
-	printk("SRC=" NIP6_FMT " DST=" NIP6_FMT " ", NIP6(ih->saddr), NIP6(ih->daddr));
+	printk("SRC=%p6 DST=%p6 ", &ih->saddr, &ih->daddr);
 
 	/* Max length: 44 "LEN=65535 TC=255 HOPLIMIT=255 FLOWLBL=FFFFF " */
 	printk("LEN=%Zu TC=%u HOPLIMIT=%u FLOWLBL=%u ",
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index e91db16..b165a27 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -56,9 +56,8 @@ static bool ipv6_invert_tuple(struct nf_conntrack_tuple *tuple,
 static int ipv6_print_tuple(struct seq_file *s,
 			    const struct nf_conntrack_tuple *tuple)
 {
-	return seq_printf(s, "src=" NIP6_FMT " dst=" NIP6_FMT " ",
-			  NIP6(*((struct in6_addr *)tuple->src.u3.ip6)),
-			  NIP6(*((struct in6_addr *)tuple->dst.u3.ip6)));
+	return seq_printf(s, "src=%p6 dst=%p6 ",
+			  tuple->src.u3.ip6, tuple->dst.u3.ip6);
 }
 
 /*
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6b356b..483550c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -872,12 +872,10 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash %s for "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
+			printk(KERN_INFO "MD5 Hash %s for (%p6, %u)->(%p6, %u)\n",
 			       genhash ? "failed" : "mismatch",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
+			       &ip6h->saddr, ntohs(th->source),
+			       &ip6h->daddr, ntohs(th->dest));
 		}
 		return 1;
 	}
-- 
1.6.0.3.729.g6ea410



