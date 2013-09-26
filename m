From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] netfilter: Remove extern from function prototypes
Date: Thu, 26 Sep 2013 15:18:31 -0700
Message-ID: <a0f4ecf3494c9869d20f606e7e2b2f50f0e67a7f.1380233637.git.joe@perches.com>
References: <cover.1380233637.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380233637.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netfilter.h                        |  10 +-
 include/linux/netfilter/nf_conntrack_common.h    |   2 +-
 include/linux/netfilter/nf_conntrack_h323.h      |  14 +--
 include/linux/netfilter/nf_conntrack_proto_gre.h |   4 +-
 include/linux/netfilter/nf_conntrack_sip.h       |  57 +++++-----
 include/linux/netfilter/nfnetlink.h              |  28 ++---
 include/linux/netfilter/nfnetlink_acct.h         |   6 +-
 include/linux/netfilter/x_tables.h               | 128 +++++++++++------------
 include/linux/netfilter_bridge.h                 |   4 +-
 include/linux/netfilter_ipv4.h                   |   6 +-
 include/linux/netfilter_ipv6.h                   |  10 +-
 11 files changed, 133 insertions(+), 136 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 708fe72ab9..61223c5 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -35,7 +35,7 @@ static inline void nf_inet_addr_mask(const union nf_inet_addr *a1,
 	result->all[3] = a1->all[3] & mask->all[3];
 }
 
-extern int netfilter_init(void);
+int netfilter_init(void);
 
 /* Largest hook number + 1 */
 #define NF_MAX_HOOKS 8
