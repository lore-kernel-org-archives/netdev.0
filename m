From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/12] ip*.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:42 -0700
Message-ID: <a8ed8de28a17c7cff3a9bbe4f8ab3f748bf8eabb.1379783995.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
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
 include/net/ip.h        | 169 +++++++++++++++---------------
 include/net/ip6_fib.h   |  53 +++++-----
 include/net/ip6_route.h |  98 ++++++++----------
 include/net/ip_fib.h    |  61 ++++++-----
 include/net/ip_vs.h     | 245 +++++++++++++++++++++----------------------
 include/net/ipv6.h      | 268 +++++++++++++++++++++---------------------------
 6 files changed, 416 insertions(+), 478 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 5e52688..c1f192b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -86,53 +86,51 @@ struct packet_type;
 struct rtable;
 struct sockaddr;
 
-extern int		igmp_mc_proc_init(void);
+int igmp_mc_proc_init(void);
 
 /*
  *	Functions provided by ip.c
  */
 
-extern int		ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
-					      __be32 saddr, __be32 daddr,
-					      struct ip_options_rcu *opt);
-extern int		ip_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt, struct net_device *orig_dev);
-extern int		ip_local_deliver(struct sk_buff *skb);
-extern int		ip_mr_input(struct sk_buff *skb);
-extern int		ip_output(struct sk_buff *skb);
-extern int		ip_mc_output(struct sk_buff *skb);
-extern int		ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
-extern int		ip_do_nat(struct sk_buff *skb);
-extern void		ip_send_check(struct iphdr *ip);
-extern int		__ip_local_out(struct sk_buff *skb);
-extern int		ip_local_out(struct sk_buff *skb);
-extern int		ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
-extern void		ip_init(void);
-extern int		ip_append_data(struct sock *sk, struct flowi4 *fl4,
-				       int getfrag(void *from, char *to, int offset, int len,
-						   int odd, struct sk_buff *skb),
-				void *from, int len, int protolen,
-				struct ipcm_cookie *ipc,
-				struct rtable **rt,
-				unsigned int flags);
-extern int		ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb);
-extern ssize_t		ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
-				int offset, size_t size, int flags);
-extern struct sk_buff  *__ip_make_skb(struct sock *sk,
-				      struct flowi4 *fl4,
-				      struct sk_buff_head *queue,
-				      struct inet_cork *cork);
-extern int		ip_send_skb(struct net *net, struct sk_buff *skb);
-extern int		ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4);
-extern void		ip_flush_pending_frames(struct sock *sk);
-extern struct sk_buff  *ip_make_skb(struct sock *sk,
-				    struct flowi4 *fl4,
-				    int getfrag(void *from, char *to, int offset, int len,
-						int odd, struct sk_buff *skb),
-				    void *from, int length, int transhdrlen,
-				    struct ipcm_cookie *ipc,
-				    struct rtable **rtp,
-				    unsigned int flags);
+int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
+			  __be32 saddr, __be32 daddr,
+			  struct ip_options_rcu *opt);
+int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
+	   struct net_device *orig_dev);
+int ip_local_deliver(struct sk_buff *skb);
+int ip_mr_input(struct sk_buff *skb);
+int ip_output(struct sk_buff *skb);
+int ip_mc_output(struct sk_buff *skb);
+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip_do_nat(struct sk_buff *skb);
+void ip_send_check(struct iphdr *ip);
+int __ip_local_out(struct sk_buff *skb);
+int ip_local_out(struct sk_buff *skb);
+int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl);
+void ip_init(void);
+int ip_append_data(struct sock *sk, struct flowi4 *fl4,
+		   int getfrag(void *from, char *to, int offset, int len,
+			       int odd, struct sk_buff *skb),
+		   void *from, int len, int protolen,
+		   struct ipcm_cookie *ipc,
+		   struct rtable **rt,
+		   unsigned int flags);
+int ip_generic_getfrag(void *from, char *to, int offset, int len, int odd,
+		       struct sk_buff *skb);
+ssize_t ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
+		       int offset, size_t size, int flags);
+struct sk_buff *__ip_make_skb(struct sock *sk, struct flowi4 *fl4,
+			      struct sk_buff_head *queue,
+			      struct inet_cork *cork);
+int ip_send_skb(struct net *net, struct sk_buff *skb);
+int ip_push_pending_frames(struct sock *sk, struct flowi4 *fl4);
+void ip_flush_pending_frames(struct sock *sk);
+struct sk_buff *ip_make_skb(struct sock *sk, struct flowi4 *fl4,
+			    int getfrag(void *from, char *to, int offset,
+					int len, int odd, struct sk_buff *skb),
+			    void *from, int length, int transhdrlen,
+			    struct ipcm_cookie *ipc, struct rtable **rtp,
+			    unsigned int flags);
 
 static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 {
@@ -140,10 +138,9 @@ static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 }
 
 /* datagram.c */
-extern int		ip4_datagram_connect(struct sock *sk, 
-					     struct sockaddr *uaddr, int addr_len);
+int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
-extern void ip4_datagram_release_cb(struct sock *sk);
+void ip4_datagram_release_cb(struct sock *sk);
 
 struct ip_reply_arg {
 	struct kvec iov[1];   
@@ -184,16 +181,16 @@ extern struct ipv4_config ipv4_config;
 #define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
-extern unsigned long snmp_fold_field(void __percpu *mib[], int offt);
+unsigned long snmp_fold_field(void __percpu *mib[], int offt);
 #if BITS_PER_LONG==32
-extern u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t sync_off);
+u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t sync_off);
 #else
 static inline u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_off)
 {
 	return snmp_fold_field(mib, offt);
 }
 #endif
-extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
+int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
 
 static inline void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
 {
@@ -210,7 +207,7 @@ extern struct local_ports {
 	seqlock_t	lock;
 	int		range[2];
 } sysctl_local_ports;
-extern void inet_get_local_port_range(int *low, int *high);
+void inet_get_local_port_range(int *low, int *high);
 
 extern unsigned long *sysctl_local_reserved_ports;
 static inline int inet_is_reserved_local_port(int port)
@@ -231,9 +228,9 @@ extern int sysctl_ip_early_demux;
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
 
-extern void ipfrag_init(void);
+void ipfrag_init(void);
 
-extern void ip_static_sysctl_init(void);
+void ip_static_sysctl_init(void);
 
 static inline bool ip_is_fragment(const struct iphdr *iph)
 {
@@ -262,7 +259,7 @@ int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
 		 !(dst_metric_locked(dst, RTAX_MTU)));
 }
 
-extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more);
+void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst, int more);
 
 static inline void ip_select_ident(struct sk_buff *skb, struct dst_entry *dst, struct sock *sk)
 {
@@ -390,7 +387,7 @@ static inline int sk_mc_loop(struct sock *sk)
 	return 1;
 }
 
-extern bool ip_call_ra_chain(struct sk_buff *skb);
+bool ip_call_ra_chain(struct sk_buff *skb);
 
 /*
  *	Functions provided by ip_fragment.c
@@ -428,50 +425,52 @@ int ip_frag_nqueues(struct net *net);
  *	Functions provided by ip_forward.c
  */
  
-extern int ip_forward(struct sk_buff *skb);
+int ip_forward(struct sk_buff *skb);
  
 /*
  *	Functions provided by ip_options.c
  */
  
-extern void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
-			     __be32 daddr, struct rtable *rt, int is_frag);
-extern int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb);
-extern void ip_options_fragment(struct sk_buff *skb);
-extern int ip_options_compile(struct net *net,
-			      struct ip_options *opt, struct sk_buff *skb);
-extern int ip_options_get(struct net *net, struct ip_options_rcu **optp,
-			  unsigned char *data, int optlen);
-extern int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
-				    unsigned char __user *data, int optlen);
-extern void ip_options_undo(struct ip_options * opt);
-extern void ip_forward_options(struct sk_buff *skb);
-extern int ip_options_rcv_srr(struct sk_buff *skb);
+void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
+		      __be32 daddr, struct rtable *rt, int is_frag);
+int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb);
+void ip_options_fragment(struct sk_buff *skb);
+int ip_options_compile(struct net *net, struct ip_options *opt,
+		       struct sk_buff *skb);
+int ip_options_get(struct net *net, struct ip_options_rcu **optp,
+		   unsigned char *data, int optlen);
+int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
+			     unsigned char __user *data, int optlen);
+void ip_options_undo(struct ip_options *opt);
+void ip_forward_options(struct sk_buff *skb);
+int ip_options_rcv_srr(struct sk_buff *skb);
 
 /*
  *	Functions provided by ip_sockglue.c
  */
 
-extern void	ipv4_pktinfo_prepare(struct sk_buff *skb);
-extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
-extern int	ip_cmsg_send(struct net *net,
-			     struct msghdr *msg, struct ipcm_cookie *ipc);
-extern int	ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval, unsigned int optlen);
-extern int	ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval, int __user *optlen);
-extern int	compat_ip_setsockopt(struct sock *sk, int level,
-			int optname, char __user *optval, unsigned int optlen);
-extern int	compat_ip_getsockopt(struct sock *sk, int level,
-			int optname, char __user *optval, int __user *optlen);
-extern int	ip_ra_control(struct sock *sk, unsigned char on, void (*destructor)(struct sock *));
-
-extern int 	ip_recv_error(struct sock *sk, struct msghdr *msg, int len);
-extern void	ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err, 
-			      __be16 port, u32 info, u8 *payload);
-extern void	ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
-			       u32 info);
+void ipv4_pktinfo_prepare(struct sk_buff *skb);
+void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
+int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc);
+int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
+		  unsigned int optlen);
+int ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
+		  int __user *optlen);
+int compat_ip_setsockopt(struct sock *sk, int level, int optname,
+			 char __user *optval, unsigned int optlen);
+int compat_ip_getsockopt(struct sock *sk, int level, int optname,
+			 char __user *optval, int __user *optlen);
+int ip_ra_control(struct sock *sk, unsigned char on,
+		  void (*destructor)(struct sock *));
+
+int ip_recv_error(struct sock *sk, struct msghdr *msg, int len);
+void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
+		   u32 info, u8 *payload);
+void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
+		    u32 info);
 
 #ifdef CONFIG_PROC_FS
-extern int ip_misc_proc_init(void);
+int ip_misc_proc_init(void);
 #endif
 
 #endif	/* _IP_H */
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 48ec25a..eab88f0 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -267,48 +267,41 @@ typedef struct rt6_info *(*pol_lookup_t)(struct net *,
  *	exported functions
  */
 
-extern struct fib6_table        *fib6_get_table(struct net *net, u32 id);
-extern struct fib6_table        *fib6_new_table(struct net *net, u32 id);
-extern struct dst_entry         *fib6_rule_lookup(struct net *net,
-						  struct flowi6 *fl6, int flags,
-						  pol_lookup_t lookup);
+struct fib6_table *fib6_get_table(struct net *net, u32 id);
+struct fib6_table *fib6_new_table(struct net *net, u32 id);
+struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
+				   int flags, pol_lookup_t lookup);
 
-extern struct fib6_node		*fib6_lookup(struct fib6_node *root,
-					     const struct in6_addr *daddr,
-					     const struct in6_addr *saddr);
+struct fib6_node *fib6_lookup(struct fib6_node *root,
+			      const struct in6_addr *daddr,
+			      const struct in6_addr *saddr);
 
-struct fib6_node		*fib6_locate(struct fib6_node *root,
-					     const struct in6_addr *daddr, int dst_len,
-					     const struct in6_addr *saddr, int src_len);
+struct fib6_node *fib6_locate(struct fib6_node *root,
+			      const struct in6_addr *daddr, int dst_len,
+			      const struct in6_addr *saddr, int src_len);
 
