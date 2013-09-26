From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] [networking]device.h: Remove extern from function prototypes
Date: Thu, 26 Sep 2013 15:18:33 -0700
Message-ID: <f629d208d27a22f495b7734eede585b5d207e912.1380233637.git.joe@perches.com>
References: <cover.1380233637.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jes Sorensen <jes@trained-monkey.org>,
	linux-kernel@vger.kernel.org, linux-hippi@sunsite.dk
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
 include/linux/etherdevice.h |  35 ++--
 include/linux/fcdevice.h    |   2 +-
 include/linux/fddidevice.h  |   7 +-
 include/linux/hippidevice.h |  10 +-
 include/linux/inetdevice.h  |  28 +--
 include/linux/netdevice.h   | 432 +++++++++++++++++++++-----------------------
 6 files changed, 248 insertions(+), 266 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index d8b5124..fc4a9aa 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -28,27 +28,24 @@
 #include <asm/unaligned.h>
 
 #ifdef __KERNEL__
-extern __be16		eth_type_trans(struct sk_buff *skb, struct net_device *dev);
+__be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev);
 extern const struct header_ops eth_header_ops;
 
-extern int eth_header(struct sk_buff *skb, struct net_device *dev,
-		      unsigned short type,
-		      const void *daddr, const void *saddr, unsigned len);
-extern int eth_rebuild_header(struct sk_buff *skb);
-extern int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
-extern int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type);
-extern void eth_header_cache_update(struct hh_cache *hh,
-				    const struct net_device *dev,
-				    const unsigned char *haddr);
-extern int eth_prepare_mac_addr_change(struct net_device *dev, void *p);
-extern void eth_commit_mac_addr_change(struct net_device *dev, void *p);
-extern int eth_mac_addr(struct net_device *dev, void *p);
-extern int eth_change_mtu(struct net_device *dev, int new_mtu);
-extern int eth_validate_addr(struct net_device *dev);
-
-
-
-extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
+int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
+	       const void *daddr, const void *saddr, unsigned len);
+int eth_rebuild_header(struct sk_buff *skb);
+int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
+int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh,
+		     __be16 type);
+void eth_header_cache_update(struct hh_cache *hh, const struct net_device *dev,
+			     const unsigned char *haddr);
+int eth_prepare_mac_addr_change(struct net_device *dev, void *p);
+void eth_commit_mac_addr_change(struct net_device *dev, void *p);
+int eth_mac_addr(struct net_device *dev, void *p);
+int eth_change_mtu(struct net_device *dev, int new_mtu);
+int eth_validate_addr(struct net_device *dev);
+
+struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 					    unsigned int rxqs);
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
 #define alloc_etherdev_mq(sizeof_priv, count) alloc_etherdev_mqs(sizeof_priv, count, count)
diff --git a/include/linux/fcdevice.h b/include/linux/fcdevice.h
index e460ef8..5009fa1 100644
--- a/include/linux/fcdevice.h
+++ b/include/linux/fcdevice.h
@@ -27,7 +27,7 @@
 #include <linux/if_fc.h>
 
 #ifdef __KERNEL__
-extern struct net_device *alloc_fcdev(int sizeof_priv);
+struct net_device *alloc_fcdev(int sizeof_priv);
 #endif
 
 #endif	/* _LINUX_FCDEVICE_H */
diff --git a/include/linux/fddidevice.h b/include/linux/fddidevice.h
index 155bafd..9a79f01 100644
--- a/include/linux/fddidevice.h
+++ b/include/linux/fddidevice.h
@@ -25,10 +25,9 @@
 #include <linux/if_fddi.h>
 
 #ifdef __KERNEL__
-extern __be16	fddi_type_trans(struct sk_buff *skb,
-				struct net_device *dev);
-extern int fddi_change_mtu(struct net_device *dev, int new_mtu);
-extern struct net_device *alloc_fddidev(int sizeof_priv);
+__be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev);
+int fddi_change_mtu(struct net_device *dev, int new_mtu);
+struct net_device *alloc_fddidev(int sizeof_priv);
 #endif
 
 #endif	/* _LINUX_FDDIDEVICE_H */
diff --git a/include/linux/hippidevice.h b/include/linux/hippidevice.h
index f148e49..8ec23fb 100644
--- a/include/linux/hippidevice.h
+++ b/include/linux/hippidevice.h
@@ -31,11 +31,11 @@ struct hippi_cb {
 	__u32	ifield;
 };
 
