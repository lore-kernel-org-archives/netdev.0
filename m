From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Remove __KERNEL__ cpp checks from include/net
Date: Sun, 24 Apr 2011 11:05:17 -0700 (PDT)
Message-ID: <20110424.110517.71112331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753214Ab1DXSFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 14:05:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2F82E24C088
	for <netdev@vger.kernel.org>; Sun, 24 Apr 2011 11:05:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These header files are never installed to user consumption, so any
__KERNEL__ cpp checks are superfluous.

Projects should also not copy these files into their userland utility
sources and try to use them there.  If they insist on doing so, the
onus is on them to sanitize the headers as needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/addrconf.h                     |    3 ---
 include/net/af_rxrpc.h                     |    3 ---
 include/net/af_unix.h                      |    2 --
 include/net/atmclip.h                      |    2 --
 include/net/bluetooth/hci.h                |    2 --
 include/net/dst.h                          |    3 ---
 include/net/if_inet6.h                     |    3 ---
 include/net/ip6_fib.h                      |    3 ---
 include/net/ip6_route.h                    |    3 ---
 include/net/ip_vs.h                        |    5 -----
 include/net/ipv6.h                         |    7 -------
 include/net/ipx.h                          |    2 --
 include/net/ndisc.h                        |    6 ------
 include/net/netevent.h                     |    2 --
 include/net/netfilter/nf_conntrack.h       |    2 --
 include/net/netfilter/nf_conntrack_tuple.h |    4 ----
 include/net/netfilter/nf_nat.h             |    4 ----
 include/net/rawv6.h                        |    4 ----
 include/net/route.h                        |    4 ----
 include/net/transp_v6.h                    |    4 ----
 include/net/wimax.h                        |    5 -----
 21 files changed, 0 insertions(+), 73 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 7c4d92c..582e4ae 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -42,8 +42,6 @@ struct prefix_info {
 };
 
 
-#ifdef __KERNEL__
-
 #include <linux/netdevice.h>
 #include <net/if_inet6.h>
 #include <net/ipv6.h>
@@ -285,4 +283,3 @@ extern void if6_proc_exit(void);
 #endif
 
 #endif
-#endif
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 00c2eaa..03e6e94 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -12,8 +12,6 @@
 #ifndef _NET_RXRPC_H
 #define _NET_RXRPC_H
 
-#ifdef __KERNEL__
-
 #include <linux/rxrpc.h>
 
 struct rxrpc_call;
@@ -53,5 +51,4 @@ extern struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *,
 						   unsigned long);
 extern int rxrpc_kernel_reject_call(struct socket *);
 
-#endif /* __KERNEL__ */
 #endif /* _NET_RXRPC_H */
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 18e5c3f..91ab5b0 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -41,7 +41,6 @@ struct unix_skb_parms {
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
 
-#ifdef __KERNEL__
 /* The AF_UNIX socket */
 struct unix_sock {
 	/* WARNING: sk has to be the first member */
@@ -72,4 +71,3 @@ static inline int unix_sysctl_register(struct net *net) { return 0; }
 static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 #endif
-#endif
diff --git a/include/net/atmclip.h b/include/net/atmclip.h
index 467c531..497ef64 100644
--- a/include/net/atmclip.h
+++ b/include/net/atmclip.h
@@ -54,8 +54,6 @@ struct clip_priv {
 };
 
 
-#ifdef __KERNEL__
 extern struct neigh_table *clip_tbl_hook;
-#endif
 
 #endif
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 6138e31..499b7b7 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -1067,7 +1067,6 @@ struct hci_sco_hdr {
 	__u8	dlen;
 } __packed;
 
-#ifdef __KERNEL__
 #include <linux/skbuff.h>
 static inline struct hci_event_hdr *hci_event_hdr(const struct sk_buff *skb)
 {
@@ -1083,7 +1082,6 @@ static inline struct hci_sco_hdr *hci_sco_hdr(const struct sk_buff *skb)
 {
 	return (struct hci_sco_hdr *) skb->data;
 }
-#endif
 
 /* Command opcode pack/unpack */
 #define hci_opcode_pack(ogf, ocf)	(__u16) ((ocf & 0x03ff)|(ogf << 10))
diff --git a/include/net/dst.h b/include/net/dst.h
index 75b95df..d7bb740 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -92,8 +92,6 @@ struct dst_entry {
 	};
 };
 
-#ifdef __KERNEL__
-
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
 extern const u32 dst_default_metrics[RTAX_MAX];
 
@@ -438,6 +436,5 @@ extern struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig
 				     const struct flowi *fl, struct sock *sk,
 				     int flags);
 #endif
-#endif
 
 #endif /* _NET_DST_H */
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 3d982f7..0c603fe 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -30,8 +30,6 @@
 #define IF_PREFIX_ONLINK	0x01
 #define IF_PREFIX_AUTOCONF	0x02
 
-#ifdef __KERNEL__
-
 enum {
 	INET6_IFADDR_STATE_DAD,
 	INET6_IFADDR_STATE_POSTDAD,
@@ -303,4 +301,3 @@ static inline int ipv6_ipgre_mc_map(const struct in6_addr *addr,
 }
 
 #endif
-#endif
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aca8ef4..477ef75 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -13,8 +13,6 @@
 #ifndef _IP6_FIB_H
 #define _IP6_FIB_H
 
-#ifdef __KERNEL__
-
 #include <linux/ipv6_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/spinlock.h>
@@ -240,4 +238,3 @@ static inline void              fib6_rules_cleanup(void)
 }
 #endif
 #endif
-#endif
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index d5c21d4..5e91b72 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -21,8 +21,6 @@ struct route_info {
 	__u8			prefix[0];	/* 0,8 or 16 */
 };
 
-#ifdef __KERNEL__
-
 #include <net/flow.h>
 #include <net/ip6_fib.h>
 #include <net/sock.h>
@@ -193,4 +191,3 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 }
 
 #endif
