From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 02/14] replace __inline__ by inline in net/ipv6
Date: Wed, 06 Feb 2008 10:14:07 +0100
Message-ID: <20080206092101.061356796@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:24984 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760446AbYBFJ1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:04 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169QZZo078040
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169QZPP4944074
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169QWe5022167
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:32 GMT
Content-Disposition: inline; filename=remove-__inline__-in-ipv6.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/ipv6

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/af_inet6.c                     |    2 +-
 net/ipv6/icmp.c                         |    6 +++---
 net/ipv6/ip6_fib.c                      |   12 ++++++------
 net/ipv6/ip6_flowlabel.c                |    2 +-
 net/ipv6/ip6_output.c                   |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    8 ++++----
 net/ipv6/raw.c                          |    2 +-
 net/ipv6/reassembly.c                   |   11 ++++++-----
 net/ipv6/route.c                        |   10 +++++-----
 net/ipv6/tcp_ipv6.c                     |    2 +-
 net/ipv6/udp.c                          |    8 ++++----
 11 files changed, 33 insertions(+), 32 deletions(-)

Index: net-2.6/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.orig/net/ipv6/af_inet6.c
+++ net-2.6/net/ipv6/af_inet6.c
@@ -72,7 +72,7 @@ MODULE_LICENSE("GPL");
 static struct list_head inetsw6[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw6_lock);
 
-static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
+static inline struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
 	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
 