-extern __be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev);
-extern int hippi_change_mtu(struct net_device *dev, int new_mtu);
-extern int hippi_mac_addr(struct net_device *dev, void *p);
-extern int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p);
-extern struct net_device *alloc_hippi_dev(int sizeof_priv);
+__be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev);
+int hippi_change_mtu(struct net_device *dev, int new_mtu);
+int hippi_mac_addr(struct net_device *dev, void *p);
+int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p);
+struct net_device *alloc_hippi_dev(int sizeof_priv);
 #endif
 
 #endif	/* _LINUX_HIPPIDEVICE_H */
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 79640e0..0d678ae 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -147,25 +147,27 @@ struct in_ifaddr {
 	unsigned long		ifa_tstamp; /* updated timestamp */
 };
 
-extern int register_inetaddr_notifier(struct notifier_block *nb);
-extern int unregister_inetaddr_notifier(struct notifier_block *nb);
+int register_inetaddr_notifier(struct notifier_block *nb);
+int unregister_inetaddr_notifier(struct notifier_block *nb);
 
-extern void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
-					struct ipv4_devconf *devconf);
+void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
+				 struct ipv4_devconf *devconf);
 
-extern struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
+struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
 {
 	return __ip_dev_find(net, addr, true);
 }
 
-extern int		inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
-extern int		devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
-extern void		devinet_init(void);
-extern struct in_device	*inetdev_by_index(struct net *, int);
-extern __be32		inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
-extern __be32		inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local, int scope);
-extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix, __be32 mask);
+int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
+int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
+void devinet_init(void);
+struct in_device *inetdev_by_index(struct net *, int);
+__be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
+__be32 inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local,
+			 int scope);
+struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
+				    __be32 mask);
 
 static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
@@ -218,7 +220,7 @@ static inline struct in_device *__in_dev_get_rtnl(const struct net_device *dev)
 	return rtnl_dereference(dev->ip_ptr);
 }
 
