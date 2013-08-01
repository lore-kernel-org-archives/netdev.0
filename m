From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/8] addrconf.h: Remove extern function prototypes
Date: Wed, 31 Jul 2013 17:31:32 -0700
Message-ID: <6333b83215520a6db1f68f1930b047d08548777a.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/addrconf.h | 160 ++++++++++++++++++++++---------------------------
 1 file changed, 72 insertions(+), 88 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index c7b181c..43fa31a 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -53,51 +53,36 @@ struct prefix_info {
 #define IN6_ADDR_HSIZE_SHIFT	4
 #define IN6_ADDR_HSIZE		(1 << IN6_ADDR_HSIZE_SHIFT)
 
-extern int			addrconf_init(void);
-extern void			addrconf_cleanup(void);
+int addrconf_init(void);
+void addrconf_cleanup(void);
 
-extern int			addrconf_add_ifaddr(struct net *net,
-						    void __user *arg);
-extern int			addrconf_del_ifaddr(struct net *net,
-						    void __user *arg);
-extern int			addrconf_set_dstaddr(struct net *net,
-						     void __user *arg);
+int addrconf_add_ifaddr(struct net *net, void __user *arg);
+int addrconf_del_ifaddr(struct net *net, void __user *arg);
+int addrconf_set_dstaddr(struct net *net, void __user *arg);
 
-extern int			ipv6_chk_addr(struct net *net,
-					      const struct in6_addr *addr,
-					      const struct net_device *dev,
-					      int strict);
+int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
+		  const struct net_device *dev, int strict);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-extern int			ipv6_chk_home_addr(struct net *net,
-						   const struct in6_addr *addr);
+int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
 #endif
 
-extern int			ipv6_chk_prefix(const struct in6_addr *addr,
-						struct net_device *dev);
-
-extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
-						 const struct in6_addr *addr,
-						 struct net_device *dev,
-						 int strict);
-
-extern int			ipv6_dev_get_saddr(struct net *net,
-					       const struct net_device *dev,
-					       const struct in6_addr *daddr,
-					       unsigned int srcprefs,
-					       struct in6_addr *saddr);
-extern int			__ipv6_get_lladdr(struct inet6_dev *idev,
-						  struct in6_addr *addr,
-						  unsigned char banned_flags);
-extern int			ipv6_get_lladdr(struct net_device *dev,
-						struct in6_addr *addr,
-						unsigned char banned_flags);
-extern int 			ipv6_rcv_saddr_equal(const struct sock *sk,
-						    const struct sock *sk2);
-extern void			addrconf_join_solict(struct net_device *dev,
-					const struct in6_addr *addr);
-extern void			addrconf_leave_solict(struct inet6_dev *idev,
-					const struct in6_addr *addr);
+int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev);
+
+struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
+				     const struct in6_addr *addr,
+				     struct net_device *dev, int strict);
+
+int ipv6_dev_get_saddr(struct net *net, const struct net_device *dev,
+		       const struct in6_addr *daddr, unsigned int srcprefs,
+		       struct in6_addr *saddr);
+int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
+		      unsigned char banned_flags);
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
+		    unsigned char banned_flags);
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2);
+void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
+void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 
 static inline unsigned long addrconf_timeout_fixup(u32 timeout,
 						   unsigned int unit)
@@ -124,41 +109,38 @@ static inline int addrconf_finite_timeout(unsigned long timeout)
 /*
  *	IPv6 Address Label subsystem (addrlabel.c)
  */
-extern int			ipv6_addr_label_init(void);
-extern void			ipv6_addr_label_cleanup(void);
-extern void			ipv6_addr_label_rtnl_register(void);
-extern u32			ipv6_addr_label(struct net *net,
-						const struct in6_addr *addr,
-						int type, int ifindex);
+int ipv6_addr_label_init(void);
+void ipv6_addr_label_cleanup(void);
+void ipv6_addr_label_rtnl_register(void);
+u32 ipv6_addr_label(struct net *net, const struct in6_addr *addr,
+		    int type, int ifindex);
 
 /*
  *	multicast prototypes (mcast.c)
  */
