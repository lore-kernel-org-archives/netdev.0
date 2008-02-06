From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 01/14] replace __inline__ by inline in net/ipv4
Date: Wed, 06 Feb 2008 10:14:06 +0100
Message-ID: <20080206092051.715181913@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:39422 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760332AbYBFJ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:26:29 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169QRHF164894
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:26:27 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169QRxd2248870
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:27 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169QRG4004011
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:26:27 +0100
Content-Disposition: inline; filename=remove-__inline__-in-ipv4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/ipv4

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv4/devinet.c        |    2 +-
 net/ipv4/fib_semantics.c  |    2 +-
 net/ipv4/igmp.c           |    2 +-
 net/ipv4/ip_fragment.c    |    8 ++++----
 net/ipv4/ip_output.c      |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c |   15 ++++++++-------
 net/ipv4/raw.c            |    2 +-
 net/ipv4/route.c          |   10 +++++-----
 net/ipv4/tcp_minisocks.c  |    2 +-
 net/ipv4/tcp_output.c     |    5 +++--
 10 files changed, 26 insertions(+), 24 deletions(-)

Index: net-2.6/net/ipv4/devinet.c
===================================================================
--- net-2.6.orig/net/ipv4/devinet.c
+++ net-2.6/net/ipv4/devinet.c
@@ -574,7 +574,7 @@ static int inet_rtm_newaddr(struct sk_bu
  *	Determine a default network mask, based on the IP address.
  */
 
-static __inline__ int inet_abc_len(__be32 addr)
+static inline int inet_abc_len(__be32 addr)
 {
 	int rc = -1;	/* Something else, probably a multicast. */
 
Index: net-2.6/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_semantics.c
+++ net-2.6/net/ipv4/fib_semantics.c
@@ -173,7 +173,7 @@ void fib_release_info(struct fib_info *f
 	spin_unlock_bh(&fib_info_lock);
 }
 
-static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
+static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 {
 	const struct fib_nh *onh = ofi->fib_nh;
 
Index: net-2.6/net/ipv4/igmp.c
===================================================================
--- net-2.6.orig/net/ipv4/igmp.c
+++ net-2.6/net/ipv4/igmp.c
@@ -164,7 +164,7 @@ static void ip_ma_put(struct ip_mc_list 
  *	Timer management
  */
 
-static __inline__ void igmp_stop_timer(struct ip_mc_list *im)
+static inline void igmp_stop_timer(struct ip_mc_list *im)
 {
 	spin_lock_bh(&im->lock);
 	if (del_timer(&im->timer))
Index: net-2.6/net/ipv4/ip_fragment.c
===================================================================
--- net-2.6.orig/net/ipv4/ip_fragment.c
+++ net-2.6/net/ipv4/ip_fragment.c
@@ -123,8 +123,8 @@ static int ip4_frag_match(struct inet_fr
 }
 
 /* Memory Tracking Functions. */
-static __inline__ void frag_kfree_skb(struct netns_frags *nf,
-		struct sk_buff *skb, int *work)
+static inline void frag_kfree_skb(struct netns_frags *nf,
+				  struct sk_buff *skb, int *work)
 {
 	if (work)
 		*work -= skb->truesize;
@@ -146,7 +146,7 @@ static void ip4_frag_init(struct inet_fr
 		inet_getpeer(arg->iph->saddr, 1) : NULL;
 }
 
-static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
+static inline void ip4_frag_free(struct inet_frag_queue *q)
 {
 	struct ipq *qp;
 
@@ -158,7 +158,7 @@ static __inline__ void ip4_frag_free(str
 
 /* Destruction primitives. */
 
-static __inline__ void ipq_put(struct ipq *ipq)
+static inline void ipq_put(struct ipq *ipq)
 {
 	inet_frag_put(&ipq->q, &ip4_frags);
 }
Index: net-2.6/net/ipv4/ip_output.c
===================================================================
--- net-2.6.orig/net/ipv4/ip_output.c
+++ net-2.6/net/ipv4/ip_output.c
@@ -85,7 +85,7 @@
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 
 /* Generate a checksum for an outgoing IP datagram. */
-__inline__ void ip_send_check(struct iphdr *iph)
+inline void ip_send_check(struct iphdr *iph)
 {
 	iph->check = 0;
 	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
Index: net-2.6/net/ipv4/raw.c
===================================================================
--- net-2.6.orig/net/ipv4/raw.c
+++ net-2.6/net/ipv4/raw.c
@@ -139,7 +139,7 @@ found:
  *	0 - deliver
  *	1 - block
  */
-static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
+static inline int icmp_filter(struct sock *sk, struct sk_buff *skb)
 {
 	int type;
 
Index: net-2.6/net/ipv4/route.c
===================================================================
--- net-2.6.orig/net/ipv4/route.c
+++ net-2.6/net/ipv4/route.c
@@ -572,18 +572,18 @@ static inline int ip_rt_proc_init(struct
 }
 #endif /* CONFIG_PROC_FS */
 
-static __inline__ void rt_free(struct rtable *rt)
+static inline void rt_free(struct rtable *rt)
 {
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
 
-static __inline__ void rt_drop(struct rtable *rt)
+static inline void rt_drop(struct rtable *rt)
 {
 	ip_rt_put(rt);
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
 
-static __inline__ int rt_fast_clean(struct rtable *rth)
+static inline int rt_fast_clean(struct rtable *rth)
 {
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
@@ -591,7 +591,7 @@ static __inline__ int rt_fast_clean(stru
 		rth->fl.iif && rth->u.dst.rt_next;
 }
 
-static __inline__ int rt_valuable(struct rtable *rth)
+static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
 		rth->u.dst.expires;
@@ -1389,7 +1389,7 @@ out:	kfree_skb(skb);
 static const unsigned short mtu_plateau[] =
 {32000, 17914, 8166, 4352, 2002, 1492, 576, 296, 216, 128 };
 
-static __inline__ unsigned short guess_mtu(unsigned short old_mtu)
+static inline unsigned short guess_mtu(unsigned short old_mtu)
 {
 	int i;
 
Index: net-2.6/net/ipv4/tcp_minisocks.c
===================================================================
--- net-2.6.orig/net/ipv4/tcp_minisocks.c
+++ net-2.6/net/ipv4/tcp_minisocks.c
@@ -55,7 +55,7 @@ struct inet_timewait_death_row tcp_death
 
 EXPORT_SYMBOL_GPL(tcp_death_row);
 
-static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
+static inline int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
 		return 1;
Index: net-2.6/net/ipv4/tcp_output.c
===================================================================
--- net-2.6.orig/net/ipv4/tcp_output.c
+++ net-2.6/net/ipv4/tcp_output.c
@@ -1,3 +1,4 @@
+
 /*
  * INET		An implementation of the TCP/IP protocol suite for the LINUX
  *		operating system.  INET is implemented using the  BSD Socket
@@ -296,8 +297,8 @@ static inline void TCP_ECN_send_syn(stru
 	}
 }
 
-static __inline__ void
-TCP_ECN_make_synack(struct request_sock *req, struct tcphdr *th)
+static inline void TCP_ECN_make_synack(struct request_sock *req,
+				       struct tcphdr *th)
 {
 	if (inet_rsk(req)->ecn_ok)
 		th->ece = 1;
Index: net-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
+++ net-2.6/net/ipv4/ipvs/ip_vs_ctl.c
@@ -282,8 +282,8 @@ static atomic_t ip_vs_nullsvc_counter = 
 /*
  *	Returns hash value for virtual service
  */
-static __inline__ unsigned
-ip_vs_svc_hashkey(unsigned proto, __be32 addr, __be16 port)
+static inline unsigned ip_vs_svc_hashkey(unsigned proto, __be32 addr,
+					 __be16 port)
 {
 	register unsigned porth = ntohs(port);
 
@@ -294,7 +294,7 @@ ip_vs_svc_hashkey(unsigned proto, __be32
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
-static __inline__ unsigned ip_vs_svc_fwm_hashkey(__u32 fwmark)
+static inline unsigned ip_vs_svc_fwm_hashkey(__u32 fwmark)
 {
 	return fwmark & IP_VS_SVC_TAB_MASK;
 }
@@ -364,8 +364,9 @@ static int ip_vs_svc_unhash(struct ip_vs
 /*
  *	Get service by {proto,addr,port} in the service table.
  */
-static __inline__ struct ip_vs_service *
-__ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
+static inline struct ip_vs_service *__ip_vs_service_get(__u16 protocol,
+							__be32 vaddr,
+							__be16 vport)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
@@ -390,7 +391,7 @@ __ip_vs_service_get(__u16 protocol, __be
 /*
  *	Get service by {fwmark} in the service table.
  */
-static __inline__ struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
+static inline struct ip_vs_service *__ip_vs_svc_fwm_get(__u32 fwmark)
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
@@ -480,7 +481,7 @@ __ip_vs_unbind_svc(struct ip_vs_dest *de
 /*
  *	Returns hash value for real service
  */
-static __inline__ unsigned ip_vs_rs_hashkey(__be32 addr, __be16 port)
+static inline unsigned ip_vs_rs_hashkey(__be32 addr, __be16 port)
 {
 	register unsigned porth = ntohs(port);
 

-- 