-extern void in_dev_finish_destroy(struct in_device *idev);
+void in_dev_finish_destroy(struct in_device *idev);
 
 static inline void in_dev_put(struct in_device *idev)
 {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b4cfb63..5f01af3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,8 +60,8 @@ struct wireless_dev;
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
 
-extern void netdev_set_default_ethtool_ops(struct net_device *dev,
-					   const struct ethtool_ops *ops);
+void netdev_set_default_ethtool_ops(struct net_device *dev,
+				    const struct ethtool_ops *ops);
 
 /* hardware address assignment types */
 #define NET_ADDR_PERM		0	/* address is permanent (default) */
@@ -298,7 +298,7 @@ struct netdev_boot_setup {
 };
 #define NETDEV_BOOT_SETUP_MAX 8
 
-extern int __init netdev_boot_setup(char *str);
+int __init netdev_boot_setup(char *str);
 
 /*
  * Structure for NAPI scheduling similar to tasklet but with weighting
@@ -394,7 +394,7 @@ enum rx_handler_result {
 typedef enum rx_handler_result rx_handler_result_t;
 typedef rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
 
-extern void __napi_schedule(struct napi_struct *n);
+void __napi_schedule(struct napi_struct *n);
 
 static inline bool napi_disable_pending(struct napi_struct *n)
 {
@@ -445,8 +445,8 @@ static inline bool napi_reschedule(struct napi_struct *napi)
  *
  * Mark NAPI processing as complete.
  */
-extern void __napi_complete(struct napi_struct *n);
-extern void napi_complete(struct napi_struct *n);
+void __napi_complete(struct napi_struct *n);
+void napi_complete(struct napi_struct *n);
 
 /**
  *	napi_by_id - lookup a NAPI by napi_id
@@ -455,7 +455,7 @@ extern void napi_complete(struct napi_struct *n);
  * lookup @napi_id in napi_hash table
  * must be called under rcu_read_lock()
  */
-extern struct napi_struct *napi_by_id(unsigned int napi_id);
+struct napi_struct *napi_by_id(unsigned int napi_id);
 
 /**
  *	napi_hash_add - add a NAPI to global hashtable
@@ -463,7 +463,7 @@ extern struct napi_struct *napi_by_id(unsigned int napi_id);
  *
  * generate a new napi_id and store a @napi under it in napi_hash
  */
-extern void napi_hash_add(struct napi_struct *napi);
+void napi_hash_add(struct napi_struct *napi);
 
 /**
  *	napi_hash_del - remove a NAPI from global table
@@ -472,7 +472,7 @@ extern void napi_hash_add(struct napi_struct *napi);
  * Warning: caller must observe rcu grace period
  * before freeing memory containing @napi
  */
-extern void napi_hash_del(struct napi_struct *napi);
+void napi_hash_del(struct napi_struct *napi);
 
 /**
  *	napi_disable - prevent NAPI from scheduling
@@ -664,8 +664,8 @@ static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
 extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
 
 #ifdef CONFIG_RFS_ACCEL
-extern bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
-				u32 flow_id, u16 filter_id);
+bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index, u32 flow_id,
+			 u16 filter_id);
 #endif
 
 /* This structure contains an instance of an RX queue. */
@@ -1497,9 +1497,9 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
-extern struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-					   struct sk_buff *skb);
-extern u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb);
+struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+				    struct sk_buff *skb);
+u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb);
 
 /*
  * Net namespace inlines
@@ -1683,8 +1683,8 @@ struct packet_offload {
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
 
-extern int register_netdevice_notifier(struct notifier_block *nb);
-extern int unregister_netdevice_notifier(struct notifier_block *nb);
+int register_netdevice_notifier(struct notifier_block *nb);
+int unregister_netdevice_notifier(struct notifier_block *nb);
 
 struct netdev_notifier_info {
 	struct net_device *dev;
@@ -1707,9 +1707,9 @@ netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
 	return info->dev;
 }
 
-extern int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
-					 struct netdev_notifier_info *info);
-extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
+int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
+				  struct netdev_notifier_info *info);
+int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
@@ -1764,54 +1764,52 @@ static inline struct net_device *first_net_device_rcu(struct net *net)
 	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
 }
 
-extern int 			netdev_boot_setup_check(struct net_device *dev);
-extern unsigned long		netdev_boot_base(const char *prefix, int unit);
-extern struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short type,
-					      const char *hwaddr);
-extern struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type);
-extern struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type);
-extern void		dev_add_pack(struct packet_type *pt);
-extern void		dev_remove_pack(struct packet_type *pt);
-extern void		__dev_remove_pack(struct packet_type *pt);
-extern void		dev_add_offload(struct packet_offload *po);
-extern void		dev_remove_offload(struct packet_offload *po);
-extern void		__dev_remove_offload(struct packet_offload *po);
-
-extern struct net_device	*dev_get_by_flags_rcu(struct net *net, unsigned short flags,
-						      unsigned short mask);
-extern struct net_device	*dev_get_by_name(struct net *net, const char *name);
-extern struct net_device	*dev_get_by_name_rcu(struct net *net, const char *name);
-extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
-extern int		dev_alloc_name(struct net_device *dev, const char *name);
-extern int		dev_open(struct net_device *dev);
-extern int		dev_close(struct net_device *dev);
-extern void		dev_disable_lro(struct net_device *dev);
-extern int		dev_loopback_xmit(struct sk_buff *newskb);
-extern int		dev_queue_xmit(struct sk_buff *skb);
-extern int		register_netdevice(struct net_device *dev);
-extern void		unregister_netdevice_queue(struct net_device *dev,
-						   struct list_head *head);
-extern void		unregister_netdevice_many(struct list_head *head);
+int netdev_boot_setup_check(struct net_device *dev);
+unsigned long netdev_boot_base(const char *prefix, int unit);
+struct net_device *dev_getbyhwaddr_rcu(struct net *net, unsigned short type,
+				       const char *hwaddr);
+struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type);
+struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type);
+void dev_add_pack(struct packet_type *pt);
+void dev_remove_pack(struct packet_type *pt);
+void __dev_remove_pack(struct packet_type *pt);
+void dev_add_offload(struct packet_offload *po);
+void dev_remove_offload(struct packet_offload *po);
+void __dev_remove_offload(struct packet_offload *po);
+
+struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short flags,
+					unsigned short mask);
+struct net_device *dev_get_by_name(struct net *net, const char *name);
+struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
+struct net_device *__dev_get_by_name(struct net *net, const char *name);
+int dev_alloc_name(struct net_device *dev, const char *name);
+int dev_open(struct net_device *dev);
+int dev_close(struct net_device *dev);
+void dev_disable_lro(struct net_device *dev);
+int dev_loopback_xmit(struct sk_buff *newskb);
+int dev_queue_xmit(struct sk_buff *skb);
+int register_netdevice(struct net_device *dev);
+void unregister_netdevice_queue(struct net_device *dev, struct list_head *head);
+void unregister_netdevice_many(struct list_head *head);
 static inline void unregister_netdevice(struct net_device *dev)
 {
 	unregister_netdevice_queue(dev, NULL);
 }
 
-extern int 		netdev_refcnt_read(const struct net_device *dev);
-extern void		free_netdev(struct net_device *dev);
-extern void		synchronize_net(void);
-extern int		init_dummy_netdev(struct net_device *dev);
+int netdev_refcnt_read(const struct net_device *dev);
+void free_netdev(struct net_device *dev);
+void synchronize_net(void);
+int init_dummy_netdev(struct net_device *dev);
 
-extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
-extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
-extern struct net_device	*dev_get_by_index_rcu(struct net *net, int ifindex);
-extern int		netdev_get_name(struct net *net, char *name, int ifindex);
-extern int		dev_restart(struct net_device *dev);
+struct net_device *dev_get_by_index(struct net *net, int ifindex);
+struct net_device *__dev_get_by_index(struct net *net, int ifindex);
+struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
+int netdev_get_name(struct net *net, char *name, int ifindex);
+int dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
-extern int		netpoll_trap(void);
+int netpoll_trap(void);
 #endif
-extern int	       skb_gro_receive(struct sk_buff **head,
-				       struct sk_buff *skb);
+int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb);
 
 static inline unsigned int skb_gro_offset(const struct sk_buff *skb)
 {
@@ -1883,7 +1881,7 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 }
 
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
-extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
+int register_gifconf(unsigned int family, gifconf_func_t *gifconf);
 static inline int unregister_gifconf(unsigned int family)
 {
 	return register_gifconf(family, NULL);
@@ -1954,7 +1952,7 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
-extern void __netif_schedule(struct Qdisc *q);
+void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
 {
@@ -2274,8 +2272,8 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 }
 
 #ifdef CONFIG_XPS
-extern int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
-			       u16 index);
+int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask,
+			u16 index);
 #else
 static inline int netif_set_xps_queue(struct net_device *dev,
 				      struct cpumask *mask,
@@ -2306,12 +2304,10 @@ static inline bool netif_is_multiqueue(const struct net_device *dev)
 	return dev->num_tx_queues > 1;
 }
 
-extern int netif_set_real_num_tx_queues(struct net_device *dev,
-					unsigned int txq);
+int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq);
 
 #ifdef CONFIG_RPS
-extern int netif_set_real_num_rx_queues(struct net_device *dev,
-					unsigned int rxq);
+int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq);
 #else
 static inline int netif_set_real_num_rx_queues(struct net_device *dev,
 						unsigned int rxq)
@@ -2338,28 +2334,27 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 }
 
 #define DEFAULT_MAX_NUM_RSS_QUEUES	(8)
-extern int netif_get_num_default_rss_queues(void);
+int netif_get_num_default_rss_queues(void);
 
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts
  * disabled.
  */