-extern int ipv6_sock_mc_join(struct sock *sk, int ifindex,
-			     const struct in6_addr *addr);
-extern int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
-			     const struct in6_addr *addr);
-extern void ipv6_sock_mc_close(struct sock *sk);
-extern bool inet6_mc_check(struct sock *sk,
-			   const struct in6_addr *mc_addr,
-			   const struct in6_addr *src_addr);
-
-extern int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr);
-extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr);
-extern int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr);
-extern void ipv6_mc_up(struct inet6_dev *idev);
-extern void ipv6_mc_down(struct inet6_dev *idev);
-extern void ipv6_mc_unmap(struct inet6_dev *idev);
-extern void ipv6_mc_remap(struct inet6_dev *idev);
-extern void ipv6_mc_init_dev(struct inet6_dev *idev);
-extern void ipv6_mc_destroy_dev(struct inet6_dev *idev);
-extern void addrconf_dad_failure(struct inet6_ifaddr *ifp);
-
-extern bool ipv6_chk_mcast_addr(struct net_device *dev,
-				const struct in6_addr *group,
-				const struct in6_addr *src_addr);
-
-extern void ipv6_mc_dad_complete(struct inet6_dev *idev);
+int ipv6_sock_mc_join(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+void ipv6_sock_mc_close(struct sock *sk);
+bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
+		    const struct in6_addr *src_addr);
+
+int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr);
+int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr);
+int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr);
+void ipv6_mc_up(struct inet6_dev *idev);
+void ipv6_mc_down(struct inet6_dev *idev);
+void ipv6_mc_unmap(struct inet6_dev *idev);
+void ipv6_mc_remap(struct inet6_dev *idev);
+void ipv6_mc_init_dev(struct inet6_dev *idev);
+void ipv6_mc_destroy_dev(struct inet6_dev *idev);
+void addrconf_dad_failure(struct inet6_ifaddr *ifp);
+
+bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
+			 const struct in6_addr *src_addr);
+
+void ipv6_mc_dad_complete(struct inet6_dev *idev);
 /*
  * identify MLD packets for MLD filter exceptions
  */
@@ -184,29 +166,31 @@ static inline bool ipv6_is_mld(struct sk_buff *skb, int nexthdr, int offset)
 	return false;
 }
 
-extern void addrconf_prefix_rcv(struct net_device *dev,
-				u8 *opt, int len, bool sllao);
+void addrconf_prefix_rcv(struct net_device *dev,
+			 u8 *opt, int len, bool sllao);
 
 /*
  *	anycast prototypes (anycast.c)
  */
-extern int ipv6_sock_ac_join(struct sock *sk,int ifindex, const struct in6_addr *addr);
-extern int ipv6_sock_ac_drop(struct sock *sk,int ifindex, const struct in6_addr *addr);
-extern void ipv6_sock_ac_close(struct sock *sk);
-
-extern int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
-extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
-extern bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+int ipv6_sock_ac_join(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+int ipv6_sock_ac_drop(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+void ipv6_sock_ac_close(struct sock *sk);
+
+int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
+int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
+bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 				const struct in6_addr *addr);
 
 
 /* Device notifier */
-extern int register_inet6addr_notifier(struct notifier_block *nb);
-extern int unregister_inet6addr_notifier(struct notifier_block *nb);
-extern int inet6addr_notifier_call_chain(unsigned long val, void *v);
+int register_inet6addr_notifier(struct notifier_block *nb);
+int unregister_inet6addr_notifier(struct notifier_block *nb);
+int inet6addr_notifier_call_chain(unsigned long val, void *v);
 
-extern void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
-					 struct ipv6_devconf *devconf);
+void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
+				  struct ipv6_devconf *devconf);
 
 /**
  * __in6_dev_get - get inet6_dev pointer from netdevice
@@ -240,7 +224,7 @@ static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
 	return idev;
 }
 
-extern void in6_dev_finish_destroy(struct inet6_dev *idev);
+void in6_dev_finish_destroy(struct inet6_dev *idev);
 
 static inline void in6_dev_put(struct inet6_dev *idev)
 {
@@ -258,7 +242,7 @@ static inline void in6_dev_hold(struct inet6_dev *idev)
 	atomic_inc(&idev->refcnt);
 }
 
-extern void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp);
+void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp);
 
 static inline void in6_ifa_put(struct inet6_ifaddr *ifp)
 {
@@ -340,8 +324,8 @@ static inline bool ipv6_addr_is_solict_mult(const struct in6_addr *addr)
 }
 
 #ifdef CONFIG_PROC_FS
-extern int if6_proc_init(void);
-extern void if6_proc_exit(void);
+int if6_proc_init(void);
+void if6_proc_exit(void);
 #endif
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