-extern void			fib6_clean_all_ro(struct net *net,
-					       int (*func)(struct rt6_info *, void *arg),
-					       int prune, void *arg);
+void fib6_clean_all_ro(struct net *net,
+		       int (*func)(struct rt6_info *, void *arg),
+		       int prune, void *arg);
 
-extern void			fib6_clean_all(struct net *net,
-					       int (*func)(struct rt6_info *, void *arg),
-					       int prune, void *arg);
+void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
+		    int prune, void *arg);
 
-extern int			fib6_add(struct fib6_node *root,
-					 struct rt6_info *rt,
-					 struct nl_info *info);
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info);
 
-extern int			fib6_del(struct rt6_info *rt,
-					 struct nl_info *info);
+int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
-extern void			inet6_rt_notify(int event, struct rt6_info *rt,
-						struct nl_info *info);
+void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info);
 
-extern void			fib6_run_gc(unsigned long expires,
-					    struct net *net, bool force);
+void fib6_run_gc(unsigned long expires, struct net *net, bool force);
 
-extern void			fib6_gc_cleanup(void);
+void fib6_gc_cleanup(void);
 
-extern int			fib6_init(void);
+int fib6_init(void);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-extern int			fib6_rules_init(void);
-extern void			fib6_rules_cleanup(void);
+int fib6_rules_init(void);
+void fib6_rules_cleanup(void);
 #else
 static inline int               fib6_rules_init(void)
 {
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f525e70..02e220d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -51,7 +51,7 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
 	return (flags >> 3) & 7;
 }
 
-extern void rt6_bind_peer(struct rt6_info *rt, int create);
+void rt6_bind_peer(struct rt6_info *rt, int create);
 
 static inline struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
 {
@@ -72,70 +72,58 @@ static inline struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
 	return __rt6_get_peer(rt, 1);
 }
 
-extern void			ip6_route_input(struct sk_buff *skb);
+void ip6_route_input(struct sk_buff *skb);
 
-extern struct dst_entry *	ip6_route_output(struct net *net,
-						 const struct sock *sk,
-						 struct flowi6 *fl6);
-extern struct dst_entry *	ip6_route_lookup(struct net *net,
-						 struct flowi6 *fl6, int flags);
+struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
+				   struct flowi6 *fl6);
+struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
+				   int flags);
 
-extern int			ip6_route_init(void);
-extern void			ip6_route_cleanup(void);
+int ip6_route_init(void);
+void ip6_route_cleanup(void);
 
-extern int			ipv6_route_ioctl(struct net *net,
-						 unsigned int cmd,
-						 void __user *arg);
+int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg);
 
-extern int			ip6_route_add(struct fib6_config *cfg);
-extern int			ip6_ins_rt(struct rt6_info *);
-extern int			ip6_del_rt(struct rt6_info *);
+int ip6_route_add(struct fib6_config *cfg);
+int ip6_ins_rt(struct rt6_info *);
+int ip6_del_rt(struct rt6_info *);
 
-extern int			ip6_route_get_saddr(struct net *net,
-						    struct rt6_info *rt,
-						    const struct in6_addr *daddr,
-						    unsigned int prefs,
-						    struct in6_addr *saddr);
+int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
+			const struct in6_addr *daddr, unsigned int prefs,
+			struct in6_addr *saddr);
 
-extern struct rt6_info		*rt6_lookup(struct net *net,
-					    const struct in6_addr *daddr,
-					    const struct in6_addr *saddr,
-					    int oif, int flags);
+struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
+			    const struct in6_addr *saddr, int oif, int flags);
 
-extern struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
-					 struct flowi6 *fl6);
-extern int icmp6_dst_gc(void);
+struct dst_entry *icmp6_dst_alloc(struct net_device *dev, struct flowi6 *fl6);
+int icmp6_dst_gc(void);
 
-extern void fib6_force_start_gc(struct net *net);
+void fib6_force_start_gc(struct net *net);
 
-extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
-					   const struct in6_addr *addr,
-					   bool anycast);
+struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
+				    const struct in6_addr *addr, bool anycast);
 
 /*
  *	support functions for ND
  *
  */
-extern struct rt6_info *	rt6_get_dflt_router(const struct in6_addr *addr,
-						    struct net_device *dev);
-extern struct rt6_info *	rt6_add_dflt_router(const struct in6_addr *gwaddr,
-						    struct net_device *dev,
-						    unsigned int pref);
-
-extern void			rt6_purge_dflt_routers(struct net *net);
-
-extern int			rt6_route_rcv(struct net_device *dev,
-					      u8 *opt, int len,
-					      const struct in6_addr *gwaddr);
-
-extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
-			    int oif, u32 mark);
-extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
-			       __be32 mtu);
-extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
-extern void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
-				   u32 mark);
-extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
+struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr,
+				     struct net_device *dev);
+struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
+				     struct net_device *dev, unsigned int pref);
+
+void rt6_purge_dflt_routers(struct net *net);
+
+int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
+		  const struct in6_addr *gwaddr);
+
+void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu, int oif,
+		     u32 mark);
+void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu);
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
+void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+			    u32 mark);
+void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
 struct netlink_callback;
 
@@ -145,10 +133,10 @@ struct rt6_rtnl_dump_arg {
 	struct net *net;
 };
 
-extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
-extern void rt6_ifdown(struct net *net, struct net_device *dev);
-extern void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
-extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
+int rt6_dump_route(struct rt6_info *rt, void *p_arg);
+void rt6_ifdown(struct net *net, struct net_device *dev);
+void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
+void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 
 
 /*
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index cbf2be3..9922093 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -165,7 +165,7 @@ struct fib_result_nl {
 #define FIB_TABLE_HASHSZ 2
 #endif
 
-extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
+__be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 
 #define FIB_RES_SADDR(net, res)				\
 	((FIB_RES_NH(res).nh_saddr_genid ==		\
@@ -187,14 +187,14 @@ struct fib_table {
 	unsigned long		tb_data[0];
 };
 
-extern int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
-			    struct fib_result *res, int fib_flags);
-extern int fib_table_insert(struct fib_table *, struct fib_config *);
-extern int fib_table_delete(struct fib_table *, struct fib_config *);
-extern int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
-			  struct netlink_callback *cb);
-extern int fib_table_flush(struct fib_table *table);
-extern void fib_free_table(struct fib_table *tb);
+int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
+		     struct fib_result *res, int fib_flags);
+int fib_table_insert(struct fib_table *, struct fib_config *);
+int fib_table_delete(struct fib_table *, struct fib_config *);
+int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
+		   struct netlink_callback *cb);
+int fib_table_flush(struct fib_table *table);
+void fib_free_table(struct fib_table *tb);
 
 
 
@@ -234,14 +234,13 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 }
 
 #else /* CONFIG_IP_MULTIPLE_TABLES */
-extern int __net_init fib4_rules_init(struct net *net);
-extern void __net_exit fib4_rules_exit(struct net *net);
+int __net_init fib4_rules_init(struct net *net);
+void __net_exit fib4_rules_exit(struct net *net);
 
-extern struct fib_table *fib_new_table(struct net *net, u32 id);
-extern struct fib_table *fib_get_table(struct net *net, u32 id);
+struct fib_table *fib_new_table(struct net *net, u32 id);
+struct fib_table *fib_get_table(struct net *net, u32 id);
 
-extern int __fib_lookup(struct net *net, struct flowi4 *flp,
-			struct fib_result *res);
+int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res);
 
 static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			     struct fib_result *res)
@@ -269,12 +268,12 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 
 /* Exported by fib_frontend.c */
 extern const struct nla_policy rtm_ipv4_policy[];
-extern void		ip_fib_init(void);
-extern __be32 fib_compute_spec_dst(struct sk_buff *skb);
-extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
-			       u8 tos, int oif, struct net_device *dev,
-			       struct in_device *idev, u32 *itag);
-extern void fib_select_default(struct fib_result *res);
+void ip_fib_init(void);
+__be32 fib_compute_spec_dst(struct sk_buff *skb);
+int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
+			u8 tos, int oif, struct net_device *dev,
+			struct in_device *idev, u32 *itag);
+void fib_select_default(struct fib_result *res);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 static inline int fib_num_tclassid_users(struct net *net)
 {
@@ -288,15 +287,15 @@ static inline int fib_num_tclassid_users(struct net *net)
 #endif
 
 /* Exported by fib_semantics.c */
-extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
-extern int fib_sync_down_dev(struct net_device *dev, int force);
-extern int fib_sync_down_addr(struct net *net, __be32 local);
-extern int fib_sync_up(struct net_device *dev);
-extern void fib_select_multipath(struct fib_result *res);
+int ip_fib_check_default(__be32 gw, struct net_device *dev);
+int fib_sync_down_dev(struct net_device *dev, int force);
+int fib_sync_down_addr(struct net *net, __be32 local);
+int fib_sync_up(struct net_device *dev);
+void fib_select_multipath(struct fib_result *res);
 
 /* Exported by fib_trie.c */
-extern void fib_trie_init(void);
-extern struct fib_table *fib_trie_table(u32 id);
+void fib_trie_init(void);
+struct fib_table *fib_trie_table(u32 id);
 
 static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 {
@@ -314,7 +313,7 @@ static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 #endif
 }
 
-extern void free_fib_info(struct fib_info *fi);
+void free_fib_info(struct fib_info *fi);
 
 static inline void fib_info_put(struct fib_info *fi)
 {
@@ -323,8 +322,8 @@ static inline void fib_info_put(struct fib_info *fi)
 }
 
 #ifdef CONFIG_PROC_FS
-extern int __net_init  fib_proc_init(struct net *net);
-extern void __net_exit fib_proc_exit(struct net *net);
+int __net_init fib_proc_init(struct net *net);
+void __net_exit fib_proc_exit(struct net *net);
 #else
 static inline int fib_proc_init(struct net *net)
 {
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f0d70f0..b6fd378 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -236,7 +236,7 @@ static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
 #ifdef CONFIG_IP_VS_DEBUG
 #include <linux/net.h>
 
-extern int ip_vs_get_debug_level(void);
+int ip_vs_get_debug_level(void);
 
 static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 					 const union nf_inet_addr *addr,
@@ -532,9 +532,9 @@ struct ip_vs_proto_data {
 	struct tcp_states_t	*tcp_state_table;
 };
 
-extern struct ip_vs_protocol   *ip_vs_proto_get(unsigned short proto);
-extern struct ip_vs_proto_data *ip_vs_proto_data_get(struct net *net,
-						     unsigned short proto);
+struct ip_vs_protocol   *ip_vs_proto_get(unsigned short proto);
+struct ip_vs_proto_data *ip_vs_proto_data_get(struct net *net,
+					      unsigned short proto);
 
 struct ip_vs_conn_param {
 	struct net			*net;
@@ -1176,8 +1176,8 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
  *      IPVS core functions
  *      (from ip_vs_core.c)
  */
-extern const char *ip_vs_proto_name(unsigned int proto);
-extern void ip_vs_init_hash_table(struct list_head *table, int rows);
+const char *ip_vs_proto_name(unsigned int proto);
+void ip_vs_init_hash_table(struct list_head *table, int rows);
 #define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table((t), ARRAY_SIZE((t)))
 
 #define IP_VS_APP_TYPE_FTP	1
@@ -1240,22 +1240,22 @@ static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 	smp_mb__before_atomic_dec();
 	atomic_dec(&cp->refcnt);
 }
-extern void ip_vs_conn_put(struct ip_vs_conn *cp);
-extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
+void ip_vs_conn_put(struct ip_vs_conn *cp);
+void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
 struct ip_vs_conn *ip_vs_conn_new(const struct ip_vs_conn_param *p,
 				  const union nf_inet_addr *daddr,
 				  __be16 dport, unsigned int flags,
 				  struct ip_vs_dest *dest, __u32 fwmark);
-extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
+void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
-extern const char * ip_vs_state_name(__u16 proto, int state);
+const char *ip_vs_state_name(__u16 proto, int state);
 
-extern void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
-extern int ip_vs_check_template(struct ip_vs_conn *ct);
-extern void ip_vs_random_dropentry(struct net *net);
-extern int ip_vs_conn_init(void);
-extern void ip_vs_conn_cleanup(void);
+void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
+int ip_vs_check_template(struct ip_vs_conn *ct);
+void ip_vs_random_dropentry(struct net *net);
+int ip_vs_conn_init(void);
+void ip_vs_conn_cleanup(void);
 
 static inline void ip_vs_control_del(struct ip_vs_conn *cp)
 {
@@ -1320,37 +1320,36 @@ ip_vs_control_add(struct ip_vs_conn *cp, struct ip_vs_conn *ctl_cp)
 /*
  * IPVS netns init & cleanup functions
  */
-extern int ip_vs_estimator_net_init(struct net *net);
-extern int ip_vs_control_net_init(struct net *net);
-extern int ip_vs_protocol_net_init(struct net *net);
-extern int ip_vs_app_net_init(struct net *net);
-extern int ip_vs_conn_net_init(struct net *net);
-extern int ip_vs_sync_net_init(struct net *net);
-extern void ip_vs_conn_net_cleanup(struct net *net);
-extern void ip_vs_app_net_cleanup(struct net *net);
-extern void ip_vs_protocol_net_cleanup(struct net *net);
-extern void ip_vs_control_net_cleanup(struct net *net);
-extern void ip_vs_estimator_net_cleanup(struct net *net);
-extern void ip_vs_sync_net_cleanup(struct net *net);
-extern void ip_vs_service_net_cleanup(struct net *net);
+int ip_vs_estimator_net_init(struct net *net);
+int ip_vs_control_net_init(struct net *net);
+int ip_vs_protocol_net_init(struct net *net);
+int ip_vs_app_net_init(struct net *net);
+int ip_vs_conn_net_init(struct net *net);
+int ip_vs_sync_net_init(struct net *net);
+void ip_vs_conn_net_cleanup(struct net *net);
+void ip_vs_app_net_cleanup(struct net *net);
+void ip_vs_protocol_net_cleanup(struct net *net);
+void ip_vs_control_net_cleanup(struct net *net);
+void ip_vs_estimator_net_cleanup(struct net *net);
+void ip_vs_sync_net_cleanup(struct net *net);
+void ip_vs_service_net_cleanup(struct net *net);
 
 /*
  *      IPVS application functions
  *      (from ip_vs_app.c)
  */
 #define IP_VS_APP_MAX_PORTS  8
-extern struct ip_vs_app *register_ip_vs_app(struct net *net,
-					    struct ip_vs_app *app);
-extern void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
-extern int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
-extern void ip_vs_unbind_app(struct ip_vs_conn *cp);
-extern int register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app,
-				  __u16 proto, __u16 port);
-extern int ip_vs_app_inc_get(struct ip_vs_app *inc);
-extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
-
-extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
-extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
+struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app);
+void unregister_ip_vs_app(struct net *net, struct ip_vs_app *app);
+int ip_vs_bind_app(struct ip_vs_conn *cp, struct ip_vs_protocol *pp);
+void ip_vs_unbind_app(struct ip_vs_conn *cp);
+int register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
+			   __u16 port);
+int ip_vs_app_inc_get(struct ip_vs_app *inc);
+void ip_vs_app_inc_put(struct ip_vs_app *inc);
+
+int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
+int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
 
 int register_ip_vs_pe(struct ip_vs_pe *pe);
 int unregister_ip_vs_pe(struct ip_vs_pe *pe);