-extern void dev_kfree_skb_irq(struct sk_buff *skb);
+void dev_kfree_skb_irq(struct sk_buff *skb);
 
 /* Use this variant in places where it could be invoked
  * from either hardware interrupt or other context, with hardware interrupts
  * either disabled or enabled.
  */
-extern void dev_kfree_skb_any(struct sk_buff *skb);
+void dev_kfree_skb_any(struct sk_buff *skb);
 
-extern int		netif_rx(struct sk_buff *skb);
-extern int		netif_rx_ni(struct sk_buff *skb);
-extern int		netif_receive_skb(struct sk_buff *skb);
-extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
-					 struct sk_buff *skb);
-extern void		napi_gro_flush(struct napi_struct *napi, bool flush_old);
-extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
-extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
+int netif_rx(struct sk_buff *skb);
+int netif_rx_ni(struct sk_buff *skb);
+int netif_receive_skb(struct sk_buff *skb);
+gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
+void napi_gro_flush(struct napi_struct *napi, bool flush_old);
+struct sk_buff *napi_get_frags(struct napi_struct *napi);
+gro_result_t napi_gro_frags(struct napi_struct *napi);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
@@ -2367,40 +2362,35 @@ static inline void napi_free_frags(struct napi_struct *napi)
 	napi->skb = NULL;
 }
 
