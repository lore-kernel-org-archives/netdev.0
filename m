From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use IS_ENABLED(CONFIG_IPV6)
Date: Sat, 10 Dec 2011 20:48:31 +0100
Message-ID: <1323546511.4016.32.camel@edumazet-laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43385 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab1LJTsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 14:48:37 -0500
Received: by eekc4 with SMTP id c4so911541eek.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 11:48:36 -0800 (PST)
In-Reply-To: <20111210.131555.2025649575447940902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/errqueue.h               |    4 +-
 include/linux/ipv6.h                   |    4 +-
 include/linux/lockd/lockd.h            |    6 ++--
 include/linux/sunrpc/clnt.h            |    6 ++--
 include/net/inet6_hashtables.h         |    4 +-
 include/net/inet_sock.h                |    6 ++--
 include/net/ip.h                       |    6 ++--
 include/net/net_namespace.h            |    2 -
 include/net/netfilter/nf_tproxy_core.h |    2 -
 include/net/netns/mib.h                |    2 -
 include/net/netns/xfrm.h               |    2 -
 include/net/protocol.h                 |    8 ++---
 include/net/sctp/sctp.h                |    4 +-
 include/net/sctp/structs.h             |    2 -
 include/net/tcp.h                      |    6 ++--
 include/net/udp.h                      |    4 +-
 net/bridge/br_multicast.c              |   32 +++++++++++------------
 net/bridge/br_private.h                |    2 -
 net/core/secure_seq.c                  |    4 +-
 net/dccp/dccp.h                        |    2 -
 net/dccp/minisocks.c                   |    2 -
 net/ipv4/inet_connection_sock.c        |    2 -
 net/ipv4/inet_diag.c                   |   16 +++++------
 net/ipv4/ip_gre.c                      |    8 ++---
 net/ipv4/ip_sockglue.c                 |    6 ++--
 net/ipv4/tcp_input.c                   |    2 -
 net/ipv4/tcp_minisocks.c               |    2 -
 net/ipv4/tcp_timer.c                   |    2 -
 net/ipv4/tunnel4.c                     |   10 +++----
 net/ipv4/xfrm4_tunnel.c                |    6 ++--
 net/key/af_key.c                       |   18 ++++++------
 net/netfilter/xt_TEE.c                 |    9 ++----
 net/netlabel/netlabel_addrlist.c       |    8 ++---
 net/netlabel/netlabel_addrlist.h       |    2 -
 net/netlabel/netlabel_domainhash.c     |   20 +++++++-------
 net/netlabel/netlabel_domainhash.h     |    2 -
 net/netlabel/netlabel_kapi.c           |   18 ++++++------
 net/netlabel/netlabel_mgmt.c           |    6 ++--
 net/netlabel/netlabel_unlabeled.c      |   26 +++++++++---------
 net/sctp/input.c                       |    2 -
 net/sctp/protocol.c                    |    2 -
 net/sctp/socket.c                      |    4 +-
 net/sunrpc/addr.c                      |    8 ++---
 net/sunrpc/svc.c                       |    8 ++---
 net/sunrpc/svc_xprt.c                  |    8 ++---
 net/sunrpc/svcauth_unix.c              |    2 -
 net/xfrm/xfrm_policy.c                 |    6 ++--
 net/xfrm/xfrm_user.c                   |   12 ++++----
 48 files changed, 161 insertions(+), 164 deletions(-)