@@ -208,7 +208,7 @@ int compat_nf_getsockopt(struct sock *sk, u_int8_t pf, int optval,
 /* Call this before modifying an existing packet: ensures it is
    modifiable and linear to the point you care about (writable_len).
    Returns true or false. */
-extern int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
+int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
 
 struct flowi;
 struct nf_queue_entry;
@@ -269,8 +269,8 @@ nf_checksum_partial(struct sk_buff *skb, unsigned int hook,
 	return csum;
 }
 
-extern int nf_register_afinfo(const struct nf_afinfo *afinfo);
-extern void nf_unregister_afinfo(const struct nf_afinfo *afinfo);
+int nf_register_afinfo(const struct nf_afinfo *afinfo);
+void nf_unregister_afinfo(const struct nf_afinfo *afinfo);
 
 #include <net/flow.h>
 extern void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
@@ -315,7 +315,7 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 extern void (*ip_ct_attach)(struct sk_buff *, const struct sk_buff *) __rcu;
-extern void nf_ct_attach(struct sk_buff *, const struct sk_buff *);
+void nf_ct_attach(struct sk_buff *, const struct sk_buff *);
 extern void (*nf_ct_destroy)(struct nf_conntrack *) __rcu;
 
 struct nf_conn;
diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 127d0b9..2755057 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -23,6 +23,6 @@ struct ip_conntrack_stat {
 };
 
 /* call to create an explicit dependency on nf_conntrack. */
-extern void need_conntrack(void);
+void need_conntrack(void);
 
 #endif /* _NF_CONNTRACK_COMMON_H */
diff --git a/include/linux/netfilter/nf_conntrack_h323.h b/include/linux/netfilter/nf_conntrack_h323.h
index f381020..858d9b2 100644
--- a/include/linux/netfilter/nf_conntrack_h323.h
+++ b/include/linux/netfilter/nf_conntrack_h323.h
@@ -29,13 +29,13 @@ struct nf_ct_h323_master {
 
 struct nf_conn;
 
-extern int get_h225_addr(struct nf_conn *ct, unsigned char *data,
-			 TransportAddress *taddr,
-			 union nf_inet_addr *addr, __be16 *port);
-extern void nf_conntrack_h245_expect(struct nf_conn *new,
-				     struct nf_conntrack_expect *this);
-extern void nf_conntrack_q931_expect(struct nf_conn *new,
-				     struct nf_conntrack_expect *this);
+int get_h225_addr(struct nf_conn *ct, unsigned char *data,
+		  TransportAddress *taddr, union nf_inet_addr *addr,
+		  __be16 *port);
+void nf_conntrack_h245_expect(struct nf_conn *new,
+			      struct nf_conntrack_expect *this);
+void nf_conntrack_q931_expect(struct nf_conn *new,
+			      struct nf_conntrack_expect *this);
 extern int (*set_h245_addr_hook) (struct sk_buff *skb, unsigned int protoff,
 				  unsigned char **data, int dataoff,
 				  H245_TransportAddress *taddr,
diff --git a/include/linux/netfilter/nf_conntrack_proto_gre.h b/include/linux/netfilter/nf_conntrack_proto_gre.h
index 6a0664c..ec2ffaf 100644
--- a/include/linux/netfilter/nf_conntrack_proto_gre.h
+++ b/include/linux/netfilter/nf_conntrack_proto_gre.h
@@ -87,8 +87,8 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 /* delete keymap entries */
 void nf_ct_gre_keymap_destroy(struct nf_conn *ct);
 
-extern void nf_ct_gre_keymap_flush(struct net *net);
-extern void nf_nat_need_gre(void);
+void nf_ct_gre_keymap_flush(struct net *net);
+void nf_nat_need_gre(void);
 
 #endif /* __KERNEL__ */
 #endif /* _CONNTRACK_PROTO_GRE_H */
diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index ba7f571..5cac020 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -157,35 +157,34 @@ extern unsigned int (*nf_nat_sdp_media_hook)(struct sk_buff *skb,
 					     unsigned int medialen,
 					     union nf_inet_addr *rtp_addr);
 
-extern int ct_sip_parse_request(const struct nf_conn *ct,
-				const char *dptr, unsigned int datalen,
-				unsigned int *matchoff, unsigned int *matchlen,
-				union nf_inet_addr *addr, __be16 *port);
-extern int ct_sip_get_header(const struct nf_conn *ct, const char *dptr,
-			     unsigned int dataoff, unsigned int datalen,
-			     enum sip_header_types type,
-			     unsigned int *matchoff, unsigned int *matchlen);
-extern int ct_sip_parse_header_uri(const struct nf_conn *ct, const char *dptr,
-				   unsigned int *dataoff, unsigned int datalen,
-				   enum sip_header_types type, int *in_header,
-				   unsigned int *matchoff, unsigned int *matchlen,
-				   union nf_inet_addr *addr, __be16 *port);
-extern int ct_sip_parse_address_param(const struct nf_conn *ct, const char *dptr,
-				      unsigned int dataoff, unsigned int datalen,
-				      const char *name,
-				      unsigned int *matchoff, unsigned int *matchlen,
-				      union nf_inet_addr *addr, bool delim);
-extern int ct_sip_parse_numerical_param(const struct nf_conn *ct, const char *dptr,
-					unsigned int off, unsigned int datalen,
-					const char *name,
-					unsigned int *matchoff, unsigned int *matchen,
-					unsigned int *val);
-
-extern int ct_sip_get_sdp_header(const struct nf_conn *ct, const char *dptr,
-				 unsigned int dataoff, unsigned int datalen,
-				 enum sdp_header_types type,
-				 enum sdp_header_types term,
-				 unsigned int *matchoff, unsigned int *matchlen);
+int ct_sip_parse_request(const struct nf_conn *ct, const char *dptr,
+			 unsigned int datalen, unsigned int *matchoff,
+			 unsigned int *matchlen, union nf_inet_addr *addr,
+			 __be16 *port);
+int ct_sip_get_header(const struct nf_conn *ct, const char *dptr,
+		      unsigned int dataoff, unsigned int datalen,
+		      enum sip_header_types type, unsigned int *matchoff,
+		      unsigned int *matchlen);
+int ct_sip_parse_header_uri(const struct nf_conn *ct, const char *dptr,
+			    unsigned int *dataoff, unsigned int datalen,
+			    enum sip_header_types type, int *in_header,
+			    unsigned int *matchoff, unsigned int *matchlen,
+			    union nf_inet_addr *addr, __be16 *port);
+int ct_sip_parse_address_param(const struct nf_conn *ct, const char *dptr,
+			       unsigned int dataoff, unsigned int datalen,
+			       const char *name, unsigned int *matchoff,
+			       unsigned int *matchlen, union nf_inet_addr *addr,
+			       bool delim);
+int ct_sip_parse_numerical_param(const struct nf_conn *ct, const char *dptr,
+				 unsigned int off, unsigned int datalen,
+				 const char *name, unsigned int *matchoff,
+				 unsigned int *matchen, unsigned int *val);
+
+int ct_sip_get_sdp_header(const struct nf_conn *ct, const char *dptr,
+			  unsigned int dataoff, unsigned int datalen,
+			  enum sdp_header_types type,
+			  enum sdp_header_types term,
+			  unsigned int *matchoff, unsigned int *matchlen);
 
 #endif /* __KERNEL__ */
 #endif /* __NF_CONNTRACK_SIP_H__ */
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index cadb740..4f68cd7 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -25,20 +25,20 @@ struct nfnetlink_subsystem {
 	const struct nfnl_callback *cb;	/* callback for individual types */
 };
 
-extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
-extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
-
-extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
-extern struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
-					   u32 dst_portid, gfp_t gfp_mask);
-extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
-			  unsigned int group, int echo, gfp_t flags);
-extern int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
-extern int nfnetlink_unicast(struct sk_buff *skb, struct net *net,
-			     u32 portid, int flags);
-
-extern void nfnl_lock(__u8 subsys_id);
-extern void nfnl_unlock(__u8 subsys_id);
+int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
+int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
+
+int nfnetlink_has_listeners(struct net *net, unsigned int group);
+struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+				    u32 dst_portid, gfp_t gfp_mask);
+int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
+		   unsigned int group, int echo, gfp_t flags);
+int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
+int nfnetlink_unicast(struct sk_buff *skb, struct net *net, u32 portid,
+		      int flags);
+
+void nfnl_lock(__u8 subsys_id);
+void nfnl_unlock(__u8 subsys_id);
 
 #define MODULE_ALIAS_NFNL_SUBSYS(subsys) \
 	MODULE_ALIAS("nfnetlink-subsys-" __stringify(subsys))