-extern int netdev_rx_handler_register(struct net_device *dev,
-				      rx_handler_func_t *rx_handler,
-				      void *rx_handler_data);
-extern void netdev_rx_handler_unregister(struct net_device *dev);
-
-extern bool		dev_valid_name(const char *name);
-extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
-extern int		dev_ethtool(struct net *net, struct ifreq *);
-extern unsigned int	dev_get_flags(const struct net_device *);
-extern int		__dev_change_flags(struct net_device *, unsigned int flags);
-extern int		dev_change_flags(struct net_device *, unsigned int);
-extern void		__dev_notify_flags(struct net_device *, unsigned int old_flags);
-extern int		dev_change_name(struct net_device *, const char *);
-extern int		dev_set_alias(struct net_device *, const char *, size_t);
-extern int		dev_change_net_namespace(struct net_device *,
-						 struct net *, const char *);
-extern int		dev_set_mtu(struct net_device *, int);
-extern void		dev_set_group(struct net_device *, int);
-extern int		dev_set_mac_address(struct net_device *,
-					    struct sockaddr *);
-extern int		dev_change_carrier(struct net_device *,
-					   bool new_carrier);
-extern int		dev_get_phys_port_id(struct net_device *dev,
-					     struct netdev_phys_port_id *ppid);
-extern int		dev_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev,
-					    struct netdev_queue *txq);
-extern int		dev_forward_skb(struct net_device *dev,
-					struct sk_buff *skb);
+int netdev_rx_handler_register(struct net_device *dev,
+			       rx_handler_func_t *rx_handler,
+			       void *rx_handler_data);
+void netdev_rx_handler_unregister(struct net_device *dev);
+
+bool dev_valid_name(const char *name);
+int dev_ioctl(struct net *net, unsigned int cmd, void __user *);
+int dev_ethtool(struct net *net, struct ifreq *);
+unsigned int dev_get_flags(const struct net_device *);
+int __dev_change_flags(struct net_device *, unsigned int flags);
+int dev_change_flags(struct net_device *, unsigned int);
+void __dev_notify_flags(struct net_device *, unsigned int old_flags);
+int dev_change_name(struct net_device *, const char *);
+int dev_set_alias(struct net_device *, const char *, size_t);
+int dev_change_net_namespace(struct net_device *, struct net *, const char *);
+int dev_set_mtu(struct net_device *, int);
+void dev_set_group(struct net_device *, int);
+int dev_set_mac_address(struct net_device *, struct sockaddr *);
+int dev_change_carrier(struct net_device *, bool new_carrier);
+int dev_get_phys_port_id(struct net_device *dev,
+			 struct netdev_phys_port_id *ppid);
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			struct netdev_queue *txq);
+int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
-extern void netdev_run_todo(void);
+void netdev_run_todo(void);
 
 /**
  *	dev_put - release reference to device
@@ -2433,9 +2423,9 @@ static inline void dev_hold(struct net_device *dev)
  * kind of lower layer not just hardware media.
  */
 
