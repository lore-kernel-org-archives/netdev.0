From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 13/14] replace __inline__ by inline in include/net
Date: Wed, 06 Feb 2008 10:14:18 +0100
Message-ID: <20080206092247.069874548@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:26005 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760782AbYBFJ3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:29:20 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m169SnkP380644
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:49 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169SnpK2330732
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:49 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169SeFe017736
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:41 GMT
Content-Disposition: inline; filename=remove-__inline__-in-include-net.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in include/net

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/addrconf.h     |    2 +-
 include/net/ax25.h         |    2 +-
 include/net/checksum.h     |    4 ++--
 include/net/dn_nsp.h       |   16 ++++++++--------
 include/net/ip.h           |    2 +-
 include/net/ip6_checksum.h |    8 ++++----
 include/net/ip_vs.h        |    2 +-
 include/net/ipx.h          |   16 ++++++++--------
 include/net/llc_c_ev.h     |    4 ++--
 include/net/llc_conn.h     |    4 ++--
 include/net/llc_s_ev.h     |    2 +-
 include/net/netrom.h       |    8 ++++----
 include/net/scm.h          |   14 ++++++++------
 include/net/sock.h         |   20 ++++++++++----------
 include/net/tcp.h          |    6 +++---
 include/net/udplite.h      |    4 ++--
 include/net/x25.h          |    8 ++++----
 include/net/xfrm.h         |   42 ++++++++++++++++++++----------------------
 18 files changed, 82 insertions(+), 82 deletions(-)