-#endif
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d516f00..e0b7f13 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -8,9 +8,6 @@
 
 #include <linux/ip_vs.h>                /* definitions shared with userland */
 
-/* old ipvsadm versions still include this file directly */
-#ifdef __KERNEL__
-
 #include <asm/types.h>                  /* for __uXX types */
 
 #include <linux/sysctl.h>               /* for ctl_path */
@@ -1415,6 +1412,4 @@ ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 		atomic_read(&dest->inactconns);
 }
 
-#endif /* __KERNEL__ */
-
 #endif	/* _NET_IP_VS_H */
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5da1926..e1c60b4 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -77,11 +77,9 @@
 /*
  *	Addr scopes
  */
-#ifdef __KERNEL__
 #define IPV6_ADDR_MC_SCOPE(a)	\
 	((a)->s6_addr[1] & 0x0f)	/* nonstandard */
 #define __IPV6_ADDR_SCOPE_INVALID	-1
-#endif
 #define IPV6_ADDR_SCOPE_NODELOCAL	0x01
 #define IPV6_ADDR_SCOPE_LINKLOCAL	0x02
 #define IPV6_ADDR_SCOPE_SITELOCAL	0x05
@@ -91,14 +89,12 @@
 /*
  *	Addr flags
  */
-#ifdef __KERNEL__
 #define IPV6_ADDR_MC_FLAG_TRANSIENT(a)	\
 	((a)->s6_addr[1] & 0x10)
 #define IPV6_ADDR_MC_FLAG_PREFIX(a)	\
 	((a)->s6_addr[1] & 0x20)
 #define IPV6_ADDR_MC_FLAG_RENDEZVOUS(a)	\
 	((a)->s6_addr[1] & 0x40)
-#endif
 
 /*
  *	fragmentation header
@@ -113,8 +109,6 @@ struct frag_hdr {
 
 #define	IP6_MF	0x0001
 
-#ifdef __KERNEL__
-
 #include <net/sock.h>
 
 /* sysctls */
@@ -667,5 +661,4 @@ extern int ipv6_static_sysctl_register(void);
 extern void ipv6_static_sysctl_unregister(void);
 #endif
 
-#endif /* __KERNEL__ */
 #endif /* _NET_IPV6_H */
diff --git a/include/net/ipx.h b/include/net/ipx.h
index 05d7e4a..c1fec6b 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -80,7 +80,6 @@ struct ipx_route {
 	atomic_t		refcnt;
 };
 
-#ifdef __KERNEL__
 struct ipx_cb {
 	u8	ipx_tctrl;
 	__be32	ipx_dest_net;
@@ -116,7 +115,6 @@ static inline struct ipx_sock *ipx_sk(struct sock *sk)
 }
 
 #define IPX_SKB_CB(__skb) ((struct ipx_cb *)&((__skb)->cb[0]))
-#endif
 
 #define IPX_MIN_EPHEMERAL_SOCKET	0x4000
 #define IPX_MAX_EPHEMERAL_SOCKET	0x7fff
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 6144685..62beeb9 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -42,8 +42,6 @@ enum {
 #define ND_REACHABLE_TIME		(30*HZ)
 #define ND_RETRANS_TIMER		HZ
 
-#ifdef __KERNEL__
-
 #include <linux/compiler.h>
 #include <linux/icmpv6.h>
 #include <linux/in6.h>
@@ -156,8 +154,4 @@ static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, const s
 	return ERR_PTR(-ENODEV);
 }
 
-
-#endif /* __KERNEL__ */
-
-
 #endif