-extern void linkwatch_init_dev(struct net_device *dev);
-extern void linkwatch_fire_event(struct net_device *dev);
-extern void linkwatch_forget_dev(struct net_device *dev);
+void linkwatch_init_dev(struct net_device *dev);
+void linkwatch_fire_event(struct net_device *dev);
+void linkwatch_forget_dev(struct net_device *dev);
 
 /**
  *	netif_carrier_ok - test if carrier present
@@ -2448,13 +2438,13 @@ static inline bool netif_carrier_ok(const struct net_device *dev)
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
 }
 
-extern unsigned long dev_trans_start(struct net_device *dev);
+unsigned long dev_trans_start(struct net_device *dev);
 
-extern void __netdev_watchdog_up(struct net_device *dev);
+void __netdev_watchdog_up(struct net_device *dev);
 
-extern void netif_carrier_on(struct net_device *dev);
+void netif_carrier_on(struct net_device *dev);
 
-extern void netif_carrier_off(struct net_device *dev);
+void netif_carrier_off(struct net_device *dev);
 
 /**
  *	netif_dormant_on - mark device as dormant.
@@ -2522,9 +2512,9 @@ static inline bool netif_device_present(struct net_device *dev)
 	return test_bit(__LINK_STATE_PRESENT, &dev->state);
 }
 
-extern void netif_device_detach(struct net_device *dev);
+void netif_device_detach(struct net_device *dev);
 
-extern void netif_device_attach(struct net_device *dev);
+void netif_device_attach(struct net_device *dev);
 
 /*
  * Network interface message level settings
@@ -2733,98 +2723,93 @@ static inline void netif_addr_unlock_bh(struct net_device *dev)
 
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
-extern void		ether_setup(struct net_device *dev);
+void ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
-extern struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
-				       void (*setup)(struct net_device *),
-				       unsigned int txqs, unsigned int rxqs);
+struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
+				    void (*setup)(struct net_device *),
+				    unsigned int txqs, unsigned int rxqs);
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mqs(sizeof_priv, name, setup, 1, 1)
 
 #define alloc_netdev_mq(sizeof_priv, name, setup, count) \
 	alloc_netdev_mqs(sizeof_priv, name, setup, count, count)
 
-extern int		register_netdev(struct net_device *dev);
-extern void		unregister_netdev(struct net_device *dev);
+int register_netdev(struct net_device *dev);
+void unregister_netdev(struct net_device *dev);
 
 /* General hardware address lists handling functions */
-extern int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
-				  struct netdev_hw_addr_list *from_list,
-				  int addr_len, unsigned char addr_type);
-extern void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
-				   struct netdev_hw_addr_list *from_list,
-				   int addr_len, unsigned char addr_type);
-extern int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
-			  struct netdev_hw_addr_list *from_list,
-			  int addr_len);
-extern void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
-			     struct netdev_hw_addr_list *from_list,
-			     int addr_len);
-extern void __hw_addr_flush(struct netdev_hw_addr_list *list);
-extern void __hw_addr_init(struct netdev_hw_addr_list *list);
+int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
+			   struct netdev_hw_addr_list *from_list,
+			   int addr_len, unsigned char addr_type);
+void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
+			    struct netdev_hw_addr_list *from_list,
+			    int addr_len, unsigned char addr_type);
+int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
+		   struct netdev_hw_addr_list *from_list, int addr_len);
+void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
+		      struct netdev_hw_addr_list *from_list, int addr_len);
+void __hw_addr_flush(struct netdev_hw_addr_list *list);
+void __hw_addr_init(struct netdev_hw_addr_list *list);
 
 /* Functions used for device addresses handling */
-extern int dev_addr_add(struct net_device *dev, const unsigned char *addr,
-			unsigned char addr_type);
-extern int dev_addr_del(struct net_device *dev, const unsigned char *addr,
-			unsigned char addr_type);
-extern int dev_addr_add_multiple(struct net_device *to_dev,
-				 struct net_device *from_dev,
-				 unsigned char addr_type);
-extern int dev_addr_del_multiple(struct net_device *to_dev,
-				 struct net_device *from_dev,
-				 unsigned char addr_type);
-extern void dev_addr_flush(struct net_device *dev);
-extern int dev_addr_init(struct net_device *dev);
+int dev_addr_add(struct net_device *dev, const unsigned char *addr,
+		 unsigned char addr_type);
+int dev_addr_del(struct net_device *dev, const unsigned char *addr,
+		 unsigned char addr_type);
+int dev_addr_add_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev, unsigned char addr_type);
+int dev_addr_del_multiple(struct net_device *to_dev,
+			  struct net_device *from_dev, unsigned char addr_type);
+void dev_addr_flush(struct net_device *dev);
+int dev_addr_init(struct net_device *dev);
 
 /* Functions used for unicast addresses handling */