Index: net-2.6/net/ipv6/icmp.c
===================================================================
--- net-2.6.orig/net/ipv6/icmp.c
+++ net-2.6/net/ipv6/icmp.c
@@ -90,7 +90,7 @@ static struct inet6_protocol icmpv6_prot
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
-static __inline__ int icmpv6_xmit_lock(void)
+static inline int icmpv6_xmit_lock(void)
 {
 	local_bh_disable();
 
@@ -105,7 +105,7 @@ static __inline__ int icmpv6_xmit_lock(v
 	return 0;
 }
 
-static __inline__ void icmpv6_xmit_unlock(void)
+static inline void icmpv6_xmit_unlock(void)
 {
 	spin_unlock_bh(&icmpv6_socket->sk->sk_lock.slock);
 }
@@ -203,7 +203,7 @@ static inline int icmpv6_xrlim_allow(str
  *	highest-order two bits set to 10
  */
 
-static __inline__ int opt_unrec(struct sk_buff *skb, __u32 offset)
+static inline int opt_unrec(struct sk_buff *skb, __u32 offset)
 {
 	u8 _optval, *op;
 
Index: net-2.6/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6_fib.c
+++ net-2.6/net/ipv6/ip6_fib.c
@@ -120,7 +120,7 @@ static inline void fib6_walker_unlink(st
 	w->prev = w->next = w;
 	write_unlock_bh(&fib6_walker_lock);
 }
-static __inline__ u32 fib6_new_sernum(void)
+static inline u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
 	if ((__s32)n <= 0)
@@ -139,14 +139,14 @@ static __inline__ u32 fib6_new_sernum(vo
  *	test bit
  */
 
-static __inline__ __be32 addr_bit_set(void *token, int fn_bit)
+static inline __be32 addr_bit_set(void *token, int fn_bit)
 {
 	__be32 *addr = token;
 
 	return htonl(1 << ((~fn_bit)&0x1F)) & addr[fn_bit>>5];
 }
 
-static __inline__ struct fib6_node * node_alloc(void)
+static inline struct fib6_node *node_alloc(void)
 {
 	struct fib6_node *fn;
 
@@ -155,12 +155,12 @@ static __inline__ struct fib6_node * nod
 	return fn;
 }
 
-static __inline__ void node_free(struct fib6_node * fn)
+static inline void node_free(struct fib6_node *fn)
 {
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static __inline__ void rt6_release(struct rt6_info *rt)
+static inline void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref))
 		dst_free(&rt->u.dst);
@@ -677,7 +677,7 @@ static int fib6_add_rt2node(struct fib6_
 	return 0;
 }
 
-static __inline__ void fib6_start_gc(struct rt6_info *rt)
+static inline void fib6_start_gc(struct rt6_info *rt)
 {
 	if (ip6_fib_timer.expires == 0 &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
Index: net-2.6/net/ipv6/ip6_flowlabel.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6_flowlabel.c
+++ net-2.6/net/ipv6/ip6_flowlabel.c
@@ -62,7 +62,7 @@ static DEFINE_RWLOCK(ip6_fl_lock);
 static DEFINE_RWLOCK(ip6_sk_fl_lock);
 
 
-static __inline__ struct ip6_flowlabel * __fl_lookup(__be32 label)
+static inline struct ip6_flowlabel *__fl_lookup(__be32 label)
 {
 	struct ip6_flowlabel *fl;
 
Index: net-2.6/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6_output.c
+++ net-2.6/net/ipv6/ip6_output.c
@@ -58,7 +58,7 @@
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
-static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
+static inline void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
 {
 	static u32 ipv6_fragmentation_id = 1;
 	static DEFINE_SPINLOCK(ip6_id_lock);
Index: net-2.6/net/ipv6/raw.c
===================================================================
--- net-2.6.orig/net/ipv6/raw.c
+++ net-2.6/net/ipv6/raw.c
@@ -116,7 +116,7 @@ found:
  *	0 - deliver
  *	1 - block
  */
-static __inline__ int icmpv6_filter(struct sock *sk, struct sk_buff *skb)
+static inline int icmpv6_filter(struct sock *sk, struct sk_buff *skb)
 {
 	struct icmp6hdr *icmph;
 	struct raw6_sock *rp = raw6_sk(sk);
Index: net-2.6/net/ipv6/reassembly.c
===================================================================
--- net-2.6.orig/net/ipv6/reassembly.c
+++ net-2.6/net/ipv6/reassembly.c
@@ -171,7 +171,7 @@ EXPORT_SYMBOL(ip6_frag_init);
 
 /* Destruction primitives. */
 
-static __inline__ void fq_put(struct frag_queue *fq)
+static inline void fq_put(struct frag_queue *fq)
 {
 	inet_frag_put(&fq->q, &ip6_frags);
 }
@@ -179,7 +179,7 @@ static __inline__ void fq_put(struct fra
 /* Kill fq entry. It is not destroyed immediately,
  * because caller (and someone more) holds reference count.
  */
-static __inline__ void fq_kill(struct frag_queue *fq)
+static inline void fq_kill(struct frag_queue *fq)
 {
 	inet_frag_kill(&fq->q, &ip6_frags);
 }
@@ -234,9 +234,10 @@ out:
 	fq_put(fq);
 }
 
-static __inline__ struct frag_queue *
-fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
-	struct inet6_dev *idev)
+static inline struct frag_queue *fq_find(struct net *net, __be32 id,
+					 struct in6_addr *src,
+					 struct in6_addr *dst,
+					 struct inet6_dev *idev)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
Index: net-2.6/net/ipv6/route.c
===================================================================
--- net-2.6.orig/net/ipv6/route.c
+++ net-2.6/net/ipv6/route.c
@@ -189,7 +189,7 @@ struct rt6_info ip6_blk_hole_entry = {
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static __inline__ struct rt6_info *ip6_dst_alloc(void)
+static inline struct rt6_info *ip6_dst_alloc(void)
 {
 	return (struct rt6_info *)dst_alloc(&ip6_dst_ops);
 }
@@ -223,7 +223,7 @@ static void ip6_dst_ifdown(struct dst_en
 	}
 }
 
-static __inline__ int rt6_check_expired(const struct rt6_info *rt)
+static inline int rt6_check_expired(const struct rt6_info *rt)
 {
 	return (rt->rt6i_flags & RTF_EXPIRES &&
 		time_after(jiffies, rt->rt6i_expires));
@@ -239,9 +239,9 @@ static inline int rt6_need_strict(struct
  *	Route lookup. Any table->tb6_lock is implied.
  */
 
-static __inline__ struct rt6_info *rt6_device_match(struct rt6_info *rt,
-						    int oif,
-						    int strict)
+static inline struct rt6_info *rt6_device_match(struct rt6_info *rt,
+						int oif,
+						int strict)
 {
 	struct rt6_info *local = NULL;
 	struct rt6_info *sprt;
Index: net-2.6/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6/net/ipv6/tcp_ipv6.c
@@ -99,7 +99,7 @@ static void tcp_v6_hash(struct sock *sk)
 	}
 }
 
-static __inline__ __sum16 tcp_v6_check(struct tcphdr *th, int len,
+static inline __sum16 tcp_v6_check(struct tcphdr *th, int len,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
 				   __wsum base)
Index: net-2.6/net/ipv6/udp.c
===================================================================
--- net-2.6.orig/net/ipv6/udp.c
+++ net-2.6/net/ipv6/udp.c
@@ -257,9 +257,9 @@ out:
 	sock_put(sk);
 }
 
-static __inline__ void udpv6_err(struct sk_buff *skb,
-				 struct inet6_skb_parm *opt, int type,
-				 int code, int offset, __be32 info     )
+static inline void udpv6_err(struct sk_buff *skb,
+			     struct inet6_skb_parm *opt, int type,
+			     int code, int offset, __be32 info)
 {
 	__udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
 }
@@ -519,7 +519,7 @@ discard:
 	return 0;
 }
 
-static __inline__ int udpv6_rcv(struct sk_buff *skb)
+static inline int udpv6_rcv(struct sk_buff *skb)
 {
 	return __udp6_lib_rcv(skb, udp_hash, IPPROTO_UDP);
 }
Index: net-2.6/net/ipv6/netfilter/nf_conntrack_reasm.c
===================================================================
--- net-2.6.orig/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ net-2.6/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -156,7 +156,7 @@ static inline void frag_kfree_skb(struct
 
 /* Destruction primitives. */
 
-static __inline__ void fq_put(struct nf_ct_frag6_queue *fq)
+static inline void fq_put(struct nf_ct_frag6_queue *fq)
 {
 	inet_frag_put(&fq->q, &nf_frags);
 }
@@ -164,7 +164,7 @@ static __inline__ void fq_put(struct nf_
 /* Kill fq entry. It is not destroyed immediately,
  * because caller (and someone more) holds reference count.
  */
-static __inline__ void fq_kill(struct nf_ct_frag6_queue *fq)
+static inline void fq_kill(struct nf_ct_frag6_queue *fq)
 {
 	inet_frag_kill(&fq->q, &nf_frags);
 }
@@ -195,8 +195,8 @@ out:
 
 /* Creation primitives. */
 
-static __inline__ struct nf_ct_frag6_queue *
-fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst)
+static inline struct nf_ct_frag6_queue *fq_find(__be32 id, struct in6_addr *src,
+						struct in6_addr *dst)
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;

-- 