diff --git a/include/net/netevent.h b/include/net/netevent.h
index 22b239c..086f8a5 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -10,7 +10,6 @@
  *
  * 	Changes:
  */
-#ifdef __KERNEL__
 
 struct dst_entry;
 
@@ -29,4 +28,3 @@ extern int unregister_netevent_notifier(struct notifier_block *nb);
 extern int call_netevent_notifiers(unsigned long val, void *v);
 
 #endif
-#endif
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index d0d1337..c7c42e7 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -14,7 +14,6 @@
 
 #include <linux/netfilter/nf_conntrack_common.h>
 
-#ifdef __KERNEL__
 #include <linux/bitops.h>
 #include <linux/compiler.h>
 #include <asm/atomic.h>
@@ -326,5 +325,4 @@ do {							\
 #define MODULE_ALIAS_NFCT_HELPER(helper) \
         MODULE_ALIAS("nfct-helper-" helper)
 
-#endif /* __KERNEL__ */
 #endif /* _NF_CONNTRACK_H */
diff --git a/include/net/netfilter/nf_conntrack_tuple.h b/include/net/netfilter/nf_conntrack_tuple.h
index 4ee44c8..7ca6bdd 100644
--- a/include/net/netfilter/nf_conntrack_tuple.h
+++ b/include/net/netfilter/nf_conntrack_tuple.h
@@ -104,8 +104,6 @@ struct nf_conntrack_tuple_mask {
 	} src;
 };
 
-#ifdef __KERNEL__
-
 static inline void nf_ct_dump_tuple_ip(const struct nf_conntrack_tuple *t)
 {
 #ifdef DEBUG
@@ -148,8 +146,6 @@ struct nf_conntrack_tuple_hash {
 	struct nf_conntrack_tuple tuple;
 };
 
-#endif /* __KERNEL__ */
-
 static inline bool __nf_ct_tuple_src_equal(const struct nf_conntrack_tuple *t1,
 					   const struct nf_conntrack_tuple *t2)
 { 
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index aff80b1..0346b00 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -48,7 +48,6 @@ struct nf_nat_multi_range_compat {
 	struct nf_nat_range range[1];
 };
 
-#ifdef __KERNEL__
 #include <linux/list.h>
 #include <linux/netfilter/nf_conntrack_pptp.h>
 #include <net/netfilter/nf_conntrack_extend.h>
@@ -93,7 +92,4 @@ static inline struct nf_conn_nat *nfct_nat(const struct nf_conn *ct)
 #endif
 }
 
-#else  /* !__KERNEL__: iptables wants this to compile. */
-#define nf_nat_multi_range nf_nat_multi_range_compat
-#endif /*__KERNEL__*/
 #endif
diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index f6b9b83..cf75772 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -1,8 +1,6 @@
 #ifndef _NET_RAWV6_H
 #define _NET_RAWV6_H
 
-#ifdef __KERNEL__
-
 #include <net/protocol.h>
 
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
@@ -20,5 +18,3 @@ int rawv6_mh_filter_unregister(int (*filter)(struct sock *sock,
 #endif
 
 #endif
-
-#endif
diff --git a/include/net/route.h b/include/net/route.h
index b3962e2..3684c3e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -35,10 +35,6 @@
 #include <linux/cache.h>
 #include <linux/security.h>
 
-#ifndef __KERNEL__
-#warning This file is not supposed to be used outside of kernel.
-#endif
-
 #define RTO_ONLINK	0x01
 
 #define RTO_CONN	0
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index a8122dc..5271a74 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -7,8 +7,6 @@
  *	IPv6 transport protocols
  */
 
-#ifdef __KERNEL__
-
 extern struct proto rawv6_prot;
 extern struct proto udpv6_prot;
 extern struct proto udplitev6_prot;
@@ -57,5 +55,3 @@ extern const struct inet_connection_sock_af_ops ipv4_specific;
 extern void inet6_destroy_sock(struct sock *sk);
 
 #endif
-
-#endif
diff --git a/include/net/wimax.h b/include/net/wimax.h
index c799ba7..7328d50 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -250,7 +250,6 @@
 
 #ifndef __NET__WIMAX_H__
 #define __NET__WIMAX_H__
-#ifdef __KERNEL__
 
 #include <linux/wimax.h>
 #include <net/genetlink.h>
@@ -518,8 +517,4 @@ extern ssize_t wimax_msg_len(struct sk_buff *);
 extern int wimax_rfkill(struct wimax_dev *, enum wimax_rf_state);
 extern int wimax_reset(struct wimax_dev *);
 
-#else
-/* You might be looking for linux/wimax.h */
-#error This file should not be included from user space.
-#endif /* #ifdef __KERNEL__ */
 #endif /* #ifndef __NET__WIMAX_H__ */
-- 
1.7.4.3