-extern int dev_uc_add(struct net_device *dev, const unsigned char *addr);
-extern int dev_uc_add_excl(struct net_device *dev, const unsigned char *addr);
-extern int dev_uc_del(struct net_device *dev, const unsigned char *addr);
-extern int dev_uc_sync(struct net_device *to, struct net_device *from);
-extern int dev_uc_sync_multiple(struct net_device *to, struct net_device *from);
-extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
-extern void dev_uc_flush(struct net_device *dev);
-extern void dev_uc_init(struct net_device *dev);
+int dev_uc_add(struct net_device *dev, const unsigned char *addr);
+int dev_uc_add_excl(struct net_device *dev, const unsigned char *addr);
+int dev_uc_del(struct net_device *dev, const unsigned char *addr);
+int dev_uc_sync(struct net_device *to, struct net_device *from);
+int dev_uc_sync_multiple(struct net_device *to, struct net_device *from);
+void dev_uc_unsync(struct net_device *to, struct net_device *from);
+void dev_uc_flush(struct net_device *dev);
+void dev_uc_init(struct net_device *dev);
 
 /* Functions used for multicast addresses handling */
-extern int dev_mc_add(struct net_device *dev, const unsigned char *addr);
-extern int dev_mc_add_global(struct net_device *dev, const unsigned char *addr);
-extern int dev_mc_add_excl(struct net_device *dev, const unsigned char *addr);
-extern int dev_mc_del(struct net_device *dev, const unsigned char *addr);
-extern int dev_mc_del_global(struct net_device *dev, const unsigned char *addr);
-extern int dev_mc_sync(struct net_device *to, struct net_device *from);
-extern int dev_mc_sync_multiple(struct net_device *to, struct net_device *from);
-extern void dev_mc_unsync(struct net_device *to, struct net_device *from);
-extern void dev_mc_flush(struct net_device *dev);
-extern void dev_mc_init(struct net_device *dev);
+int dev_mc_add(struct net_device *dev, const unsigned char *addr);
+int dev_mc_add_global(struct net_device *dev, const unsigned char *addr);
+int dev_mc_add_excl(struct net_device *dev, const unsigned char *addr);
+int dev_mc_del(struct net_device *dev, const unsigned char *addr);
+int dev_mc_del_global(struct net_device *dev, const unsigned char *addr);
+int dev_mc_sync(struct net_device *to, struct net_device *from);
+int dev_mc_sync_multiple(struct net_device *to, struct net_device *from);
+void dev_mc_unsync(struct net_device *to, struct net_device *from);
+void dev_mc_flush(struct net_device *dev);
+void dev_mc_init(struct net_device *dev);
 
 /* Functions used for secondary unicast and multicast support */
-extern void		dev_set_rx_mode(struct net_device *dev);
-extern void		__dev_set_rx_mode(struct net_device *dev);
-extern int		dev_set_promiscuity(struct net_device *dev, int inc);
-extern int		dev_set_allmulti(struct net_device *dev, int inc);
-extern void		netdev_state_change(struct net_device *dev);
-extern void		netdev_notify_peers(struct net_device *dev);
-extern void		netdev_features_change(struct net_device *dev);
+void dev_set_rx_mode(struct net_device *dev);
+void __dev_set_rx_mode(struct net_device *dev);
+int dev_set_promiscuity(struct net_device *dev, int inc);
+int dev_set_allmulti(struct net_device *dev, int inc);
+void netdev_state_change(struct net_device *dev);
+void netdev_notify_peers(struct net_device *dev);
+void netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
-extern void		dev_load(struct net *net, const char *name);
-extern struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
-					       struct rtnl_link_stats64 *storage);
-extern void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
-				    const struct net_device_stats *netdev_stats);
+void dev_load(struct net *net, const char *name);
+struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
+					struct rtnl_link_stats64 *storage);
+void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
+			     const struct net_device_stats *netdev_stats);
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		bpf_jit_enable;
 
-extern bool netdev_has_upper_dev(struct net_device *dev,
-				 struct net_device *upper_dev);
-extern bool netdev_has_any_upper_dev(struct net_device *dev);
-extern struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
-							    struct list_head **iter);
+bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
+bool netdev_has_any_upper_dev(struct net_device *dev);
+struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
+						     struct list_head **iter);
 
 /* iterate through upper list, must be called under RCU read lock */
 #define netdev_for_each_all_upper_dev_rcu(dev, updev, iter) \
@@ -2833,10 +2818,10 @@ extern struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *d
 	     updev; \
 	     updev = netdev_all_upper_get_next_dev_rcu(dev, &(iter)))
 