diff --git a/include/linux/netfilter/nfnetlink_acct.h b/include/linux/netfilter/nfnetlink_acct.h
index bb4bbc9..b2e85e5 100644
--- a/include/linux/netfilter/nfnetlink_acct.h
+++ b/include/linux/netfilter/nfnetlink_acct.h
@@ -6,8 +6,8 @@
 
 struct nf_acct;
 
-extern struct nf_acct *nfnl_acct_find_get(const char *filter_name);
-extern void nfnl_acct_put(struct nf_acct *acct);
-extern void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct);
+struct nf_acct *nfnl_acct_find_get(const char *filter_name);
+void nfnl_acct_put(struct nf_acct *acct);
+void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct);
 
 #endif /* _NFNL_ACCT_H */
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index dd49566..a3e215b 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -229,50 +229,48 @@ struct xt_table_info {
 
 #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
 			  + nr_cpu_ids * sizeof(char *))
-extern int xt_register_target(struct xt_target *target);
-extern void xt_unregister_target(struct xt_target *target);
-extern int xt_register_targets(struct xt_target *target, unsigned int n);
-extern void xt_unregister_targets(struct xt_target *target, unsigned int n);
-
-extern int xt_register_match(struct xt_match *target);
-extern void xt_unregister_match(struct xt_match *target);
-extern int xt_register_matches(struct xt_match *match, unsigned int n);
-extern void xt_unregister_matches(struct xt_match *match, unsigned int n);
-
-extern int xt_check_match(struct xt_mtchk_param *,
-			  unsigned int size, u_int8_t proto, bool inv_proto);
-extern int xt_check_target(struct xt_tgchk_param *,
-			   unsigned int size, u_int8_t proto, bool inv_proto);
-
-extern struct xt_table *xt_register_table(struct net *net,
-					  const struct xt_table *table,
-					  struct xt_table_info *bootstrap,
-					  struct xt_table_info *newinfo);
-extern void *xt_unregister_table(struct xt_table *table);
-
-extern struct xt_table_info *xt_replace_table(struct xt_table *table,
-					      unsigned int num_counters,
-					      struct xt_table_info *newinfo,
-					      int *error);
-
-extern struct xt_match *xt_find_match(u8 af, const char *name, u8 revision);
-extern struct xt_target *xt_find_target(u8 af, const char *name, u8 revision);
-extern struct xt_match *xt_request_find_match(u8 af, const char *name,
-					      u8 revision);
-extern struct xt_target *xt_request_find_target(u8 af, const char *name,
-						u8 revision);
-extern int xt_find_revision(u8 af, const char *name, u8 revision,
-			    int target, int *err);
-
-extern struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
-					   const char *name);
-extern void xt_table_unlock(struct xt_table *t);
-
-extern int xt_proto_init(struct net *net, u_int8_t af);
-extern void xt_proto_fini(struct net *net, u_int8_t af);
-
-extern struct xt_table_info *xt_alloc_table_info(unsigned int size);
-extern void xt_free_table_info(struct xt_table_info *info);
+int xt_register_target(struct xt_target *target);
+void xt_unregister_target(struct xt_target *target);
+int xt_register_targets(struct xt_target *target, unsigned int n);
+void xt_unregister_targets(struct xt_target *target, unsigned int n);
+
+int xt_register_match(struct xt_match *target);
+void xt_unregister_match(struct xt_match *target);
+int xt_register_matches(struct xt_match *match, unsigned int n);
+void xt_unregister_matches(struct xt_match *match, unsigned int n);
+
+int xt_check_match(struct xt_mtchk_param *, unsigned int size, u_int8_t proto,
+		   bool inv_proto);
+int xt_check_target(struct xt_tgchk_param *, unsigned int size, u_int8_t proto,
+		    bool inv_proto);
+
+struct xt_table *xt_register_table(struct net *net,
+				   const struct xt_table *table,
+				   struct xt_table_info *bootstrap,
+				   struct xt_table_info *newinfo);
+void *xt_unregister_table(struct xt_table *table);
+
+struct xt_table_info *xt_replace_table(struct xt_table *table,
+				       unsigned int num_counters,
+				       struct xt_table_info *newinfo,
+				       int *error);
+
+struct xt_match *xt_find_match(u8 af, const char *name, u8 revision);
+struct xt_target *xt_find_target(u8 af, const char *name, u8 revision);
+struct xt_match *xt_request_find_match(u8 af, const char *name, u8 revision);
+struct xt_target *xt_request_find_target(u8 af, const char *name, u8 revision);
+int xt_find_revision(u8 af, const char *name, u8 revision, int target,
+		     int *err);
+
+struct xt_table *xt_find_table_lock(struct net *net, u_int8_t af,
+				    const char *name);
+void xt_table_unlock(struct xt_table *t);
+
+int xt_proto_init(struct net *net, u_int8_t af);
+void xt_proto_fini(struct net *net, u_int8_t af);
+
+struct xt_table_info *xt_alloc_table_info(unsigned int size);
+void xt_free_table_info(struct xt_table_info *info);
 
 /**
  * xt_recseq - recursive seqcount for netfilter use
@@ -353,8 +351,8 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 	return ret;
 }
 
-extern struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
-extern void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
+struct nf_hook_ops *xt_hook_link(const struct xt_table *, nf_hookfn *);
+void xt_hook_unlink(const struct xt_table *, struct nf_hook_ops *);
 
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
@@ -414,25 +412,25 @@ struct _compat_xt_align {
 
 #define COMPAT_XT_ALIGN(s) __ALIGN_KERNEL((s), __alignof__(struct _compat_xt_align))
 
-extern void xt_compat_lock(u_int8_t af);
-extern void xt_compat_unlock(u_int8_t af);
-
-extern int xt_compat_add_offset(u_int8_t af, unsigned int offset, int delta);
-extern void xt_compat_flush_offsets(u_int8_t af);
-extern void xt_compat_init_offsets(u_int8_t af, unsigned int number);
-extern int xt_compat_calc_jump(u_int8_t af, unsigned int offset);
-
-extern int xt_compat_match_offset(const struct xt_match *match);
-extern int xt_compat_match_from_user(struct xt_entry_match *m,
-				     void **dstptr, unsigned int *size);
-extern int xt_compat_match_to_user(const struct xt_entry_match *m,
-				   void __user **dstptr, unsigned int *size);
-
-extern int xt_compat_target_offset(const struct xt_target *target);
-extern void xt_compat_target_from_user(struct xt_entry_target *t,
-				       void **dstptr, unsigned int *size);
-extern int xt_compat_target_to_user(const struct xt_entry_target *t,
-				    void __user **dstptr, unsigned int *size);
+void xt_compat_lock(u_int8_t af);
+void xt_compat_unlock(u_int8_t af);
+
+int xt_compat_add_offset(u_int8_t af, unsigned int offset, int delta);
+void xt_compat_flush_offsets(u_int8_t af);
+void xt_compat_init_offsets(u_int8_t af, unsigned int number);
+int xt_compat_calc_jump(u_int8_t af, unsigned int offset);
+
+int xt_compat_match_offset(const struct xt_match *match);
+int xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
+			      unsigned int *size);
+int xt_compat_match_to_user(const struct xt_entry_match *m,
+			    void __user **dstptr, unsigned int *size);
+
+int xt_compat_target_offset(const struct xt_target *target);
+void xt_compat_target_from_user(struct xt_entry_target *t, void **dstptr,
+				unsigned int *size);
+int xt_compat_target_to_user(const struct xt_entry_target *t,
+			     void __user **dstptr, unsigned int *size);
 
 #endif /* CONFIG_COMPAT */
 #endif /* _X_TABLES_H */
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index dfb4d9e..8ab1c27 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -25,7 +25,7 @@ enum nf_br_hook_priorities {
 #define BRNF_PPPoE			0x20
 
 /* Only used in br_forward.c */
-extern int nf_bridge_copy_header(struct sk_buff *skb);
+int nf_bridge_copy_header(struct sk_buff *skb);
 static inline int nf_bridge_maybe_copy_header(struct sk_buff *skb)
 {
 	if (skb->nf_bridge &&
@@ -53,7 +53,7 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 	return 0;
 }
 
-extern int br_handle_frame_finish(struct sk_buff *skb);
+int br_handle_frame_finish(struct sk_buff *skb);
 /* Only used in br_device.c */
 static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 {
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index dfaf116..6e4591b 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -6,7 +6,7 @@
 
 #include <uapi/linux/netfilter_ipv4.h>
 
-extern int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type);
-extern __sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
-				   unsigned int dataoff, u_int8_t protocol);
+int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type);
+__sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
+		       unsigned int dataoff, u_int8_t protocol);
 #endif /*__LINUX_IP_NETFILTER_H*/
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 2d4df6ce..64dad1cc 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -11,12 +11,12 @@
 
 
 #ifdef CONFIG_NETFILTER
-extern int ip6_route_me_harder(struct sk_buff *skb);
-extern __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
-				    unsigned int dataoff, u_int8_t protocol);
+int ip6_route_me_harder(struct sk_buff *skb);
+__sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
+			unsigned int dataoff, u_int8_t protocol);
 
-extern int ipv6_netfilter_init(void);
-extern void ipv6_netfilter_fini(void);
+int ipv6_netfilter_init(void);
+void ipv6_netfilter_fini(void);
 
 /*
  * Hook functions for ipv6 to allow xt_* modules to be built-in even
-- 
1.8.1.2.459.gbcd45b4.dirty