@@ -1371,17 +1370,15 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name);
 /*
  *	IPVS protocol functions (from ip_vs_proto.c)
  */
-extern int ip_vs_protocol_init(void);
-extern void ip_vs_protocol_cleanup(void);
-extern void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
-extern int *ip_vs_create_timeout_table(int *table, int size);
-extern int
-ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			const char *name, int to);
-extern void
-ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
-			  const struct sk_buff *skb,
-			  int offset, const char *msg);
+int ip_vs_protocol_init(void);
+void ip_vs_protocol_cleanup(void);
+void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
+int *ip_vs_create_timeout_table(int *table, int size);
+int ip_vs_set_state_timeout(int *table, int num, const char *const *names,
+			    const char *name, int to);
+void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
+			       const struct sk_buff *skb, int offset,
+			       const char *msg);
 
 extern struct ip_vs_protocol ip_vs_protocol_tcp;
 extern struct ip_vs_protocol ip_vs_protocol_udp;
@@ -1394,22 +1391,22 @@ extern struct ip_vs_protocol ip_vs_protocol_sctp;
  *      Registering/unregistering scheduler functions
  *      (from ip_vs_sched.c)
  */
-extern int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
-extern int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
-extern int ip_vs_bind_scheduler(struct ip_vs_service *svc,
-				struct ip_vs_scheduler *scheduler);
-extern void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
-				   struct ip_vs_scheduler *sched);
-extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
-extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
-extern struct ip_vs_conn *
+int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
+int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler);
+int ip_vs_bind_scheduler(struct ip_vs_service *svc,
+			 struct ip_vs_scheduler *scheduler);
+void ip_vs_unbind_scheduler(struct ip_vs_service *svc,
+			    struct ip_vs_scheduler *sched);
+struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
+void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
+struct ip_vs_conn *
 ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	       struct ip_vs_proto_data *pd, int *ignored,
 	       struct ip_vs_iphdr *iph);
-extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
-			struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
+int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
+		struct ip_vs_proto_data *pd, struct ip_vs_iphdr *iph);
 
-extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
+void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 
 
 /*
@@ -1418,25 +1415,24 @@ extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
 extern struct ip_vs_stats ip_vs_stats;
 extern int sysctl_ip_vs_sync_ver;
 
-extern struct ip_vs_service *
+struct ip_vs_service *
 ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
 
-extern bool
-ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
-		       const union nf_inet_addr *daddr, __be16 dport);
-
-extern int ip_vs_use_count_inc(void);
-extern void ip_vs_use_count_dec(void);
-extern int ip_vs_register_nl_ioctl(void);
-extern void ip_vs_unregister_nl_ioctl(void);
-extern int ip_vs_control_init(void);
-extern void ip_vs_control_cleanup(void);
-extern struct ip_vs_dest *
+bool ip_vs_has_real_service(struct net *net, int af, __u16 protocol,
+			    const union nf_inet_addr *daddr, __be16 dport);
+
+int ip_vs_use_count_inc(void);
+void ip_vs_use_count_dec(void);
+int ip_vs_register_nl_ioctl(void);
+void ip_vs_unregister_nl_ioctl(void);
+int ip_vs_control_init(void);
+void ip_vs_control_cleanup(void);
+struct ip_vs_dest *
 ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
 		__be16 dport, const union nf_inet_addr *vaddr, __be16 vport,
 		__u16 protocol, __u32 fwmark, __u32 flags);
-extern void ip_vs_try_bind_dest(struct ip_vs_conn *cp);
+void ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 static inline void ip_vs_dest_hold(struct ip_vs_dest *dest)
 {
@@ -1453,56 +1449,49 @@ static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
  *      IPVS sync daemon data and function prototypes
  *      (from ip_vs_sync.c)
  */
-extern int start_sync_thread(struct net *net, int state, char *mcast_ifn,
-			     __u8 syncid);
-extern int stop_sync_thread(struct net *net, int state);
-extern void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
-
+int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid);
+int stop_sync_thread(struct net *net, int state);
+void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp, int pkts);
 
 /*
  *      IPVS rate estimator prototypes (from ip_vs_est.c)
  */
-extern void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
-extern void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
-extern void ip_vs_zero_estimator(struct ip_vs_stats *stats);
-extern void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
-				 struct ip_vs_stats *stats);
+void ip_vs_start_estimator(struct net *net, struct ip_vs_stats *stats);
+void ip_vs_stop_estimator(struct net *net, struct ip_vs_stats *stats);
+void ip_vs_zero_estimator(struct ip_vs_stats *stats);
+void ip_vs_read_estimator(struct ip_vs_stats_user *dst,
+			  struct ip_vs_stats *stats);
 
 /*
  *	Various IPVS packet transmitters (from ip_vs_xmit.c)
  */
-extern int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
-extern int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			     struct ip_vs_protocol *pp,
-			     struct ip_vs_iphdr *iph);
-extern int ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
-extern int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			     struct ip_vs_protocol *pp,
-			     struct ip_vs_iphdr *iph);
-extern int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
-extern int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
-			   struct ip_vs_protocol *pp, int offset,
-			   unsigned int hooknum, struct ip_vs_iphdr *iph);
-extern void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
+int ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		   struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
+		    struct ip_vs_protocol *pp, int offset,
+		    unsigned int hooknum, struct ip_vs_iphdr *iph);
+void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
 
 #ifdef CONFIG_IP_VS_IPV6
-extern int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-				struct ip_vs_protocol *pp,
-				struct ip_vs_iphdr *iph);
-extern int ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			     struct ip_vs_protocol *pp,
-			     struct ip_vs_iphdr *iph);
-extern int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-				struct ip_vs_protocol *pp,
-				struct ip_vs_iphdr *iph);
-extern int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			    struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
-extern int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
-			      struct ip_vs_protocol *pp, int offset,
-			      unsigned int hooknum, struct ip_vs_iphdr *iph);
+int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		      struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+			 struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *iph);
+int ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+		       struct ip_vs_protocol *pp, int offset,
+		       unsigned int hooknum, struct ip_vs_iphdr *iph);
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -1551,15 +1540,15 @@ static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
 	return fwd;
 }
 
-extern void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
-			   struct ip_vs_conn *cp, int dir);
+void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		    struct ip_vs_conn *cp, int dir);
 
 #ifdef CONFIG_IP_VS_IPV6
-extern void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
-			      struct ip_vs_conn *cp, int dir);
+void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
+		       struct ip_vs_conn *cp, int dir);
 #endif
 
-extern __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
+__sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset);
 
 static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
 {
@@ -1618,13 +1607,13 @@ static inline int ip_vs_conntrack_enabled(struct netns_ipvs *ipvs)
 #endif
 }
 
-extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
-				   int outin);
-extern int ip_vs_confirm_conntrack(struct sk_buff *skb);
-extern void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
-				      struct ip_vs_conn *cp, u_int8_t proto,
-				      const __be16 port, int from_rs);
-extern void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp);
+void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
+			    int outin);
+int ip_vs_confirm_conntrack(struct sk_buff *skb);
+void ip_vs_nfct_expect_related(struct sk_buff *skb, struct nf_conn *ct,
+			       struct ip_vs_conn *cp, u_int8_t proto,
+			       const __be16 port, int from_rs);
+void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp);
 
 #else
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index bbf1c8f..fe1c7f6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -244,14 +244,14 @@ struct ipv6_fl_socklist {
 	struct rcu_head			rcu;
 };
 
