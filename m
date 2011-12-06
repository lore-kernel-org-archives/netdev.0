From: Feng King <kinwin2008@gmail.com>
Subject: [PATCH] ipv4: cleanups to use IS_ENABLED(CONFIG_FOO)
Date: Tue,  6 Dec 2011 20:24:49 +0800
Message-ID: <1323174289-2289-1-git-send-email-kinwin2008@gmail.com>
Cc: netdev@vger.kernel.org, Feng Jin <ronyjin@tencent.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62547 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933349Ab1LFMZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 07:25:00 -0500
Received: by iakc1 with SMTP id c1so3644173iak.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 04:24:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng Jin <ronyjin@tencent.com>

use #if IS_ENABLED(CONFIG_FOO) defined in include/linux/kconfig.h
instead of #if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE).

Signed-off-by: Feng Jin <ronyjin@tencent.com>
---
 include/net/inet6_hashtables.h  |    2 +-
 include/net/inet_sock.h         |    6 +++---
 include/net/ip.h                |    6 +++---
 include/net/net_namespace.h     |    8 ++++----
 include/net/protocol.h          |    8 ++++----
 include/net/tcp.h               |    6 +++---
 include/net/udp.h               |    4 ++--
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inet_diag.c            |   16 ++++++++--------
 net/ipv4/ip_gre.c               |    8 ++++----
 net/ipv4/ip_output.c            |    5 ++---
 net/ipv4/ip_sockglue.c          |    6 +++---
 net/ipv4/route.c                |    2 +-
 net/ipv4/tcp_input.c            |    2 +-
 net/ipv4/tcp_minisocks.c        |    2 +-
 net/ipv4/tcp_timer.c            |    2 +-
 net/ipv4/tunnel4.c              |   10 +++++-----
 net/ipv4/xfrm4_tunnel.c         |    6 +++---
 18 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index e46674d..2554f87 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -15,7 +15,7 @@
 #define _INET6_HASHTABLES_H
 
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
 #include <linux/ipv6.h>
 #include <linux/types.h>
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index f941964..e3e4051 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -71,7 +71,7 @@ struct ip_options_data {
 
 struct inet_request_sock {
 	struct request_sock	req;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	u16			inet6_rsk_offset;
 #endif
 	__be16			loc_port;
@@ -139,7 +139,7 @@ struct rtable;
 struct inet_sock {
 	/* sk and pinet6 has to be the first two members of inet_sock */
 	struct sock		sk;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct ipv6_pinfo	*pinet6;
 #endif
 	/* Socket demultiplex comparisons on incoming packets. */
@@ -188,7 +188,7 @@ static inline void __inet_sk_copy_descendant(struct sock *sk_to,
 	memcpy(inet_sk(sk_to) + 1, inet_sk(sk_from) + 1,
 	       sk_from->sk_prot->obj_size - ancestor_size);
 }
-#if !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE))
+#if !(IS_ENABLED(CONFIG_IPV6))
 static inline void inet_sk_copy_descendant(struct sock *sk_to,
 					   const struct sock *sk_from)
 {
diff --git a/include/net/ip.h b/include/net/ip.h
index eca0ef7..8e40759 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -353,14 +353,14 @@ static inline void ip_ipgre_mc_map(__be32 naddr, const unsigned char *broadcast,
 		memcpy(buf, &naddr, sizeof(naddr));
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/ipv6.h>
 #endif
 
 static __inline__ void inet_reset_saddr(struct sock *sk)
 {
 	inet_sk(sk)->inet_rcv_saddr = inet_sk(sk)->inet_saddr = 0;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == PF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -379,7 +379,7 @@ static inline int sk_mc_loop(struct sock *sk)
 	switch (sk->sk_family) {
 	case AF_INET:
 		return inet_sk(sk)->mc_loop;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		return inet6_sk(sk)->mc_loop;
 #endif
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3bb6fa0..23318f6 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -17,7 +17,7 @@
 #include <net/netns/ipv6.h>
 #include <net/netns/dccp.h>
 #include <net/netns/x_tables.h>
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netns/conntrack.h>
 #endif
 #include <net/netns/xfrm.h>
@@ -77,15 +77,15 @@ struct net {
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netns_ipv6	ipv6;
 #endif
-#if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
+#if IS_ENABLED(CONFIG_IP_DCCP)
 	struct netns_dccp	dccp;
 #endif
 #ifdef CONFIG_NETFILTER
 	struct netns_xt		xt;
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	struct netns_ct		ct;
 #endif
 	struct sock		*nfnl;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 6f7eb80..e19e42e 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -25,7 +25,7 @@
 #define _PROTOCOL_H
 
 #include <linux/in6.h>
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/ipv6.h>
 #endif
 
@@ -46,7 +46,7 @@ struct net_protocol {
 				netns_ok:1;
 };
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 struct inet6_protocol {
 	int	(*handler)(struct sk_buff *skb);
 
@@ -91,7 +91,7 @@ struct inet_protosw {
 
 extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 #endif
 
@@ -100,7 +100,7 @@ extern int	inet_del_protocol(const struct net_protocol *prot, unsigned char num)
 extern void	inet_register_protosw(struct inet_protosw *p);
 extern void	inet_unregister_protosw(struct inet_protosw *p);
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 extern int	inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
 extern int	inet6_register_protosw(struct inet_protosw *p);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb18c4d..cc1cfa9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -628,7 +628,7 @@ extern u32 __tcp_select_window(struct sock *sk);
 struct tcp_skb_cb {
 	union {
 		struct inet_skb_parm	h4;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
 	} header;	/* For incoming frames		*/
@@ -1144,7 +1144,7 @@ struct tcp6_md5sig_key {
 /* - sock block */
 struct tcp_md5sig_info {
 	struct tcp4_md5sig_key	*keys4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct tcp6_md5sig_key	*keys6;
 	u32			entries6;
 	u32			alloced6;
@@ -1171,7 +1171,7 @@ struct tcp6_pseudohdr {
 
 union tcp_md5sum_block {
 	struct tcp4_pseudohdr ip4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct tcp6_pseudohdr ip6;
 #endif
 };
diff --git a/include/net/udp.h b/include/net/udp.h
index 3b285f4..de4e2a5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -41,7 +41,7 @@
 struct udp_skb_cb {
 	union {
 		struct inet_skb_parm	h4;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
@@ -217,7 +217,7 @@ extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *sadd
 	else	    SNMP_INC_STATS_USER((net)->mib.udp_stats_in6, field);      \
 } while(0)
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #define UDPX_INC_STATS_BH(sk, field) \
 	do { \
 		if ((sk)->sk_family == AF_INET) \
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c14d88a..2445070 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -418,7 +418,7 @@ static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
 	return jhash_2words((__force u32)raddr, (__force u32)rport, rnd) & (synq_hsize - 1);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #define AF_INET_FAMILY(fam) ((fam) == AF_INET)
 #else
 #define AF_INET_FAMILY(fam) 1
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ccee270..2de519a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -128,7 +128,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	if (ext & (1 << (INET_DIAG_TOS - 1)))
 		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -223,7 +223,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_wqueue	      = 0;
 	r->idiag_uid	      = 0;
 	r->idiag_inode	      = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (tw->tw_family == AF_INET6) {
 		const struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
@@ -276,7 +276,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 	}
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	else if (req->idiag_family == AF_INET6) {
 		sk = inet6_lookup(&init_net, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
@@ -505,7 +505,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 		struct inet_sock *inet = inet_sk(sk);
 
 		entry.family = sk->sk_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (entry.family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -543,7 +543,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 							  INET_DIAG_REQ_BYTECODE);
 
 		entry.family = tw->tw_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == AF_INET6) {
 			struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
@@ -605,7 +605,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_wqueue = 0;
 	r->idiag_uid = sock_i_uid(sk);
 	r->idiag_inode = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
 			       &inet6_rsk(req)->loc_addr);
@@ -671,13 +671,13 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 			if (bc) {
 				entry.saddr =
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 					(entry.family == AF_INET6) ?
 					inet6_rsk(req)->loc_addr.s6_addr32 :
 #endif
 					&ireq->loc_addr;
 				entry.daddr =
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 					(entry.family == AF_INET6) ?
 					inet6_rsk(req)->rmt_addr.s6_addr32 :
 #endif
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d55110e..35238bf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -46,7 +46,7 @@
 #include <net/rtnetlink.h>
 #include <net/gre.h>
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -729,7 +729,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			struct neighbour *neigh = dst_get_neighbour(skb_dst(skb));
 			const struct in6_addr *addr6;
@@ -799,7 +799,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
@@ -873,7 +873,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6))
 			iph->ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
 #endif
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0bc95f3..3eafa5e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -426,11 +426,10 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	to->nf_trace = from->nf_trace;
 #endif
-#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
+#if IS_ENABLED(CONFIG_IP_VS)
 	to->ipvs_property = from->ipvs_property;
 #endif
 	skb_copy_secmark(to, from);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 09ff51b..aa3c93a 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -37,7 +37,7 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 #include <net/compat.h>
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <net/transp_v6.h>
 #endif
 
@@ -515,7 +515,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 						sock_owned_by_user(sk));
 		if (inet->is_icsk) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			if (sk->sk_family == PF_INET ||
 			    (!((1 << sk->sk_state) &
 			       (TCPF_LISTEN | TCPF_CLOSE)) &&
@@ -526,7 +526,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 				if (opt)
 					icsk->icsk_ext_hdr_len += opt->opt.optlen;
 				icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			}
 #endif
 		}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ca5e237..affe442 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1025,7 +1025,7 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const vo
 	const __be32 *pkey = daddr;
 	struct neighbour *n;
 
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
+#if IS_ENABLED(CONFIG_ATM_CLIP)
 	if (dev->type == ARPHRD_ATM)
 		tbl = clip_tbl_hook;
 #endif
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..22ecabb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2663,7 +2663,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 		       tp->snd_ssthresh, tp->prior_ssthresh,
 		       tp->packets_out);
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	else if (sk->sk_family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 66363b6..fc26f83 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -336,7 +336,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		tcptw->tw_ts_recent	= tp->rx_opt.ts_recent;
 		tcptw->tw_ts_recent_stamp = tp->rx_opt.ts_recent_stamp;
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			struct inet6_timewait_sock *tw6;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 2e0f0af..aa39a69 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -340,7 +340,7 @@ void tcp_retransmit_timer(struct sock *sk)
 			       &inet->inet_daddr, ntohs(inet->inet_dport),
 			       inet->inet_num, tp->snd_una, tp->snd_nxt);
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index ac3b3ee..0177598 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -105,7 +105,7 @@ drop:
 	return 0;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int tunnel64_rcv(struct sk_buff *skb)
 {
 	struct xfrm_tunnel *handler;
@@ -134,7 +134,7 @@ static void tunnel4_err(struct sk_buff *skb, u32 info)
 			break;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static void tunnel64_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
@@ -152,7 +152,7 @@ static const struct net_protocol tunnel4_protocol = {
 	.netns_ok	=	1,
 };
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static const struct net_protocol tunnel64_protocol = {
 	.handler	=	tunnel64_rcv,
 	.err_handler	=	tunnel64_err,
@@ -167,7 +167,7 @@ static int __init tunnel4_init(void)
 		printk(KERN_ERR "tunnel4 init: can't add protocol\n");
 		return -EAGAIN;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
 		printk(KERN_ERR "tunnel64 init: can't add protocol\n");
 		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
@@ -179,7 +179,7 @@ static int __init tunnel4_init(void)
 
 static void __exit tunnel4_fini(void)
 {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
 		printk(KERN_ERR "tunnel64 close: can't remove protocol\n");
 #endif
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 8280645..9247d9d 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -64,7 +64,7 @@ static struct xfrm_tunnel xfrm_tunnel_handler __read_mostly = {
 	.priority	=	2,
 };
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static struct xfrm_tunnel xfrm64_tunnel_handler __read_mostly = {
 	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
@@ -84,7 +84,7 @@ static int __init ipip_init(void)
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (xfrm4_tunnel_register(&xfrm64_tunnel_handler, AF_INET6)) {
 		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
 		xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET);
@@ -97,7 +97,7 @@ static int __init ipip_init(void)
 
 static void __exit ipip_fini(void)
 {
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (xfrm4_tunnel_deregister(&xfrm64_tunnel_handler, AF_INET6))
 		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET6\n");
 #endif
-- 
1.7.7.3