Index: net-2.6/include/net/addrconf.h
===================================================================
--- net-2.6.orig/include/net/addrconf.h
+++ net-2.6/include/net/addrconf.h
@@ -190,7 +190,7 @@ extern void			addrconf_forwarding_on(voi
  *	Hash function taken from net_alias.c
  */
 
-static __inline__ u8 ipv6_addr_hash(const struct in6_addr *addr)
+static inline u8 ipv6_addr_hash(const struct in6_addr *addr)
 {	
 	__u32 word;
 
Index: net-2.6/include/net/ax25.h
===================================================================
--- net-2.6.orig/include/net/ax25.h
+++ net-2.6/include/net/ax25.h
@@ -252,7 +252,7 @@ typedef struct ax25_cb {
 #define ax25_cb_hold(__ax25) \
 	atomic_inc(&((__ax25)->refcount))
 
-static __inline__ void ax25_cb_put(ax25_cb *ax25)
+static inline void ax25_cb_put(ax25_cb *ax25)
 {
 	if (atomic_dec_and_test(&ax25->refcount)) {
 		kfree(ax25->digipeat);
Index: net-2.6/include/net/checksum.h
===================================================================
--- net-2.6.orig/include/net/checksum.h
+++ net-2.6/include/net/checksum.h
@@ -41,8 +41,8 @@ __wsum csum_and_copy_from_user (const vo
 #endif
 
 #ifndef HAVE_CSUM_COPY_USER
-static __inline__ __wsum csum_and_copy_to_user
-(const void *src, void __user *dst, int len, __wsum sum, int *err_ptr)
+static inline __wsum csum_and_copy_to_user(const void *src, void __user *dst,
+					   int len, __wsum sum, int *err_ptr)
 {
 	sum = csum_partial(src, len, sum);
 
Index: net-2.6/include/net/dn_nsp.h
===================================================================
--- net-2.6.orig/include/net/dn_nsp.h
+++ net-2.6/include/net/dn_nsp.h
@@ -150,7 +150,7 @@ struct  srcobj_fmt
  * numbers used in NSP. Similar in operation to the functions
  * of the same name in TCP.
  */
-static __inline__ int dn_before(__u16 seq1, __u16 seq2)
+static inline int dn_before(__u16 seq1, __u16 seq2)
 {
         seq1 &= 0x0fff;
         seq2 &= 0x0fff;
@@ -159,7 +159,7 @@ static __inline__ int dn_before(__u16 se
 }
 
 
-static __inline__ int dn_after(__u16 seq1, __u16 seq2)
+static inline int dn_after(__u16 seq1, __u16 seq2)
 {
         seq1 &= 0x0fff;
         seq2 &= 0x0fff;
@@ -167,23 +167,23 @@ static __inline__ int dn_after(__u16 seq
         return (int)((seq2 - seq1) & 0x0fff) > 2048;
 }
 
-static __inline__ int dn_equal(__u16 seq1, __u16 seq2)
+static inline int dn_equal(__u16 seq1, __u16 seq2)
 {
         return ((seq1 ^ seq2) & 0x0fff) == 0;
 }
 
-static __inline__ int dn_before_or_equal(__u16 seq1, __u16 seq2)
+static inline int dn_before_or_equal(__u16 seq1, __u16 seq2)
 {
 	return (dn_before(seq1, seq2) || dn_equal(seq1, seq2));
 }
 
-static __inline__ void seq_add(__u16 *seq, __u16 off)
+static inline void seq_add(__u16 *seq, __u16 off)
 {
         (*seq) += off;
         (*seq) &= 0x0fff;
 }
 
-static __inline__ int seq_next(__u16 seq1, __u16 seq2)
+static inline int seq_next(__u16 seq1, __u16 seq2)
 {
 	return dn_equal(seq1 + 1, seq2);
 }
@@ -191,7 +191,7 @@ static __inline__ int seq_next(__u16 seq
 /*
  * Can we delay the ack ?
  */
-static __inline__ int sendack(__u16 seq)
+static inline int sendack(__u16 seq)
 {
         return (int)((seq & 0x1000) ? 0 : 1);
 }
@@ -199,7 +199,7 @@ static __inline__ int sendack(__u16 seq)
 /*
  * Is socket congested ?
  */
-static __inline__ int dn_congested(struct sock *sk)
+static inline int dn_congested(struct sock *sk)
 {
         return atomic_read(&sk->sk_rmem_alloc) > (sk->sk_rcvbuf >> 1);
 }
Index: net-2.6/include/net/ip.h
===================================================================
--- net-2.6.orig/include/net/ip.h
+++ net-2.6/include/net/ip.h
@@ -298,7 +298,7 @@ static inline void ip_ib_mc_map(__be32 n
 #include <linux/ipv6.h>
 #endif
 
-static __inline__ void inet_reset_saddr(struct sock *sk)
+static inline void inet_reset_saddr(struct sock *sk)
 {
 	inet_sk(sk)->rcv_saddr = inet_sk(sk)->saddr = 0;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
Index: net-2.6/include/net/ip6_checksum.h
===================================================================
--- net-2.6.orig/include/net/ip6_checksum.h
+++ net-2.6/include/net/ip6_checksum.h
@@ -34,10 +34,10 @@
 
 #ifndef _HAVE_ARCH_IPV6_CSUM
 
-static __inline__ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
-					  const struct in6_addr *daddr,
-					  __u32 len, unsigned short proto,
-					  __wsum csum)
+static inline __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
+				      const struct in6_addr *daddr,
+				      __u32 len, unsigned short proto,
+				      __wsum csum)
 {
 
 	int carry;
Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h
+++ net-2.6/include/net/ip_vs.h
@@ -925,7 +925,7 @@ extern void ip_vs_dst_reset(struct ip_vs
 extern int ip_vs_drop_rate;
 extern int ip_vs_drop_counter;
 
-static __inline__ int ip_vs_todrop(void)
+static inline int ip_vs_todrop(void)
 {
 	if (!ip_vs_drop_rate) return 0;
 	if (--ip_vs_drop_counter > 0) return 0;
Index: net-2.6/include/net/ipx.h
===================================================================
--- net-2.6.orig/include/net/ipx.h
+++ net-2.6/include/net/ipx.h
@@ -41,7 +41,7 @@ struct ipxhdr {
 	struct ipx_address	ipx_source __attribute__ ((packed));
 };
 
-static __inline__ struct ipxhdr *ipx_hdr(struct sk_buff *skb)
+static inline struct ipxhdr *ipx_hdr(struct sk_buff *skb)
 {
 	return (struct ipxhdr *)skb_transport_header(skb);
 }
@@ -135,27 +135,27 @@ extern void ipx_proc_exit(void);
 extern const char *ipx_frame_name(__be16);
 extern const char *ipx_device_name(struct ipx_interface *intrfc);
 
-static __inline__ void ipxitf_hold(struct ipx_interface *intrfc)
+static inline void ipxitf_hold(struct ipx_interface *intrfc)
 {
 	atomic_inc(&intrfc->refcnt);
 }
 
 extern void ipxitf_down(struct ipx_interface *intrfc);
 
-static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
+static inline void ipxitf_put(struct ipx_interface *intrfc)
 {
 	if (atomic_dec_and_test(&intrfc->refcnt))
 		ipxitf_down(intrfc);
 }
 
-static __inline__ void ipxrtr_hold(struct ipx_route *rt)
+static inline void ipxrtr_hold(struct ipx_route *rt)
 {
-	        atomic_inc(&rt->refcnt);
+	atomic_inc(&rt->refcnt);
 }
 
-static __inline__ void ipxrtr_put(struct ipx_route *rt)
+static inline void ipxrtr_put(struct ipx_route *rt)
 {
-	        if (atomic_dec_and_test(&rt->refcnt))
-			                kfree(rt);
+	if (atomic_dec_and_test(&rt->refcnt))
+		kfree(rt);
 }
 #endif /* _NET_INET_IPX_H_ */
Index: net-2.6/include/net/llc_c_ev.h
===================================================================
--- net-2.6.orig/include/net/llc_c_ev.h
+++ net-2.6/include/net/llc_c_ev.h
@@ -120,7 +120,7 @@ struct llc_conn_state_ev {
 	u8 cfm_prim;
 };
 
-static __inline__ struct llc_conn_state_ev *llc_conn_ev(struct sk_buff *skb)
+static inline struct llc_conn_state_ev *llc_conn_ev(struct sk_buff *skb)
 {
 	return (struct llc_conn_state_ev *)skb->cb;
 }
@@ -261,7 +261,7 @@ extern int llc_conn_ev_qlfy_set_status_c
 extern int llc_conn_ev_qlfy_set_status_rst_done(struct sock *sk,
 						struct sk_buff *skb);
 
-static __inline__ int llc_conn_space(struct sock *sk, struct sk_buff *skb)
+static inline int llc_conn_space(struct sock *sk, struct sk_buff *skb)
 {
 	return atomic_read(&sk->sk_rmem_alloc) + skb->truesize <
 	       (unsigned)sk->sk_rcvbuf;
Index: net-2.6/include/net/llc_conn.h
===================================================================
--- net-2.6.orig/include/net/llc_conn.h
+++ net-2.6/include/net/llc_conn.h
@@ -83,12 +83,12 @@ static inline struct llc_sock *llc_sk(co
 	return (struct llc_sock *)sk;
 }
 
-static __inline__ void llc_set_backlog_type(struct sk_buff *skb, char type)
+static inline void llc_set_backlog_type(struct sk_buff *skb, char type)
 {
 	skb->cb[sizeof(skb->cb) - 1] = type;
 }
 
-static __inline__ char llc_backlog_type(struct sk_buff *skb)
+static inline char llc_backlog_type(struct sk_buff *skb)
 {
 	return skb->cb[sizeof(skb->cb) - 1];
 }
Index: net-2.6/include/net/llc_s_ev.h
===================================================================
--- net-2.6.orig/include/net/llc_s_ev.h
+++ net-2.6/include/net/llc_s_ev.h
@@ -44,7 +44,7 @@ struct llc_sap_state_ev {
 	struct llc_addr daddr;
 };
 
-static __inline__ struct llc_sap_state_ev *llc_sap_ev(struct sk_buff *skb)
+static inline struct llc_sap_state_ev *llc_sap_ev(struct sk_buff *skb)
 {
 	return (struct llc_sap_state_ev *)skb->cb;
 }
Index: net-2.6/include/net/netrom.h
===================================================================
--- net-2.6.orig/include/net/netrom.h
+++ net-2.6/include/net/netrom.h
@@ -123,7 +123,7 @@ struct nr_node {
 #define nr_node_hold(__nr_node) \
 	atomic_inc(&((__nr_node)->refcount))
 
-static __inline__ void nr_node_put(struct nr_node *nr_node)
+static inline void nr_node_put(struct nr_node *nr_node)
 {
 	if (atomic_dec_and_test(&nr_node->refcount)) {
 		kfree(nr_node);
@@ -133,7 +133,7 @@ static __inline__ void nr_node_put(struc
 #define nr_neigh_hold(__nr_neigh) \
 	atomic_inc(&((__nr_neigh)->refcount))
 
-static __inline__ void nr_neigh_put(struct nr_neigh *nr_neigh)
+static inline void nr_neigh_put(struct nr_neigh *nr_neigh)
 {
 	if (atomic_dec_and_test(&nr_neigh->refcount)) {
 		kfree(nr_neigh->digipeat);
@@ -143,13 +143,13 @@ static __inline__ void nr_neigh_put(stru
 
 /* nr_node_lock and nr_node_unlock also hold/put the node's refcounter.
  */
-static __inline__ void nr_node_lock(struct nr_node *nr_node)
+static inline void nr_node_lock(struct nr_node *nr_node)
 {
 	nr_node_hold(nr_node);
 	spin_lock_bh(&nr_node->node_lock);
 }
 
-static __inline__ void nr_node_unlock(struct nr_node *nr_node)
+static inline void nr_node_unlock(struct nr_node *nr_node)
 {
 	spin_unlock_bh(&nr_node->node_lock);
 	nr_node_put(nr_node);
Index: net-2.6/include/net/scm.h
===================================================================
--- net-2.6.orig/include/net/scm.h
+++ net-2.6/include/net/scm.h
@@ -35,22 +35,24 @@ extern void __scm_destroy(struct scm_coo
 extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
 
 #ifdef CONFIG_SECURITY_NETWORK
-static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
+static inline void unix_get_peersec_dgram(struct socket *sock,
+					  struct scm_cookie *scm)
 {
 	security_socket_getpeersec_dgram(sock, NULL, &scm->secid);
 }
 #else
-static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
+static inline void unix_get_peersec_dgram(struct socket *sock,
+					  struct scm_cookie *scm)
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
-static __inline__ void scm_destroy(struct scm_cookie *scm)
+static inline void scm_destroy(struct scm_cookie *scm)
 {
 	if (scm && scm->fp)
 		__scm_destroy(scm);
 }
 
-static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
+static inline int scm_send(struct socket *sock, struct msghdr *msg,
 			       struct scm_cookie *scm)
 {
 	struct task_struct *p = current;
@@ -86,8 +88,8 @@ static inline void scm_passec(struct soc
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
 
-static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
-				struct scm_cookie *scm, int flags)
+static inline void scm_recv(struct socket *sock, struct msghdr *msg,
+			    struct scm_cookie *scm, int flags)
 {
 	if (!msg->msg_control)
 	{
Index: net-2.6/include/net/sock.h
===================================================================
--- net-2.6.orig/include/net/sock.h
+++ net-2.6/include/net/sock.h
@@ -302,17 +302,17 @@ static inline int sk_hashed(const struct
 	return !sk_unhashed(sk);
 }
 
-static __inline__ void sk_node_init(struct hlist_node *node)
+static inline void sk_node_init(struct hlist_node *node)
 {
 	node->pprev = NULL;
 }
 
-static __inline__ void __sk_del_node(struct sock *sk)
+static inline void __sk_del_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_node);
 }
 
-static __inline__ int __sk_del_node_init(struct sock *sk)
+static inline int __sk_del_node_init(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		__sk_del_node(sk);
@@ -341,7 +341,7 @@ static inline void __sock_put(struct soc
 	atomic_dec(&sk->sk_refcnt);
 }
 
-static __inline__ int sk_del_node_init(struct sock *sk)
+static inline int sk_del_node_init(struct sock *sk)
 {
 	int rc = __sk_del_node_init(sk);
 
@@ -353,23 +353,23 @@ static __inline__ int sk_del_node_init(s
 	return rc;
 }
 
-static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
+static inline void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_node, list);
 }
 
-static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
+static inline void sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	sock_hold(sk);
 	__sk_add_node(sk, list);
 }
 
-static __inline__ void __sk_del_bind_node(struct sock *sk)
+static inline void __sk_del_bind_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_bind_node);
 }
 
-static __inline__ void sk_add_bind_node(struct sock *sk,
+static inline void sk_add_bind_node(struct sock *sk,
 					struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_bind_node, list);
@@ -1295,8 +1295,8 @@ static inline int sock_intr_errno(long t
 extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb);
 
-static __inline__ void
-sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
+static inline void sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
+				       struct sk_buff *skb)
 {
 	ktime_t kt = skb->tstamp;
 
Index: net-2.6/include/net/tcp.h
===================================================================
--- net-2.6.orig/include/net/tcp.h
+++ net-2.6/include/net/tcp.h
@@ -338,8 +338,8 @@ static inline void tcp_clear_options(str
 #define	TCP_ECN_QUEUE_CWR	2
 #define	TCP_ECN_DEMAND_CWR	4
 
-static __inline__ void
-TCP_ECN_create_request(struct request_sock *req, struct tcphdr *th)
+static inline void TCP_ECN_create_request(struct request_sock *req,
+					  struct tcphdr *th)
 {
 	if (sysctl_tcp_ecn && th->ece && th->cwr)
 		inet_rsk(req)->ecn_ok = 1;
@@ -776,7 +776,7 @@ extern __u32 tcp_init_cwnd(struct tcp_so
 /* Slow start with delack produces 3 packets of burst, so that
  * it is safe "de facto".
  */
-static __inline__ __u32 tcp_max_burst(const struct tcp_sock *tp)
+static inline __u32 tcp_max_burst(const struct tcp_sock *tp)
 {
 	return 3;
 }
Index: net-2.6/include/net/udplite.h
===================================================================
--- net-2.6.orig/include/net/udplite.h
+++ net-2.6/include/net/udplite.h
@@ -16,8 +16,8 @@ extern struct hlist_head 	udplite_hash[U
 /*
  *	Checksum computation is all in software, hence simpler getfrag.
  */
-static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
-				      int len, int odd, struct sk_buff *skb)
+static inline int udplite_getfrag(void *from, char *to, int  offset,
+				  int len, int odd, struct sk_buff *skb)
 {
 	return memcpy_fromiovecend(to, (struct iovec *) from, offset, len);
 }
Index: net-2.6/include/net/x25.h
===================================================================
--- net-2.6.orig/include/net/x25.h
+++ net-2.6/include/net/x25.h
@@ -231,12 +231,12 @@ extern struct x25_neigh *x25_get_neigh(s
 extern void x25_link_free(void);
 
 /* x25_neigh.c */
-static __inline__ void x25_neigh_hold(struct x25_neigh *nb)
+static inline void x25_neigh_hold(struct x25_neigh *nb)
 {
 	atomic_inc(&nb->refcnt);
 }
 
-static __inline__ void x25_neigh_put(struct x25_neigh *nb)
+static inline void x25_neigh_put(struct x25_neigh *nb)
 {
 	if (atomic_dec_and_test(&nb->refcnt))
 		kfree(nb);
@@ -254,12 +254,12 @@ extern void x25_route_device_down(struct
 extern int  x25_route_ioctl(unsigned int, void __user *);
 extern void x25_route_free(void);
 
-static __inline__ void x25_route_hold(struct x25_route *rt)
+static inline void x25_route_hold(struct x25_route *rt)
 {
 	atomic_inc(&rt->refcnt);
 }
 
-static __inline__ void x25_route_put(struct x25_route *rt)
+static inline void x25_route_put(struct x25_route *rt)
 {
 	if (atomic_dec_and_test(&rt->refcnt))
 		kfree(rt);
Index: net-2.6/include/net/xfrm.h
===================================================================
--- net-2.6.orig/include/net/xfrm.h
+++ net-2.6/include/net/xfrm.h
@@ -667,7 +667,7 @@ static inline void xfrm_state_hold(struc
 	atomic_inc(&x->refcnt);
 }
 
-static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
+static inline int addr_match(void *token1, void *token2, int prefixlen)
 {
 	__be32 *a1 = token1;
 	__be32 *a2 = token2;
@@ -693,8 +693,7 @@ static __inline__ int addr_match(void *t
 	return 1;
 }
 
-static __inline__
-__be16 xfrm_flowi_sport(struct flowi *fl)
+static inline __be16 xfrm_flowi_sport(struct flowi *fl)
 {
 	__be16 port;
 	switch(fl->proto) {
@@ -717,8 +716,7 @@ __be16 xfrm_flowi_sport(struct flowi *fl
 	return port;
 }
 
-static __inline__
-__be16 xfrm_flowi_dport(struct flowi *fl)
+static inline __be16 xfrm_flowi_dport(struct flowi *fl)
 {
 	__be16 port;
 	switch(fl->proto) {
@@ -1016,8 +1014,8 @@ static inline int xfrm6_policy_check_rev
 }
 #endif
 
-static __inline__
-xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
+static inline xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl,
+					       unsigned short family)
 {
 	switch (family){
 	case AF_INET:
@@ -1028,8 +1026,8 @@ xfrm_address_t *xfrm_flowi_daddr(struct 
 	return NULL;
 }
 
-static __inline__
-xfrm_address_t *xfrm_flowi_saddr(struct flowi *fl, unsigned short family)
+static inline xfrm_address_t *xfrm_flowi_saddr(struct flowi *fl,
+					       unsigned short family)
 {
 	switch (family){
 	case AF_INET:
@@ -1040,9 +1038,9 @@ xfrm_address_t *xfrm_flowi_saddr(struct 
 	return NULL;
 }
 
-static __inline__ int
-__xfrm4_state_addr_check(struct xfrm_state *x,
-			 xfrm_address_t *daddr, xfrm_address_t *saddr)
+static inline int __xfrm4_state_addr_check(struct xfrm_state *x,
+					   xfrm_address_t *daddr,
+					   xfrm_address_t *saddr)
 {
 	if (daddr->a4 == x->id.daddr.a4 &&
 	    (saddr->a4 == x->props.saddr.a4 || !saddr->a4 || !x->props.saddr.a4))
@@ -1050,9 +1048,9 @@ __xfrm4_state_addr_check(struct xfrm_sta
 	return 0;
 }
 
-static __inline__ int
-__xfrm6_state_addr_check(struct xfrm_state *x,
-			 xfrm_address_t *daddr, xfrm_address_t *saddr)
+static inline int __xfrm6_state_addr_check(struct xfrm_state *x,
+					   xfrm_address_t *daddr,
+					   xfrm_address_t *saddr)
 {
 	if (!ipv6_addr_cmp((struct in6_addr *)daddr, (struct in6_addr *)&x->id.daddr) &&
 	    (!ipv6_addr_cmp((struct in6_addr *)saddr, (struct in6_addr *)&x->props.saddr)|| 
@@ -1062,10 +1060,10 @@ __xfrm6_state_addr_check(struct xfrm_sta
 	return 0;
 }
 
-static __inline__ int
-xfrm_state_addr_check(struct xfrm_state *x,
-		      xfrm_address_t *daddr, xfrm_address_t *saddr,
-		      unsigned short family)
+static inline int xfrm_state_addr_check(struct xfrm_state *x,
+					xfrm_address_t *daddr,
+					xfrm_address_t *saddr,
+					unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
@@ -1076,9 +1074,9 @@ xfrm_state_addr_check(struct xfrm_state 
 	return 0;
 }
 
-static __inline__ int
-xfrm_state_addr_flow_check(struct xfrm_state *x, struct flowi *fl,
-			   unsigned short family)
+static inline int xfrm_state_addr_flow_check(struct xfrm_state *x,
+					     struct flowi *fl,
+					     unsigned short family)
 {
 	switch (family) {
 	case AF_INET:

-- 