-extern struct ip6_flowlabel	*fl6_sock_lookup(struct sock *sk, __be32 label);
-extern struct ipv6_txoptions	*fl6_merge_options(struct ipv6_txoptions * opt_space,
-						   struct ip6_flowlabel * fl,
-						   struct ipv6_txoptions * fopt);
-extern void			fl6_free_socklist(struct sock *sk);
-extern int			ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
-extern int			ip6_flowlabel_init(void);
-extern void			ip6_flowlabel_cleanup(void);
+struct ip6_flowlabel *fl6_sock_lookup(struct sock *sk, __be32 label);
+struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
+					 struct ip6_flowlabel *fl,
+					 struct ipv6_txoptions *fopt);
+void fl6_free_socklist(struct sock *sk);
+int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
+int ip6_flowlabel_init(void);
+void ip6_flowlabel_cleanup(void);
 
 static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 {
@@ -259,7 +259,7 @@ static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 		atomic_dec(&fl->users);
 }
 
-extern void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info);
+void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info);
 
 int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 			       struct icmp6hdr *thdr, int len);
@@ -267,19 +267,21 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
 				      struct sock *sk, struct flowi6 *fl6);
 
-extern int 			ip6_ra_control(struct sock *sk, int sel);
+int ip6_ra_control(struct sock *sk, int sel);
 
-extern int			ipv6_parse_hopopts(struct sk_buff *skb);
+int ipv6_parse_hopopts(struct sk_buff *skb);
 
-extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
-extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
-						   int newtype,
-						   struct ipv6_opt_hdr __user *newopt,
-						   int newoptlen);
+struct ipv6_txoptions *ipv6_dup_options(struct sock *sk,
+					struct ipv6_txoptions *opt);
+struct ipv6_txoptions *ipv6_renew_options(struct sock *sk,
+					  struct ipv6_txoptions *opt,
+					  int newtype,
+					  struct ipv6_opt_hdr __user *newopt,
+					  int newoptlen);
 struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 					  struct ipv6_txoptions *opt);
 
-extern bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
+bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
 
 static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 {
@@ -306,7 +308,7 @@ static inline int ip6_frag_mem(struct net *net)
 #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
 #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
 
-extern int __ipv6_addr_type(const struct in6_addr *addr);
+int __ipv6_addr_type(const struct in6_addr *addr);
 static inline int ipv6_addr_type(const struct in6_addr *addr)
 {
 	return __ipv6_addr_type(addr) & 0xffff;
@@ -656,9 +658,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
+void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 
-extern int ip6_dst_hoplimit(struct dst_entry *dst);
+int ip6_dst_hoplimit(struct dst_entry *dst);
 
 /*
  *	Header manipulation
@@ -682,83 +684,65 @@ static inline __be32 ip6_flowinfo(const struct ipv6hdr *hdr)
  *	rcv function (called from netdevice level)
  */
 
-extern int			ipv6_rcv(struct sk_buff *skb, 
-					 struct net_device *dev, 
-					 struct packet_type *pt,
-					 struct net_device *orig_dev);
+int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
+	     struct packet_type *pt, struct net_device *orig_dev);
 
-extern int			ip6_rcv_finish(struct sk_buff *skb);
+int ip6_rcv_finish(struct sk_buff *skb);
 
 /*
  *	upper-layer output functions
  */
-extern int			ip6_xmit(struct sock *sk,
-					 struct sk_buff *skb,
-					 struct flowi6 *fl6,
-					 struct ipv6_txoptions *opt,
-					 int tclass);
-
-extern int			ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
-
-extern int			ip6_append_data(struct sock *sk,
-						int getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb),
-		    				void *from,
-						int length,
-						int transhdrlen,
-		      				int hlimit,
-		      				int tclass,
-						struct ipv6_txoptions *opt,
-						struct flowi6 *fl6,
-						struct rt6_info *rt,
-						unsigned int flags,
-						int dontfrag);
-
-extern int			ip6_push_pending_frames(struct sock *sk);
-
-extern void			ip6_flush_pending_frames(struct sock *sk);
-
-extern int			ip6_dst_lookup(struct sock *sk,
-					       struct dst_entry **dst,
-					       struct flowi6 *fl6);
-extern struct dst_entry *	ip6_dst_lookup_flow(struct sock *sk,
-						    struct flowi6 *fl6,
-						    const struct in6_addr *final_dst,
-						    bool can_sleep);
-extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
-						       struct flowi6 *fl6,
-						       const struct in6_addr *final_dst,
-						       bool can_sleep);
-extern struct dst_entry *	ip6_blackhole_route(struct net *net,
-						    struct dst_entry *orig_dst);
+int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
+	     struct ipv6_txoptions *opt, int tclass);
+
+int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
+
+int ip6_append_data(struct sock *sk,
+		    int getfrag(void *from, char *to, int offset, int len,
+				int odd, struct sk_buff *skb),
+		    void *from, int length, int transhdrlen, int hlimit,
+		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
+		    struct rt6_info *rt, unsigned int flags, int dontfrag);
+
+int ip6_push_pending_frames(struct sock *sk);
+
+void ip6_flush_pending_frames(struct sock *sk);
+
+int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6);
+struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
+				      const struct in6_addr *final_dst,
+				      bool can_sleep);
+struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
+					 const struct in6_addr *final_dst,
+					 bool can_sleep);
+struct dst_entry *ip6_blackhole_route(struct net *net,
+				      struct dst_entry *orig_dst);
 
 /*
  *	skb processing functions
  */
 
-extern int			ip6_output(struct sk_buff *skb);
-extern int			ip6_forward(struct sk_buff *skb);
-extern int			ip6_input(struct sk_buff *skb);
-extern int			ip6_mc_input(struct sk_buff *skb);
+int ip6_output(struct sk_buff *skb);
+int ip6_forward(struct sk_buff *skb);
+int ip6_input(struct sk_buff *skb);
+int ip6_mc_input(struct sk_buff *skb);
 
-extern int			__ip6_local_out(struct sk_buff *skb);
-extern int			ip6_local_out(struct sk_buff *skb);
+int __ip6_local_out(struct sk_buff *skb);
+int ip6_local_out(struct sk_buff *skb);
 
 /*
  *	Extension header (options) processing
  */
 