diff --git a/include/linux/errqueue.h b/include/linux/errqueue.h
index c9f522b..fd0628b 100644
--- a/include/linux/errqueue.h
+++ b/include/linux/errqueue.h
@@ -25,7 +25,7 @@ struct sock_extended_err {
 #ifdef __KERNEL__
 
 #include <net/ip.h>
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/ipv6.h>
 #endif
 
@@ -34,7 +34,7 @@ struct sock_extended_err {
 struct sock_exterr_skb {
 	union {
 		struct inet_skb_parm	h4;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0c99776..6318268 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -404,7 +404,7 @@ struct tcp6_sock {
 
 extern int inet6_sk_rebuild_header(struct sock *sk);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
 	return inet_sk(__sk)->pinet6;
@@ -515,7 +515,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #define inet6_rcv_saddr(__sk)	NULL
 #define tcp_twsk_ipv6only(__sk)		0
 #define inet_v6_ipv6only(__sk)		0
-#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
 	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ff9abff..90b0656 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -301,7 +301,7 @@ static inline int __nlm_privileged_request4(const struct sockaddr *sap)
 	return ipv4_is_loopback(sin->sin_addr.s_addr);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline int __nlm_privileged_request6(const struct sockaddr *sap)
 {
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
@@ -314,12 +314,12 @@ static inline int __nlm_privileged_request6(const struct sockaddr *sap)
 
 	return ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LOOPBACK;
 }
-#else	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#else	/* IS_ENABLED(CONFIG_IPV6) */
 static inline int __nlm_privileged_request6(const struct sockaddr *sap)
 {
 	return 0;
 }
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif	/* IS_ENABLED(CONFIG_IPV6) */
 
 /*
  * Ensure incoming requests are from local privileged callers.
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index f15fd98..2c5993a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -215,7 +215,7 @@ static inline bool __rpc_copy_addr4(struct sockaddr *dst,
 	return true;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
 				   const struct sockaddr *sap2)
 {
@@ -240,7 +240,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
 	dsin6->sin6_addr = ssin6->sin6_addr;
 	return true;
 }
-#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+#else	/* !(IS_ENABLED(CONFIG_IPV6) */
 static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
 				   const struct sockaddr *sap2)
 {
@@ -252,7 +252,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
 {
 	return false;
 }
-#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+#endif	/* !(IS_ENABLED(CONFIG_IPV6) */
 
 /**
  * rpc_cmp_addr - compare the address portion of two sockaddrs.
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index e46674d..00cbb43 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -15,7 +15,7 @@
 #define _INET6_HASHTABLES_H
 
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
 #include <linux/ipv6.h>
 #include <linux/types.h>
@@ -110,5 +110,5 @@ extern struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo
 				 const struct in6_addr *saddr, const __be16 sport,
 				 const struct in6_addr *daddr, const __be16 dport,
 				 const int dif);
-#endif /* defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE) */
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 #endif /* _INET6_HASHTABLES_H */
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
index fd1561e..775009f 100644
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
index 3bb6fa0..ee547c1 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -77,7 +77,7 @@ struct net {
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netns_ipv6	ipv6;
 #endif
 #if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index e505358..75ca929 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -131,7 +131,7 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 	return sk;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline struct sock *
 nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
 		      const struct in6_addr *saddr, const struct in6_addr *daddr,
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 30f6728..d542a4b 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -12,7 +12,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 	DEFINE_SNMP_STAT_ATOMIC(struct icmpmsg_mib, icmpmsg_statistics);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct proc_dir_entry *proc_net_devsnmp6;
 	DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 748f91f..5299e69 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -56,7 +56,7 @@ struct netns_xfrm {
 #endif
 
 	struct dst_ops		xfrm4_dst_ops;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct dst_ops		xfrm6_dst_ops;
 #endif
 };
diff --git a/include/net/protocol.h b/include/net/protocol.h
index e182e13..875f489 100644
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
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 6a72a58..d368561 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -71,7 +71,7 @@
 #include <linux/jiffies.h>
 #include <linux/idr.h>
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #endif
@@ -383,7 +383,7 @@ static inline void sctp_sysctl_unregister(void) { return; }
 /* Size of Supported Address Parameter for 'x' address types. */
 #define SCTP_SAT_LEN(x) (sizeof(struct sctp_paramhdr) + (x) * sizeof(__u16))
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 
 void sctp_v6_pf_init(void);
 void sctp_v6_pf_exit(void);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3382615..ad0e31b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -365,7 +365,7 @@ static inline struct sock *sctp_opt2sk(const struct sctp_sock *sp)
        return (struct sock *)sp;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 struct sctp6_sock {
        struct sctp_sock  sctp;
        struct ipv6_pinfo inet6;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 87e3c80..02f070d 100644
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
@@ -1152,7 +1152,7 @@ struct tcp6_md5sig_key {
 /* - sock block */
 struct tcp_md5sig_info {
 	struct tcp4_md5sig_key	*keys4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct tcp6_md5sig_key	*keys6;
 	u32			entries6;
 	u32			alloced6;
@@ -1179,7 +1179,7 @@ struct tcp6_pseudohdr {
 
 union tcp_md5sum_block {
 	struct tcp4_pseudohdr ip4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct tcp6_pseudohdr ip6;
 #endif
 };
diff --git a/include/net/udp.h b/include/net/udp.h
index 1ffb39c..e39592f 100644
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
@@ -223,7 +223,7 @@ extern struct sock *__udp6_lib_lookup(struct net *net, const struct in6_addr *sa
 	else	    SNMP_INC_STATS_USER((net)->mib.udp_stats_in6, field);      \
 } while(0)
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #define UDPX_INC_STATS_BH(sk, field) \
 	do { \
 		if ((sk)->sk_family == AF_INET) \
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 375417e..568d5bf 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -24,7 +24,7 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <net/ip.h>
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/mld.h>
 #include <net/addrconf.h>
@@ -36,7 +36,7 @@
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
 {
 	if (ipv6_addr_is_multicast(addr) && IPV6_ADDR_MC_FLAG_TRANSIENT(addr))
@@ -52,7 +52,7 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
 		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
 #endif
@@ -65,7 +65,7 @@ static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
 				const struct in6_addr *ip)
 {
@@ -79,7 +79,7 @@ static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
 		return __br_ip4_hash(mdb, ip->u.ip4);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
 		return __br_ip6_hash(mdb, &ip->u.ip6);
 #endif
@@ -121,7 +121,7 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	return br_mdb_ip_get(mdb, &br_dst);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
 {
@@ -152,7 +152,7 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	case htons(ETH_P_IP):
 		ip.u.ip4 = ip_hdr(skb)->daddr;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
 		ip.u.ip6 = ipv6_hdr(skb)->daddr;
 		break;
@@ -411,7 +411,7 @@ out:
 	return skb;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 						    const struct in6_addr *group)
 {
@@ -496,7 +496,7 @@ static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
 		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
 		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
 #endif
@@ -773,7 +773,7 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	return br_multicast_add_group(br, port, &br_group);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_add_group(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      const struct in6_addr *group)
@@ -845,7 +845,7 @@ static void br_multicast_send_query(struct net_bridge *br,
 	br_group.proto = htons(ETH_P_IP);
 	__br_multicast_send_query(br, port, &br_group);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	br_group.proto = htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
 #endif
@@ -989,7 +989,7 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 					struct net_bridge_port *port,
 					struct sk_buff *skb)
@@ -1185,7 +1185,7 @@ out:
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct sk_buff *skb)
@@ -1334,7 +1334,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	br_multicast_leave_group(br, port, &br_group);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
 					 const struct in6_addr *group)
@@ -1449,7 +1449,7 @@ err_out:
 	return err;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
@@ -1596,7 +1596,7 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return br_multicast_ipv4_rcv(br, port, skb);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
 		return br_multicast_ipv6_rcv(br, port, skb);
 #endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8996908..57dcd14 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -56,7 +56,7 @@ struct br_ip
 {
 	union {
 		__be32	ip4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct in6_addr ip6;
 #endif
 	} u;
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 925991a..9fbca46 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -36,7 +36,7 @@ static u32 seq_scale(u32 seq)
 }
 #endif
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				   __be16 sport, __be16 dport)
 {
@@ -156,7 +156,7 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 }
 EXPORT_SYMBOL(secure_dccp_sequence_number);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 				  __be16 sport, __be16 dport)
 {
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 583490a..5818032 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -357,7 +357,7 @@ static inline int dccp_bad_service_code(const struct sock *sk,
 struct dccp_skb_cb {
 	union {
 		struct inet_skb_parm	h4;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index b50d5fd..5a7f90b 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -53,7 +53,7 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 	if (tw != NULL) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
 			struct inet6_timewait_sock *tw6;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a598768..2e4e244 100644
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
index 9b3e0b1..575e28c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -116,7 +116,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	if (ext & (1 << (INET_DIAG_TOS - 1)))
 		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -234,7 +234,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	r->idiag_wqueue	      = 0;
 	r->idiag_uid	      = 0;
 	r->idiag_inode	      = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (tw->tw_family == AF_INET6) {
 		const struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
@@ -286,7 +286,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 	}
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
 		sk = inet6_lookup(&init_net, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
@@ -473,7 +473,7 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 		return 1;
 
 	entry.family = sk->sk_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (entry.family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -571,7 +571,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 		struct inet_diag_entry entry;
 
 		entry.family = tw->tw_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (tw->tw_family == AF_INET6) {
 			struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
@@ -633,7 +633,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_wqueue = 0;
 	r->idiag_uid = sock_i_uid(sk);
 	r->idiag_inode = 0;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		*(struct in6_addr *)r->id.idiag_src = inet6_rsk(req)->loc_addr;
 		*(struct in6_addr *)r->id.idiag_dst = inet6_rsk(req)->rmt_addr;
@@ -695,13 +695,13 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
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
index fe070c1..2b53a1f 100644
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
 			struct neighbour *neigh = dst_get_neighbour_noref(skb_dst(skb));
 			const struct in6_addr *addr6;
@@ -799,7 +799,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
@@ -875,7 +875,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol == htons(ETH_P_IPV6))
 			iph->ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
 #endif
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 80d5fa4..8aa87c1 100644
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
 
@@ -508,7 +508,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 						sock_owned_by_user(sk));
 		if (inet->is_icsk) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			if (sk->sk_family == PF_INET ||
 			    (!((1 << sk->sk_state) &
 			       (TCPF_LISTEN | TCPF_CLOSE)) &&
@@ -519,7 +519,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 				if (opt)
 					icsk->icsk_ext_hdr_len += opt->opt.optlen;
 				icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			}
 #endif
 		}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0cbb440..b9cbc35 100644
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
index 9dc146e..550e755 100644
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
diff --git a/net/key/af_key.c b/net/key/af_key.c
index bfc0bef..11dbb22 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -375,7 +375,7 @@ static int verify_address_len(const void *p)
 	const struct sadb_address *sp = p;
 	const struct sockaddr *addr = (const struct sockaddr *)(sp + 1);
 	const struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	const struct sockaddr_in6 *sin6;
 #endif
 	int len;
@@ -387,7 +387,7 @@ static int verify_address_len(const void *p)
 		    sp->sadb_address_prefixlen > 32)
 			return -EINVAL;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		len = DIV_ROUND_UP(sizeof(*sp) + sizeof(*sin6), sizeof(uint64_t));
 		if (sp->sadb_address_len != len ||
@@ -469,7 +469,7 @@ static int present_and_same_family(const struct sadb_address *src,
 	if (s_addr->sa_family != d_addr->sa_family)
 		return 0;
 	if (s_addr->sa_family != AF_INET
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	    && s_addr->sa_family != AF_INET6
 #endif
 		)
@@ -579,7 +579,7 @@ static inline int pfkey_sockaddr_len(sa_family_t family)
 	switch (family) {
 	case AF_INET:
 		return sizeof(struct sockaddr_in);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		return sizeof(struct sockaddr_in6);
 #endif
@@ -595,7 +595,7 @@ int pfkey_sockaddr_extract(const struct sockaddr *sa, xfrm_address_t *xaddr)
 		xaddr->a4 =
 			((struct sockaddr_in *)sa)->sin_addr.s_addr;
 		return AF_INET;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		memcpy(xaddr->a6,
 		       &((struct sockaddr_in6 *)sa)->sin6_addr,
@@ -639,7 +639,7 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct net *net, const struct
 	case AF_INET:
 		xaddr = (xfrm_address_t *)&((const struct sockaddr_in *)(addr + 1))->sin_addr;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		xaddr = (xfrm_address_t *)&((const struct sockaddr_in6 *)(addr + 1))->sin6_addr;
 		break;
@@ -705,7 +705,7 @@ static unsigned int pfkey_sockaddr_fill(const xfrm_address_t *xaddr, __be16 port
 		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
 		return 32;
 	    }
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 	    {
 		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sa;
@@ -1311,7 +1311,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		xdaddr = (xfrm_address_t *)&((struct sockaddr_in *)(daddr + 1))->sin_addr.s_addr;
 		xsaddr = (xfrm_address_t *)&((struct sockaddr_in *)(saddr + 1))->sin_addr.s_addr;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		xdaddr = (xfrm_address_t *)&((struct sockaddr_in6 *)(daddr + 1))->sin6_addr;
 		xsaddr = (xfrm_address_t *)&((struct sockaddr_in6 *)(saddr + 1))->sin6_addr;
@@ -3146,7 +3146,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 			return NULL;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		if (opt != IPV6_IPSEC_POLICY) {
 			*dir = -EOPNOTSUPP;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 5f054a0..68349c3 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -29,9 +29,6 @@
 #	define WITH_CONNTRACK 1
 #	include <net/netfilter/nf_conntrack.h>
 #endif
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-#	define WITH_IPV6 1
-#endif
 
 struct xt_tee_priv {
 	struct notifier_block	notifier;
@@ -136,7 +133,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-#ifdef WITH_IPV6
+#if IS_ENABLED(CONFIG_IPV6)
 static bool
 tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 {
@@ -196,7 +193,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	}
 	return XT_CONTINUE;
 }
-#endif /* WITH_IPV6 */
+#endif
 
 static int tee_netdev_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
@@ -276,7 +273,7 @@ static struct xt_target tee_tg_reg[] __read_mostly = {
 		.destroy    = tee_tg_destroy,
 		.me         = THIS_MODULE,
 	},
-#ifdef WITH_IPV6
+#if IS_ENABLED(CONFIG_IPV6)
 	{
 		.name       = "TEE",
 		.revision   = 1,
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index 96b749d..6f17013 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -96,7 +96,7 @@ struct netlbl_af4list *netlbl_af4list_search_exact(__be32 addr,
 }
 
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_af6list_search - Search for a matching IPv6 address entry
  * @addr: IPv6 address
@@ -185,7 +185,7 @@ int netlbl_af4list_add(struct netlbl_af4list *entry, struct list_head *head)
 	return 0;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_af6list_add - Add a new IPv6 address entry to a list
  * @entry: address entry
@@ -263,7 +263,7 @@ struct netlbl_af4list *netlbl_af4list_remove(__be32 addr, __be32 mask,
 	return entry;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_af6list_remove_entry - Remove an IPv6 address entry
  * @entry: address entry
@@ -342,7 +342,7 @@ void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 	}
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_af6list_audit_addr - Audit an IPv6 address
  * @audit_buf: audit buffer
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index fdbc1d2..a1287ce 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -133,7 +133,7 @@ static inline void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 }
 #endif
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 
 #define __af6list_entry(ptr) container_of(ptr, struct netlbl_af6list, list)
 
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 3f905e5..3820411 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -78,7 +78,7 @@ static void netlbl_domhsh_free_entry(struct rcu_head *entry)
 	struct netlbl_dom_map *ptr;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 	struct netlbl_af6list *tmp6;
 #endif /* IPv6 */
@@ -90,7 +90,7 @@ static void netlbl_domhsh_free_entry(struct rcu_head *entry)
 			netlbl_af4list_remove_entry(iter4);
 			kfree(netlbl_domhsh_addr4_entry(iter4));
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_safe(iter6, tmp6,
 					    &ptr->type_def.addrsel->list6) {
 			netlbl_af6list_remove_entry(iter6);
@@ -217,7 +217,7 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 			cipsov4 = map4->type_def.cipsov4;
 			netlbl_af4list_audit_addr(audit_buf, 0, NULL,
 						  addr4->addr, addr4->mask);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		} else if (addr6 != NULL) {
 			struct netlbl_domaddr6_map *map6;
 			map6 = netlbl_domhsh_addr6_entry(addr6);
@@ -306,7 +306,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 	struct netlbl_dom_map *entry_old;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 	struct netlbl_af6list *tmp6;
 #endif /* IPv6 */
@@ -338,7 +338,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 					       &entry->type_def.addrsel->list4)
 				netlbl_domhsh_audit_add(entry, iter4, NULL,
 							ret_val, audit_info);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			netlbl_af6list_foreach_rcu(iter6,
 					       &entry->type_def.addrsel->list6)
 				netlbl_domhsh_audit_add(entry, NULL, iter6,
@@ -365,7 +365,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 				ret_val = -EEXIST;
 				goto add_return;
 			}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_rcu(iter6,
 					   &entry->type_def.addrsel->list6)
 			if (netlbl_af6list_search_exact(&iter6->addr,
@@ -386,7 +386,7 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
 			if (ret_val != 0)
 				goto add_return;
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_safe(iter6, tmp6,
 					    &entry->type_def.addrsel->list6) {
 			netlbl_af6list_remove_entry(iter6);
@@ -510,7 +510,7 @@ int netlbl_domhsh_remove_af4(const char *domain,
 	struct netlbl_dom_map *entry_map;
 	struct netlbl_af4list *entry_addr;
 	struct netlbl_af4list *iter4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 #endif /* IPv6 */
 	struct netlbl_domaddr4_map *entry;
@@ -533,7 +533,7 @@ int netlbl_domhsh_remove_af4(const char *domain,
 		goto remove_af4_failure;
 	netlbl_af4list_foreach_rcu(iter4, &entry_map->type_def.addrsel->list4)
 		goto remove_af4_single_addr;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	netlbl_af6list_foreach_rcu(iter6, &entry_map->type_def.addrsel->list6)
 		goto remove_af4_single_addr;
 #endif /* IPv6 */
@@ -644,7 +644,7 @@ struct netlbl_domaddr4_map *netlbl_domhsh_getentry_af4(const char *domain,
 	return netlbl_domhsh_addr4_entry(addr_iter);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_domhsh_getentry_af6 - Get an entry from the domain hash table
  * @domain: the domain name to search for
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index bfcc0f7..90872c4 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -104,7 +104,7 @@ int netlbl_domhsh_walk(u32 *skip_bkt,
 		     int (*callback) (struct netlbl_dom_map *entry, void *arg),
 		     void *cb_arg);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 struct netlbl_domaddr6_map *netlbl_domhsh_getentry_af6(const char *domain,
 						  const struct in6_addr *addr);
 #endif /* IPv6 */
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 5952237..2560e7b 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -147,7 +147,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 				goto cfg_unlbl_map_add_failure;
 			break;
 			}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		case AF_INET6: {
 			const struct in6_addr *addr6 = addr;
 			const struct in6_addr *mask6 = mask;
@@ -227,7 +227,7 @@ int netlbl_cfg_unlbl_static_add(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
@@ -270,7 +270,7 @@ int netlbl_cfg_unlbl_static_del(struct net *net,
 	case AF_INET:
 		addr_len = sizeof(struct in_addr);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		addr_len = sizeof(struct in6_addr);
 		break;
@@ -673,7 +673,7 @@ int netlbl_sock_setattr(struct sock *sk,
 			ret_val = -ENOENT;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		/* since we don't support any IPv6 labeling protocols right
 		 * now we can optimize everything away until we do */
@@ -724,7 +724,7 @@ int netlbl_sock_getattr(struct sock *sk,
 	case AF_INET:
 		ret_val = cipso_v4_sock_getattr(sk, secattr);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		ret_val = -ENOMSG;
 		break;
@@ -782,7 +782,7 @@ int netlbl_conn_setattr(struct sock *sk,
 			ret_val = -ENOENT;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		/* since we don't support any IPv6 labeling protocols right
 		 * now we can optimize everything away until we do */
@@ -853,7 +853,7 @@ int netlbl_req_setattr(struct request_sock *req,
 			ret_val = -ENOENT;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		/* since we don't support any IPv6 labeling protocols right
 		 * now we can optimize everything away until we do */
@@ -926,7 +926,7 @@ int netlbl_skbuff_setattr(struct sk_buff *skb,
 			ret_val = -ENOENT;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		/* since we don't support any IPv6 labeling protocols right
 		 * now we can optimize everything away until we do */
@@ -965,7 +965,7 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
 		    cipso_v4_skbuff_getattr(skb, secattr) == 0)
 			return 0;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		break;
 #endif /* IPv6 */
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 9879300..4809e2e 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -184,7 +184,7 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 
 		entry->type = NETLBL_NLTYPE_ADDRSELECT;
 		entry->type_def.addrsel = addrmap;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	} else if (info->attrs[NLBL_MGMT_A_IPV6ADDR]) {
 		struct in6_addr *addr;
 		struct in6_addr *mask;
@@ -270,7 +270,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 	struct nlattr *nla_a;
 	struct nlattr *nla_b;
 	struct netlbl_af4list *iter4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 #endif
 
@@ -324,7 +324,7 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 
 			nla_nest_end(skb, nla_b);
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		netlbl_af6list_foreach_rcu(iter6,
 					   &entry->type_def.addrsel->list6) {
 			struct netlbl_domaddr6_map *map6;
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 049ccd2..4b5fa0f 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -170,7 +170,7 @@ static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
 	struct netlbl_unlhsh_iface *iface;
 	struct netlbl_af4list *iter4;
 	struct netlbl_af4list *tmp4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 	struct netlbl_af6list *tmp6;
 #endif /* IPv6 */
@@ -184,7 +184,7 @@ static void netlbl_unlhsh_free_iface(struct rcu_head *entry)
 		netlbl_af4list_remove_entry(iter4);
 		kfree(netlbl_unlhsh_addr4_entry(iter4));
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	netlbl_af6list_foreach_safe(iter6, tmp6, &iface->addr6_list) {
 		netlbl_af6list_remove_entry(iter6);
 		kfree(netlbl_unlhsh_addr6_entry(iter6));
@@ -274,7 +274,7 @@ static int netlbl_unlhsh_add_addr4(struct netlbl_unlhsh_iface *iface,
 	return ret_val;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_unlhsh_add_addr6 - Add a new IPv6 address entry to the hash table
  * @iface: the associated interface entry
@@ -436,7 +436,7 @@ int netlbl_unlhsh_add(struct net *net,
 						  mask4->s_addr);
 		break;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case sizeof(struct in6_addr): {
 		const struct in6_addr *addr6 = addr;
 		const struct in6_addr *mask6 = mask;
@@ -531,7 +531,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 	return 0;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /**
  * netlbl_unlhsh_remove_addr6 - Remove an IPv6 address entry
  * @net: network namespace
@@ -606,14 +606,14 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 static void netlbl_unlhsh_condremove_iface(struct netlbl_unlhsh_iface *iface)
 {
 	struct netlbl_af4list *iter4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *iter6;
 #endif /* IPv6 */
 
 	spin_lock(&netlbl_unlhsh_lock);
 	netlbl_af4list_foreach_rcu(iter4, &iface->addr4_list)
 		goto unlhsh_condremove_failure;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	netlbl_af6list_foreach_rcu(iter6, &iface->addr6_list)
 		goto unlhsh_condremove_failure;
 #endif /* IPv6 */
@@ -680,7 +680,7 @@ int netlbl_unlhsh_remove(struct net *net,
 						     iface, addr, mask,
 						     audit_info);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case sizeof(struct in6_addr):
 		ret_val = netlbl_unlhsh_remove_addr6(net,
 						     iface, addr, mask,
@@ -1196,7 +1196,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	struct netlbl_unlhsh_iface *iface;
 	struct list_head *iter_list;
 	struct netlbl_af4list *addr4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct netlbl_af6list *addr6;
 #endif
 
@@ -1228,7 +1228,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 					goto unlabel_staticlist_return;
 				}
 			}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 			netlbl_af6list_foreach_rcu(addr6,
 						   &iface->addr6_list) {
 				if (iter_addr6++ < skip_addr6)
@@ -1277,7 +1277,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 	u32 skip_addr6 = cb->args[1];
 	u32 iter_addr4 = 0;
 	struct netlbl_af4list *addr4;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	u32 iter_addr6 = 0;
 	struct netlbl_af6list *addr6;
 #endif
@@ -1303,7 +1303,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 			goto unlabel_staticlistdef_return;
 		}
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	netlbl_af6list_foreach_rcu(addr6, &iface->addr6_list) {
 		if (iter_addr6++ < skip_addr6)
 			continue;
@@ -1494,7 +1494,7 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 		secattr->attr.secid = netlbl_unlhsh_addr4_entry(addr4)->secid;
 		break;
 	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case PF_INET6: {
 		struct ipv6hdr *hdr6;
 		struct netlbl_af6list *addr6;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index b7692aa..80f71af 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -105,7 +105,7 @@ static inline int sctp_rcv_checksum(struct sk_buff *skb)
 struct sctp_input_cb {
 	union {
 		struct inet_skb_parm	h4;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 61b9fca..544a9b6 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -637,7 +637,7 @@ void sctp_addr_wq_timeout_handler(unsigned long arg)
 		    " for cmd %d at entry %p\n", &sctp_addr_waitq, &addrw->a, addrw->state,
 		    addrw);
 
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		/* Now we send an ASCONF for each association */
 		/* Note. we currently don't handle link local IPv6 addressees */
 		if (addrw->a.sa.sa_family == AF_INET6) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d56c07a..db03083 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6841,7 +6841,7 @@ struct proto sctp_prot = {
 	.sockets_allocated = &sctp_sockets_allocated,
 };
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
@@ -6872,4 +6872,4 @@ struct proto sctpv6_prot = {
 	.memory_allocated = &sctp_memory_allocated,
 	.sockets_allocated = &sctp_sockets_allocated,
 };
-#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif /* IS_ENABLED(CONFIG_IPV6) */
diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 67a655e..ee77742 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -21,7 +21,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 
 static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
 				  char *buf, const int buflen)
@@ -91,7 +91,7 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 	return len;
 }
 
-#else	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
+#else	/* !IS_ENABLED(CONFIG_IPV6) */
 
 static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
 				  char *buf, const int buflen)
@@ -105,7 +105,7 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 	return 0;
 }
 
-#endif	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
+#endif	/* !IS_ENABLED(CONFIG_IPV6) */
 
 static int rpc_ntop4(const struct sockaddr *sap,
 		     char *buf, const size_t buflen)
@@ -155,7 +155,7 @@ static size_t rpc_pton4(const char *buf, const size_t buflen,
 	return sizeof(struct sockaddr_in);
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 static int rpc_parse_scope_id(const char *buf, const size_t buflen,
 			      const char *delim, struct sockaddr_in6 *sin6)
 {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6e03888..9d01d46 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -826,7 +826,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 	return error;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 /*
  * Register an "inet6" protocol family netid with the local
  * rpcbind daemon via an rpcbind v4 SET request.
@@ -872,7 +872,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 
 	return error;
 }
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif	/* IS_ENABLED(CONFIG_IPV6) */
 
 /*
  * Register a kernel RPC service via rpcbind version 4.
@@ -893,11 +893,11 @@ static int __svc_register(const char *progname,
 		error = __svc_rpcb_register4(program, version,
 						protocol, port);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case PF_INET6:
 		error = __svc_rpcb_register6(program, version,
 						protocol, port);
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif
 	}
 
 	if (error < 0)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 447cd0e..38649cf 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -179,13 +179,13 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
 		.sin_port		= htons(port),
 	};
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 		.sin6_port		= htons(port),
 	};
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif
 	struct sockaddr *sap;
 	size_t len;
 
@@ -194,12 +194,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		sap = (struct sockaddr *)&sin;
 		len = sizeof(sin);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case PF_INET6:
 		sap = (struct sockaddr *)&sin6;
 		len = sizeof(sin6);
 		break;
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
+#endif
 	default:
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index fe258fc..01153ea 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -220,7 +220,7 @@ static int ip_map_parse(struct cache_detail *cd,
 		ipv6_addr_set_v4mapped(address.s4.sin_addr.s_addr,
 				&sin6.sin6_addr);
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		memcpy(&sin6, &address.s6, sizeof(sin6));
 		break;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 82e803b..eb6b0b7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1340,7 +1340,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	case AF_INET:
 		dst_ops = &net->xfrm.xfrm4_dst_ops;
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		dst_ops = &net->xfrm.xfrm6_dst_ops;
 		break;
@@ -2435,7 +2435,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		case AF_INET:
 			xfrm_dst_ops = &net->xfrm.xfrm4_dst_ops;
 			break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		case AF_INET6:
 			xfrm_dst_ops = &net->xfrm.xfrm6_dst_ops;
 			break;
@@ -2485,7 +2485,7 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 	afinfo = xfrm_policy_afinfo[AF_INET];
 	if (afinfo)
 		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	afinfo = xfrm_policy_afinfo[AF_INET6];
 	if (afinfo)
 		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d0a42df..e0d747a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -28,7 +28,7 @@
 #include <net/netlink.h>
 #include <net/ah.h>
 #include <asm/uaccess.h>
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
 #endif
 
@@ -150,7 +150,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		break;
 
 	case AF_INET6:
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		break;
 #else
 		err = -EAFNOSUPPORT;
@@ -201,7 +201,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 			goto out;
 		break;
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case IPPROTO_DSTOPTS:
 	case IPPROTO_ROUTING:
 		if (attrs[XFRMA_ALG_COMP]	||
@@ -1160,7 +1160,7 @@ static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 		break;
 
 	case AF_INET6:
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		break;
 #else
 		return  -EAFNOSUPPORT;
@@ -1231,7 +1231,7 @@ static int validate_tmpl(int nr, struct xfrm_user_tmpl *ut, u16 family)
 		switch (ut[i].family) {
 		case AF_INET:
 			break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 		case AF_INET6:
 			break;
 #endif
@@ -2604,7 +2604,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 			return NULL;
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		if (opt != IPV6_XFRM_POLICY) {
 			*dir = -EOPNOTSUPP;
