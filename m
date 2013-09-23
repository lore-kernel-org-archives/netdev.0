From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/12] xfrm.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:53 -0700
Message-ID: <f997b035d78d877bf2fd143d22cc32c840fe2915.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0253.hostedemail.com ([216.40.44.253]:48232 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753819Ab3IWSd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:33:56 -0400
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/xfrm.h | 375 +++++++++++++++++++++++++++--------------------------
 1 file changed, 190 insertions(+), 185 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e253bf0..7657461 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -307,15 +307,17 @@ struct xfrm_policy_afinfo {
 	struct dst_entry	*(*blackhole_route)(struct net *net, struct dst_entry *orig);
 };
 
-extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
-extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
-extern void km_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c);
-extern void km_state_notify(struct xfrm_state *x, const struct km_event *c);
+int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
+int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
+void km_policy_notify(struct xfrm_policy *xp, int dir,
+		      const struct km_event *c);
+void km_state_notify(struct xfrm_state *x, const struct km_event *c);
 
 struct xfrm_tmpl;
-extern int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
-extern void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
-extern int __xfrm_state_delete(struct xfrm_state *x);
+int km_query(struct xfrm_state *x, struct xfrm_tmpl *t,
+	     struct xfrm_policy *pol);
+void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
+int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
 	unsigned int		family;
@@ -344,12 +346,12 @@ struct xfrm_state_afinfo {
 	void			(*local_error)(struct sk_buff *skb, u32 mtu);
 };
 
-extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
-extern int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
-extern struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
-extern void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
+int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
+int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
+struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
+void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
-extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
+void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
 struct xfrm_type {
 	char			*description;
@@ -372,8 +374,8 @@ struct xfrm_type {
 	u32			(*get_mtu)(struct xfrm_state *, int size);
 };
 
-extern int xfrm_register_type(const struct xfrm_type *type, unsigned short family);
-extern int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family);
+int xfrm_register_type(const struct xfrm_type *type, unsigned short family);
+int xfrm_unregister_type(const struct xfrm_type *type, unsigned short family);
 
 struct xfrm_mode {
 	/*
@@ -434,8 +436,8 @@ enum {
 	XFRM_MODE_FLAG_TUNNEL = 1,
 };
 
-extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
-extern int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
+int xfrm_register_mode(struct xfrm_mode *mode, int family);
+int xfrm_unregister_mode(struct xfrm_mode *mode, int family);
 
 static inline int xfrm_af2proto(unsigned int family)
 {
@@ -595,8 +597,8 @@ struct xfrm_mgr {
 					   const struct xfrm_kmaddress *k);
 };
 
-extern int xfrm_register_km(struct xfrm_mgr *km);
-extern int xfrm_unregister_km(struct xfrm_mgr *km);
+int xfrm_register_km(struct xfrm_mgr *km);
+int xfrm_unregister_km(struct xfrm_mgr *km);
 
 /*
  * This structure is used for the duration where packets are being
@@ -713,23 +715,23 @@ static inline void xfrm_audit_helper_usrinfo(kuid_t auid, u32 ses, u32 secid,
 		audit_log_task_context(audit_buf);
 }
 
-extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  kuid_t auid, u32 ses, u32 secid);
-extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  kuid_t auid, u32 ses, u32 secid);
-extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 kuid_t auid, u32 ses, u32 secid);
-extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    kuid_t auid, u32 ses, u32 secid);
-extern void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
-					     struct sk_buff *skb);
-extern void xfrm_audit_state_replay(struct xfrm_state *x,
-				    struct sk_buff *skb, __be32 net_seq);
-extern void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family);
-extern void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
-				      __be32 net_spi, __be32 net_seq);
-extern void xfrm_audit_state_icvfail(struct xfrm_state *x,
-				     struct sk_buff *skb, u8 proto);
+void xfrm_audit_policy_add(struct xfrm_policy *xp, int result, kuid_t auid,
+			   u32 ses, u32 secid);
+void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, kuid_t auid,
+			      u32 ses, u32 secid);
+void xfrm_audit_state_add(struct xfrm_state *x, int result, kuid_t auid,
+			  u32 ses, u32 secid);
+void xfrm_audit_state_delete(struct xfrm_state *x, int result, kuid_t auid,
+			     u32 ses, u32 secid);
+void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
+				      struct sk_buff *skb);
+void xfrm_audit_state_replay(struct xfrm_state *x, struct sk_buff *skb,
+			     __be32 net_seq);
+void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family);
+void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family, __be32 net_spi,
+			       __be32 net_seq);
+void xfrm_audit_state_icvfail(struct xfrm_state *x, struct sk_buff *skb,
+			      u8 proto);
 #else
 
 static inline void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
@@ -784,7 +786,7 @@ static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 		atomic_inc(&policy->refcnt);
 }
 
-extern void xfrm_policy_destroy(struct xfrm_policy *policy);
+void xfrm_policy_destroy(struct xfrm_policy *policy);
 
 static inline void xfrm_pol_put(struct xfrm_policy *policy)
 {
@@ -799,7 +801,7 @@ static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
 		xfrm_pol_put(pols[i]);
 }
 
-extern void __xfrm_state_destroy(struct xfrm_state *);
+void __xfrm_state_destroy(struct xfrm_state *);
 
 static inline void __xfrm_state_put(struct xfrm_state *x)
 {
@@ -903,9 +905,8 @@ __be16 xfrm_flowi_dport(const struct flowi *fl, const union flowi_uli *uli)
 	return port;
 }
 
-extern bool xfrm_selector_match(const struct xfrm_selector *sel,
-				const struct flowi *fl,
-				unsigned short family);
+bool xfrm_selector_match(const struct xfrm_selector *sel,
+			 const struct flowi *fl, unsigned short family);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 /*	If neither has a context --> match
@@ -975,7 +976,7 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 }
 #endif
 
-extern void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
+void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
 
 struct sec_path {
 	atomic_t		refcnt;
@@ -1000,7 +1001,7 @@ secpath_get(struct sec_path *sp)
 	return sp;
 }
 
-extern void __secpath_destroy(struct sec_path *sp);
+void __secpath_destroy(struct sec_path *sp);
 
 static inline void
 secpath_put(struct sec_path *sp)
@@ -1009,7 +1010,7 @@ secpath_put(struct sec_path *sp)
 		__secpath_destroy(sp);
 }
 
-extern struct sec_path *secpath_dup(struct sec_path *src);
+struct sec_path *secpath_dup(struct sec_path *src);
 
 static inline void
 secpath_reset(struct sk_buff *skb)
@@ -1059,7 +1060,8 @@ xfrm_state_addr_cmp(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x, un
 }
 
 #ifdef CONFIG_XFRM
-extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
+int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb,
+			unsigned short family);
 
 static inline int __xfrm_policy_check2(struct sock *sk, int dir,
 				       struct sk_buff *skb,
@@ -1103,8 +1105,8 @@ static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
 	return __xfrm_policy_check2(sk, dir, skb, AF_INET6, 1);
 }
 
-extern int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
-				 unsigned int family, int reverse);
+int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+			  unsigned int family, int reverse);
 
 static inline int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 				      unsigned int family)
@@ -1119,7 +1121,7 @@ static inline int xfrm_decode_session_reverse(struct sk_buff *skb,
 	return __xfrm_decode_session(skb, fl, family, 1);
 }
 
-extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
+int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
@@ -1140,7 +1142,7 @@ static inline int xfrm6_route_forward(struct sk_buff *skb)
 	return xfrm_route_forward(skb, AF_INET6);
 }
 
-extern int __xfrm_sk_clone_policy(struct sock *sk);
+int __xfrm_sk_clone_policy(struct sock *sk);
 
 static inline int xfrm_sk_clone_policy(struct sock *sk)
 {
@@ -1149,7 +1151,7 @@ static inline int xfrm_sk_clone_policy(struct sock *sk)
 	return 0;
 }
 
-extern int xfrm_policy_delete(struct xfrm_policy *pol, int dir);
+int xfrm_policy_delete(struct xfrm_policy *pol, int dir);
 
 static inline void xfrm_sk_free_policy(struct sock *sk)
 {
@@ -1163,7 +1165,7 @@ static inline void xfrm_sk_free_policy(struct sock *sk)
 	}
 }
 
-extern void xfrm_garbage_collect(struct net *net);
+void xfrm_garbage_collect(struct net *net);
 
 #else
 
@@ -1363,16 +1365,16 @@ struct xfrm6_tunnel {
 	int priority;
 };
 
-extern void xfrm_init(void);
-extern void xfrm4_init(void);
-extern int xfrm_state_init(struct net *net);
-extern void xfrm_state_fini(struct net *net);
-extern void xfrm4_state_init(void);
+void xfrm_init(void);
+void xfrm4_init(void);
+int xfrm_state_init(struct net *net);
+void xfrm_state_fini(struct net *net);
+void xfrm4_state_init(void);
 #ifdef CONFIG_XFRM
-extern int xfrm6_init(void);
-extern void xfrm6_fini(void);
-extern int xfrm6_state_init(void);
-extern void xfrm6_state_fini(void);
+int xfrm6_init(void);
+void xfrm6_fini(void);
+int xfrm6_state_init(void);
+void xfrm6_state_fini(void);
 #else
 static inline int xfrm6_init(void)
 {
@@ -1385,52 +1387,52 @@ static inline void xfrm6_fini(void)
 #endif
 
 #ifdef CONFIG_XFRM_STATISTICS
-extern int xfrm_proc_init(struct net *net);
-extern void xfrm_proc_fini(struct net *net);
+int xfrm_proc_init(struct net *net);
+void xfrm_proc_fini(struct net *net);
 #endif
 
-extern int xfrm_sysctl_init(struct net *net);
+int xfrm_sysctl_init(struct net *net);
 #ifdef CONFIG_SYSCTL
-extern void xfrm_sysctl_fini(struct net *net);
+void xfrm_sysctl_fini(struct net *net);
 #else
 static inline void xfrm_sysctl_fini(struct net *net)
 {
 }
 #endif
 
-extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
-extern int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
-			   int (*func)(struct xfrm_state *, int, void*), void *);
-extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
-extern struct xfrm_state *xfrm_state_alloc(struct net *net);
-extern struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
-					  const xfrm_address_t *saddr,
-					  const struct flowi *fl,
-					  struct xfrm_tmpl *tmpl,
-					  struct xfrm_policy *pol, int *err,
-					  unsigned short family);
-extern struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
-					       xfrm_address_t *daddr,
-					       xfrm_address_t *saddr,
-					       unsigned short family,
-					       u8 mode, u8 proto, u32 reqid);
-extern int xfrm_state_check_expire(struct xfrm_state *x);
-extern void xfrm_state_insert(struct xfrm_state *x);
-extern int xfrm_state_add(struct xfrm_state *x);
-extern int xfrm_state_update(struct xfrm_state *x);
-extern struct xfrm_state *xfrm_state_lookup(struct net *net, u32 mark,
-					    const xfrm_address_t *daddr, __be32 spi,
-					    u8 proto, unsigned short family);
-extern struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, u32 mark,
-						   const xfrm_address_t *daddr,
-						   const xfrm_address_t *saddr,
-						   u8 proto,
-						   unsigned short family);
+void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
+int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
+		    int (*func)(struct xfrm_state *, int, void*), void *);
+void xfrm_state_walk_done(struct xfrm_state_walk *walk);
+struct xfrm_state *xfrm_state_alloc(struct net *net);
+struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
+				   const xfrm_address_t *saddr,
+				   const struct flowi *fl,
+				   struct xfrm_tmpl *tmpl,
+				   struct xfrm_policy *pol, int *err,
+				   unsigned short family);
+struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
+				       xfrm_address_t *daddr,
+				       xfrm_address_t *saddr,
+				       unsigned short family,
+				       u8 mode, u8 proto, u32 reqid);
+int xfrm_state_check_expire(struct xfrm_state *x);
+void xfrm_state_insert(struct xfrm_state *x);
+int xfrm_state_add(struct xfrm_state *x);
+int xfrm_state_update(struct xfrm_state *x);
+struct xfrm_state *xfrm_state_lookup(struct net *net, u32 mark,
+				     const xfrm_address_t *daddr, __be32 spi,
+				     u8 proto, unsigned short family);
+struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, u32 mark,
+					    const xfrm_address_t *daddr,
+					    const xfrm_address_t *saddr,
+					    u8 proto,
+					    unsigned short family);
 #ifdef CONFIG_XFRM_SUB_POLICY
-extern int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
-			  int n, unsigned short family);
-extern int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src,
-			   int n, unsigned short family);
+int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
+		   unsigned short family);
+int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
+		    unsigned short family);
 #else
 static inline int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
 				 int n, unsigned short family)
@@ -1462,68 +1464,68 @@ struct xfrmk_spdinfo {
 	u32 spdhmcnt;
 };
 
-extern struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark,
-					      u32 seq);
-extern int xfrm_state_delete(struct xfrm_state *x);
-extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
-extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
-extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
-extern u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
-extern int xfrm_init_replay(struct xfrm_state *x);
-extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
-extern int __xfrm_init_state(struct xfrm_state *x, bool init_replay);
-extern int xfrm_init_state(struct xfrm_state *x);
-extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
-		      int encap_type);
-extern int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
-extern int xfrm_output_resume(struct sk_buff *skb, int err);
-extern int xfrm_output(struct sk_buff *skb);
-extern int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
-extern void xfrm_local_error(struct sk_buff *skb, int mtu);
-extern int xfrm4_extract_header(struct sk_buff *skb);
-extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
-			   int encap_type);
-extern int xfrm4_transport_finish(struct sk_buff *skb, int async);
-extern int xfrm4_rcv(struct sk_buff *skb);
+struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
+int xfrm_state_delete(struct xfrm_state *x);
+int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
+void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
+void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
+u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
+int xfrm_init_replay(struct xfrm_state *x);
+int xfrm_state_mtu(struct xfrm_state *x, int mtu);
+int __xfrm_init_state(struct xfrm_state *x, bool init_replay);
+int xfrm_init_state(struct xfrm_state *x);
+int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type);
+int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
+int xfrm_output_resume(struct sk_buff *skb, int err);
+int xfrm_output(struct sk_buff *skb);
+int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+void xfrm_local_error(struct sk_buff *skb, int mtu);
+int xfrm4_extract_header(struct sk_buff *skb);
+int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
+		    int encap_type);
+int xfrm4_transport_finish(struct sk_buff *skb, int async);
+int xfrm4_rcv(struct sk_buff *skb);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
 	return xfrm4_rcv_encap(skb, nexthdr, spi, 0);
 }
 
-extern int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm4_output(struct sk_buff *skb);
-extern int xfrm4_output_finish(struct sk_buff *skb);
-extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
-extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
-extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
-extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
-extern void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
-extern int xfrm6_extract_header(struct sk_buff *skb);
-extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
-extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
-extern int xfrm6_rcv(struct sk_buff *skb);
-extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
-			    xfrm_address_t *saddr, u8 proto);
-extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
-extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
-extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
-extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr);
-extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
-extern int xfrm6_output(struct sk_buff *skb);
-extern int xfrm6_output_finish(struct sk_buff *skb);
-extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
-				 u8 **prevhdr);
-extern void xfrm6_local_error(struct sk_buff *skb, u32 mtu);
+int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm4_output(struct sk_buff *skb);
+int xfrm4_output_finish(struct sk_buff *skb);
+int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
+int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
+int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
+int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
+void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
+int xfrm6_extract_header(struct sk_buff *skb);
+int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
+int xfrm6_transport_finish(struct sk_buff *skb, int async);
+int xfrm6_rcv(struct sk_buff *skb);
+int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
+		     xfrm_address_t *saddr, u8 proto);
+int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
+int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler,
+			    unsigned short family);
+__be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
+__be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr);
+int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
+int xfrm6_output(struct sk_buff *skb);
+int xfrm6_output_finish(struct sk_buff *skb);
+int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
+			  u8 **prevhdr);
+void xfrm6_local_error(struct sk_buff *skb, u32 mtu);
 
 #ifdef CONFIG_XFRM
-extern int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
-extern int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen);
+int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
+int xfrm_user_policy(struct sock *sk, int optname,
+		     u8 __user *optval, int optlen);
 #else
 static inline int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
@@ -1540,59 +1542,62 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 
 struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
-extern void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
-extern int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
-	int (*func)(struct xfrm_policy *, int, int, void*), void *);
-extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
+void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
+int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
+		     int (*func)(struct xfrm_policy *, int, int, void*),
+		     void *);
+void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 					  u8 type, int dir,
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
-struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir, u32 id, int delete, int *err);
+struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
+				     u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
-extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
+int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state *xfrm_find_acq(struct net *net, const struct xfrm_mark *mark,
 				 u8 mode, u32 reqid, u8 proto,
 				 const xfrm_address_t *daddr,
 				 const xfrm_address_t *saddr, int create,
 				 unsigned short family);
-extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
+int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 
 #ifdef CONFIG_XFRM_MIGRATE
-extern int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
-		      const struct xfrm_migrate *m, int num_bundles,
-		      const struct xfrm_kmaddress *k);
-extern struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m);
-extern struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
-					      struct xfrm_migrate *m);
-extern int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
-			struct xfrm_migrate *m, int num_bundles,
-			struct xfrm_kmaddress *k);
+int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+	       const struct xfrm_migrate *m, int num_bundles,
+	       const struct xfrm_kmaddress *k);
+struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m);
+struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
+				      struct xfrm_migrate *m);
+int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
+		 struct xfrm_migrate *m, int num_bundles,
+		 struct xfrm_kmaddress *k);
 #endif
 
-extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
-extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 portid);
-extern int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
-
-extern void xfrm_input_init(void);
-extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
-
-extern void xfrm_probe_algs(void);
-extern int xfrm_count_pfkey_auth_supported(void);
-extern int xfrm_count_pfkey_enc_supported(void);
-extern struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx);
-extern struct xfrm_algo_desc *xfrm_ealg_get_byidx(unsigned int idx);
-extern struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id);
-extern struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id);
-extern struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id);
-extern struct xfrm_algo_desc *xfrm_aalg_get_byname(const char *name, int probe);
-extern struct xfrm_algo_desc *xfrm_ealg_get_byname(const char *name, int probe);
-extern struct xfrm_algo_desc *xfrm_calg_get_byname(const char *name, int probe);
-extern struct xfrm_algo_desc *xfrm_aead_get_byname(const char *name, int icv_len,
-						   int probe);
+int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
+void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 portid);
+int km_report(struct net *net, u8 proto, struct xfrm_selector *sel,
+	      xfrm_address_t *addr);
+
+void xfrm_input_init(void);
+int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
+
+void xfrm_probe_algs(void);
+int xfrm_count_pfkey_auth_supported(void);
+int xfrm_count_pfkey_enc_supported(void);
+struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx);
+struct xfrm_algo_desc *xfrm_ealg_get_byidx(unsigned int idx);
+struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id);
+struct xfrm_algo_desc *xfrm_ealg_get_byid(int alg_id);
+struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id);
+struct xfrm_algo_desc *xfrm_aalg_get_byname(const char *name, int probe);
+struct xfrm_algo_desc *xfrm_ealg_get_byname(const char *name, int probe);
+struct xfrm_algo_desc *xfrm_calg_get_byname(const char *name, int probe);
+struct xfrm_algo_desc *xfrm_aead_get_byname(const char *name, int icv_len,
+					    int probe);
 
 static inline bool xfrm6_addr_equal(const xfrm_address_t *a,
 				    const xfrm_address_t *b)
-- 
1.8.1.2.459.gbcd45b4.dirty