-extern void 			ipv6_push_nfrag_opts(struct sk_buff *skb,
-						     struct ipv6_txoptions *opt,
-						     u8 *proto,
-						     struct in6_addr **daddr_p);
-extern void			ipv6_push_frag_opts(struct sk_buff *skb,
-						    struct ipv6_txoptions *opt,
-						    u8 *proto);
+void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
+			  u8 *proto, struct in6_addr **daddr_p);
+void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
+			 u8 *proto);
 
-extern int			ipv6_skip_exthdr(const struct sk_buff *, int start,
-					         u8 *nexthdrp, __be16 *frag_offp);
+int ipv6_skip_exthdr(const struct sk_buff *, int start, u8 *nexthdrp,
+		     __be16 *frag_offp);
 
-extern bool			ipv6_ext_hdr(u8 nexthdr);
+bool ipv6_ext_hdr(u8 nexthdr);
 
 enum {
 	IP6_FH_F_FRAG		= (1 << 0),
@@ -767,57 +751,44 @@ enum {
 };
 
 /* find specified header and get offset to it */
-extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-			 int target, unsigned short *fragoff, int *fragflg);
+int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset, int target,
+		  unsigned short *fragoff, int *fragflg);
 
-extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
+int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
-extern struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
-				       const struct ipv6_txoptions *opt,
-				       struct in6_addr *orig);
+struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
+				const struct ipv6_txoptions *opt,
+				struct in6_addr *orig);
 
 /*
  *	socket options (ipv6_sockglue.c)
  */
 
-extern int			ipv6_setsockopt(struct sock *sk, int level, 
-						int optname,
-						char __user *optval, 
-						unsigned int optlen);
-extern int			ipv6_getsockopt(struct sock *sk, int level, 
-						int optname,
-						char __user *optval, 
-						int __user *optlen);
-extern int			compat_ipv6_setsockopt(struct sock *sk,
-						int level,
-						int optname,
-						char __user *optval,
-						unsigned int optlen);
-extern int			compat_ipv6_getsockopt(struct sock *sk,
-						int level,
-						int optname,
-						char __user *optval,
-						int __user *optlen);
-
-extern int			ip6_datagram_connect(struct sock *sk, 
-						     struct sockaddr *addr, int addr_len);
-
-extern int 			ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
-extern int 			ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len);
-extern void			ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
-						u32 info, u8 *payload);
-extern void			ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info);
-extern void			ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu);
-
-extern int inet6_release(struct socket *sock);
-extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr, 
-		      int addr_len);
-extern int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
-			 int *uaddr_len, int peer);
-extern int inet6_ioctl(struct socket *sock, unsigned int cmd, 
-		       unsigned long arg);
-
-extern int inet6_hash_connect(struct inet_timewait_death_row *death_row,
+int ipv6_setsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, unsigned int optlen);
+int ipv6_getsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user *optlen);
+int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, unsigned int optlen);
+int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, int __user *optlen);
+
+int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
+
+int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len);
+int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len);
+void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
+		     u32 info, u8 *payload);
+void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info);
+void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu);
+
+int inet6_release(struct socket *sock);
+int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
+int inet6_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
+		  int peer);
+int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+
+int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 			      struct sock *sk);
 
 /*
@@ -829,30 +800,29 @@ extern const struct proto_ops inet6_dgram_ops;
 struct group_source_req;
 struct group_filter;
 
-extern int ip6_mc_source(int add, int omode, struct sock *sk,
-			 struct group_source_req *pgsr);
-extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
-extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
-			 struct group_filter __user *optval,
-			 int __user *optlen);
-extern unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
-				    const struct in6_addr *daddr, u32 rnd);
+int ip6_mc_source(int add, int omode, struct sock *sk,
+		  struct group_source_req *pgsr);
+int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
+int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
+		  struct group_filter __user *optval, int __user *optlen);
+unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+			     const struct in6_addr *daddr, u32 rnd);
 
 #ifdef CONFIG_PROC_FS
-extern int  ac6_proc_init(struct net *net);
-extern void ac6_proc_exit(struct net *net);
-extern int  raw6_proc_init(void);
-extern void raw6_proc_exit(void);
-extern int  tcp6_proc_init(struct net *net);
-extern void tcp6_proc_exit(struct net *net);
-extern int  udp6_proc_init(struct net *net);
-extern void udp6_proc_exit(struct net *net);
-extern int  udplite6_proc_init(void);
-extern void udplite6_proc_exit(void);
-extern int  ipv6_misc_proc_init(void);
-extern void ipv6_misc_proc_exit(void);
-extern int snmp6_register_dev(struct inet6_dev *idev);
-extern int snmp6_unregister_dev(struct inet6_dev *idev);
+int ac6_proc_init(struct net *net);
+void ac6_proc_exit(struct net *net);
+int raw6_proc_init(void);
+void raw6_proc_exit(void);
+int tcp6_proc_init(struct net *net);
+void tcp6_proc_exit(struct net *net);
+int udp6_proc_init(struct net *net);
+void udp6_proc_exit(struct net *net);
+int udplite6_proc_init(void);
+void udplite6_proc_exit(void);
+int ipv6_misc_proc_init(void);
+void ipv6_misc_proc_exit(void);
+int snmp6_register_dev(struct inet6_dev *idev);
+int snmp6_unregister_dev(struct inet6_dev *idev);
 
 #else
 static inline int ac6_proc_init(struct net *net) { return 0; }
@@ -865,10 +835,10 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 extern struct ctl_table ipv6_route_table_template[];
 extern struct ctl_table ipv6_icmp_table_template[];
 
-extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-extern int ipv6_sysctl_register(void);
-extern void ipv6_sysctl_unregister(void);
+struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
+struct ctl_table *ipv6_route_sysctl_init(struct net *net);
+int ipv6_sysctl_register(void);
+void ipv6_sysctl_unregister(void);
 #endif
 
 #endif /* _NET_IPV6_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