-extern void *netdev_lower_get_next_private(struct net_device *dev,
-					   struct list_head **iter);
-extern void *netdev_lower_get_next_private_rcu(struct net_device *dev,
-					       struct list_head **iter);
+void *netdev_lower_get_next_private(struct net_device *dev,
+				    struct list_head **iter);
+void *netdev_lower_get_next_private_rcu(struct net_device *dev,
+					struct list_head **iter);
 
 #define netdev_for_each_lower_private(dev, priv, iter) \
 	for (iter = (dev)->adj_list.lower.next, \
@@ -2850,27 +2835,26 @@ extern void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	     priv; \
 	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
 
-extern void *netdev_adjacent_get_private(struct list_head *adj_list);
-extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
-extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
-extern int netdev_upper_dev_link(struct net_device *dev,
+void *netdev_adjacent_get_private(struct list_head *adj_list);
+struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
+struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
+int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
+int netdev_master_upper_dev_link(struct net_device *dev,
 				 struct net_device *upper_dev);
-extern int netdev_master_upper_dev_link(struct net_device *dev,
-					struct net_device *upper_dev);
-extern int netdev_master_upper_dev_link_private(struct net_device *dev,
-						struct net_device *upper_dev,
-						void *private);
-extern void netdev_upper_dev_unlink(struct net_device *dev,
-				    struct net_device *upper_dev);
-extern void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
-					      struct net_device *lower_dev);
-extern void *netdev_lower_dev_get_private(struct net_device *dev,
-					  struct net_device *lower_dev);
-extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
-	netdev_features_t features, bool tx_path);
-extern struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
-					  netdev_features_t features);
+int netdev_master_upper_dev_link_private(struct net_device *dev,
+					 struct net_device *upper_dev,
+					 void *private);
+void netdev_upper_dev_unlink(struct net_device *dev,
+			     struct net_device *upper_dev);
+void *netdev_lower_dev_get_private_rcu(struct net_device *dev,
+				       struct net_device *lower_dev);
+void *netdev_lower_dev_get_private(struct net_device *dev,
+				   struct net_device *lower_dev);
+int skb_checksum_help(struct sk_buff *skb);
+struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
+				  netdev_features_t features, bool tx_path);
+struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+				    netdev_features_t features);
 
 static inline
 struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
@@ -2892,30 +2876,30 @@ static inline bool can_checksum_protocol(netdev_features_t features,
 }
 
 #ifdef CONFIG_BUG
-extern void netdev_rx_csum_fault(struct net_device *dev);
+void netdev_rx_csum_fault(struct net_device *dev);
 #else
 static inline void netdev_rx_csum_fault(struct net_device *dev)
 {
 }
 #endif
 /* rx skb timestamps */
-extern void		net_enable_timestamp(void);
-extern void		net_disable_timestamp(void);
+void net_enable_timestamp(void);
+void net_disable_timestamp(void);
 
 #ifdef CONFIG_PROC_FS
-extern int __init dev_proc_init(void);
+int __init dev_proc_init(void);
 #else
 #define dev_proc_init() 0
 #endif
 
-extern int netdev_class_create_file(struct class_attribute *class_attr);
-extern void netdev_class_remove_file(struct class_attribute *class_attr);
+int netdev_class_create_file(struct class_attribute *class_attr);
+void netdev_class_remove_file(struct class_attribute *class_attr);
 
 extern struct kobj_ns_type_operations net_ns_type_operations;
 
-extern const char *netdev_drivername(const struct net_device *dev);
+const char *netdev_drivername(const struct net_device *dev);
 
-extern void linkwatch_run_queue(void);
+void linkwatch_run_queue(void);
 
 static inline netdev_features_t netdev_get_wanted_features(
 	struct net_device *dev)
@@ -3007,22 +2991,22 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
-extern __printf(3, 4)
+__printf(3, 4)
 int netdev_printk(const char *level, const struct net_device *dev,
 		  const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_emerg(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_alert(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_crit(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_err(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_warn(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_notice(const struct net_device *dev, const char *format, ...);
-extern __printf(2, 3)
+__printf(2, 3)
 int netdev_info(const struct net_device *dev, const char *format, ...);
 
 #define MODULE_ALIAS_NETDEV(device) \
-- 
1.8.1.2.459.gbcd45b4.dirty
