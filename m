From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] net: 8021q/bluetooth/bridge/can/ceph: Remove extern from function prototypes
Date: Fri, 18 Oct 2013 13:48:22 -0700
Message-ID: <f0c49d4d49f5e2bd8e75ff323f35cb83f7f31439.1382129045.git.joe@perches.com>
References: <cover.1382129045.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1382129045.git.joe@perches.com>
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
 net/8021q/vlan.h            |  28 ++---
 net/bluetooth/hidp/hidp.h   |   4 +-
 net/bridge/br_private.h     | 299 ++++++++++++++++++++------------------------
 net/bridge/br_private_stp.h |  24 ++--
 net/can/af_can.h            |   6 +-
 net/ceph/auth_none.h        |   2 +-
 net/ceph/auth_x.h           |   2 +-
 net/ceph/crypto.h           |  48 ++++---
 8 files changed, 194 insertions(+), 219 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index ba5983f..a2caf00 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -196,12 +196,12 @@ static inline u32 vlan_get_ingress_priority(struct net_device *dev,
 }
 
 #ifdef CONFIG_VLAN_8021Q_GVRP
-extern int vlan_gvrp_request_join(const struct net_device *dev);
-extern void vlan_gvrp_request_leave(const struct net_device *dev);
-extern int vlan_gvrp_init_applicant(struct net_device *dev);
-extern void vlan_gvrp_uninit_applicant(struct net_device *dev);
-extern int vlan_gvrp_init(void);
-extern void vlan_gvrp_uninit(void);
+int vlan_gvrp_request_join(const struct net_device *dev);
+void vlan_gvrp_request_leave(const struct net_device *dev);
+int vlan_gvrp_init_applicant(struct net_device *dev);
+void vlan_gvrp_uninit_applicant(struct net_device *dev);
+int vlan_gvrp_init(void);
+void vlan_gvrp_uninit(void);
 #else
 static inline int vlan_gvrp_request_join(const struct net_device *dev) { return 0; }
 static inline void vlan_gvrp_request_leave(const struct net_device *dev) {}
@@ -212,12 +212,12 @@ static inline void vlan_gvrp_uninit(void) {}
 #endif
 
 #ifdef CONFIG_VLAN_8021Q_MVRP
-extern int vlan_mvrp_request_join(const struct net_device *dev);
-extern void vlan_mvrp_request_leave(const struct net_device *dev);
-extern int vlan_mvrp_init_applicant(struct net_device *dev);
-extern void vlan_mvrp_uninit_applicant(struct net_device *dev);
-extern int vlan_mvrp_init(void);
-extern void vlan_mvrp_uninit(void);
+int vlan_mvrp_request_join(const struct net_device *dev);
+void vlan_mvrp_request_leave(const struct net_device *dev);
+int vlan_mvrp_init_applicant(struct net_device *dev);
+void vlan_mvrp_uninit_applicant(struct net_device *dev);
+int vlan_mvrp_init(void);
+void vlan_mvrp_uninit(void);
 #else
 static inline int vlan_mvrp_request_join(const struct net_device *dev) { return 0; }
 static inline void vlan_mvrp_request_leave(const struct net_device *dev) {}
@@ -229,8 +229,8 @@ static inline void vlan_mvrp_uninit(void) {}
 
 extern const char vlan_fullname[];
 extern const char vlan_version[];
-extern int vlan_netlink_init(void);
-extern void vlan_netlink_fini(void);
+int vlan_netlink_init(void);
+void vlan_netlink_fini(void);
 
 extern struct rtnl_link_ops vlan_link_ops;
 
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index 9e6cc35..ab52414 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -182,7 +182,7 @@ struct hidp_session {
 };
 
 /* HIDP init defines */
-extern int __init hidp_init_sockets(void);
-extern void __exit hidp_cleanup_sockets(void);
+int __init hidp_init_sockets(void);
+void __exit hidp_cleanup_sockets(void);
 
 #endif /* __HIDP_H */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index efb57d9..767c4da 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -344,10 +344,9 @@ static inline int br_is_root_bridge(const struct net_bridge *br)
 }
 
 /* br_device.c */
-extern void br_dev_setup(struct net_device *dev);
-extern void br_dev_delete(struct net_device *dev, struct list_head *list);
-extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
-			       struct net_device *dev);
+void br_dev_setup(struct net_device *dev);
+void br_dev_delete(struct net_device *dev, struct list_head *list);
+netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
@@ -358,8 +357,8 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 		netpoll_send_skb(np, skb);
 }
 
-extern int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
-extern void br_netpoll_disable(struct net_bridge_port *p);
+int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
+void br_netpoll_disable(struct net_bridge_port *p);
 #else
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 				       struct sk_buff *skb)
@@ -377,116 +376,99 @@ static inline void br_netpoll_disable(struct net_bridge_port *p)
 #endif
 
 /* br_fdb.c */
-extern int br_fdb_init(void);
-extern void br_fdb_fini(void);
-extern void br_fdb_flush(struct net_bridge *br);
-extern void br_fdb_changeaddr(struct net_bridge_port *p,
-			      const unsigned char *newaddr);
-extern void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
-extern void br_fdb_cleanup(unsigned long arg);
-extern void br_fdb_delete_by_port(struct net_bridge *br,
-				  const struct net_bridge_port *p, int do_all);
-extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
-						 const unsigned char *addr,
-						 __u16 vid);
-extern int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
-extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
-			  unsigned long count, unsigned long off);
-extern int br_fdb_insert(struct net_bridge *br,
-			 struct net_bridge_port *source,
-			 const unsigned char *addr,
-			 u16 vid);
-extern void br_fdb_update(struct net_bridge *br,
-			  struct net_bridge_port *source,
-			  const unsigned char *addr,
-			  u16 vid);
-extern int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
-
-extern int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
-			 struct net_device *dev,
-			 const unsigned char *addr);
-extern int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[],
-		      struct net_device *dev,
-		      const unsigned char *addr,
-		      u16 nlh_flags);
-extern int br_fdb_dump(struct sk_buff *skb,
-		       struct netlink_callback *cb,
-		       struct net_device *dev,
-		       int idx);
+int br_fdb_init(void);
+void br_fdb_fini(void);
+void br_fdb_flush(struct net_bridge *br);
+void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
+void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
+void br_fdb_cleanup(unsigned long arg);
+void br_fdb_delete_by_port(struct net_bridge *br,
+			   const struct net_bridge_port *p, int do_all);
+struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
+					  const unsigned char *addr, __u16 vid);
+int br_fdb_test_addr(struct net_device *dev, unsigned char *addr);
+int br_fdb_fillbuf(struct net_bridge *br, void *buf, unsigned long count,
+		   unsigned long off);
+int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
+		  const unsigned char *addr, u16 vid);
+void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
+		   const unsigned char *addr, u16 vid);
+int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
+
+int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
+		  struct net_device *dev, const unsigned char *addr);
+int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
+	       const unsigned char *addr, u16 nlh_flags);
+int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
+		struct net_device *dev, int idx);
 
 /* br_forward.c */
-extern void br_deliver(const struct net_bridge_port *to,
-		struct sk_buff *skb);
-extern int br_dev_queue_push_xmit(struct sk_buff *skb);
-extern void br_forward(const struct net_bridge_port *to,
+void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
+int br_dev_queue_push_xmit(struct sk_buff *skb);
+void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb, struct sk_buff *skb0);
-extern int br_forward_finish(struct sk_buff *skb);
-extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb,
-			     bool unicast);
-extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-			     struct sk_buff *skb2, bool unicast);
+int br_forward_finish(struct sk_buff *skb);
+void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
+void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
+		      struct sk_buff *skb2, bool unicast);
 
 /* br_if.c */
-extern void br_port_carrier_check(struct net_bridge_port *p);
-extern int br_add_bridge(struct net *net, const char *name);
-extern int br_del_bridge(struct net *net, const char *name);
-extern void br_net_exit(struct net *net);
-extern int br_add_if(struct net_bridge *br,
-	      struct net_device *dev);
-extern int br_del_if(struct net_bridge *br,
-	      struct net_device *dev);
-extern int br_min_mtu(const struct net_bridge *br);
-extern netdev_features_t br_features_recompute(struct net_bridge *br,
-	netdev_features_t features);
+void br_port_carrier_check(struct net_bridge_port *p);
+int br_add_bridge(struct net *net, const char *name);
+int br_del_bridge(struct net *net, const char *name);
+void br_net_exit(struct net *net);
+int br_add_if(struct net_bridge *br, struct net_device *dev);
+int br_del_if(struct net_bridge *br, struct net_device *dev);
+int br_min_mtu(const struct net_bridge *br);
+netdev_features_t br_features_recompute(struct net_bridge *br,
+					netdev_features_t features);
 
 /* br_input.c */
-extern int br_handle_frame_finish(struct sk_buff *skb);
-extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
+int br_handle_frame_finish(struct sk_buff *skb);
+rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
 /* br_ioctl.c */
-extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-extern int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *arg);
+int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd,
+			     void __user *arg);
 
 /* br_multicast.c */
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 extern unsigned int br_mdb_rehash_seq;
-extern int br_multicast_rcv(struct net_bridge *br,
-			    struct net_bridge_port *port,
-			    struct sk_buff *skb);
-extern struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
-					       struct sk_buff *skb, u16 vid);
-extern void br_multicast_add_port(struct net_bridge_port *port);
-extern void br_multicast_del_port(struct net_bridge_port *port);
-extern void br_multicast_enable_port(struct net_bridge_port *port);
-extern void br_multicast_disable_port(struct net_bridge_port *port);
-extern void br_multicast_init(struct net_bridge *br);
-extern void br_multicast_open(struct net_bridge *br);
-extern void br_multicast_stop(struct net_bridge *br);
-extern void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
-				 struct sk_buff *skb);
-extern void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-				 struct sk_buff *skb, struct sk_buff *skb2);
-extern int br_multicast_set_router(struct net_bridge *br, unsigned long val);
-extern int br_multicast_set_port_router(struct net_bridge_port *p,
-					unsigned long val);
-extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
-extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
-extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
-extern struct net_bridge_mdb_entry *br_mdb_ip_get(
-				struct net_bridge_mdb_htable *mdb,
-				struct br_ip *dst);
-extern struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
-				struct net_bridge_port *port, struct br_ip *group);
-extern void br_multicast_free_pg(struct rcu_head *head);
-extern struct net_bridge_port_group *br_multicast_new_port_group(
-				struct net_bridge_port *port,
-				struct br_ip *group,
-				struct net_bridge_port_group __rcu *next,
-				unsigned char state);
-extern void br_mdb_init(void);
-extern void br_mdb_uninit(void);
-extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-			  struct br_ip *group, int type);
+int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
+		     struct sk_buff *skb);
+struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
+					struct sk_buff *skb, u16 vid);
+void br_multicast_add_port(struct net_bridge_port *port);
+void br_multicast_del_port(struct net_bridge_port *port);
+void br_multicast_enable_port(struct net_bridge_port *port);
+void br_multicast_disable_port(struct net_bridge_port *port);
+void br_multicast_init(struct net_bridge *br);
+void br_multicast_open(struct net_bridge *br);
+void br_multicast_stop(struct net_bridge *br);
+void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
+			  struct sk_buff *skb);
+void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
+			  struct sk_buff *skb, struct sk_buff *skb2);
+int br_multicast_set_router(struct net_bridge *br, unsigned long val);
+int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val);
+int br_multicast_toggle(struct net_bridge *br, unsigned long val);
+int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
+int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+struct net_bridge_mdb_entry *
+br_mdb_ip_get(struct net_bridge_mdb_htable *mdb, struct br_ip *dst);
+struct net_bridge_mdb_entry *
+br_multicast_new_group(struct net_bridge *br, struct net_bridge_port *port,
+		       struct br_ip *group);
+void br_multicast_free_pg(struct rcu_head *head);
+struct net_bridge_port_group *
+br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
+			    struct net_bridge_port_group __rcu *next,
+			    unsigned char state);
+void br_mdb_init(void);
+void br_mdb_uninit(void);
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+		   struct br_ip *group, int type);
 
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
@@ -591,22 +573,21 @@ static inline void br_mdb_uninit(void)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-extern bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			       struct sk_buff *skb, u16 *vid);
-extern bool br_allowed_egress(struct net_bridge *br,
-			      const struct net_port_vlans *v,
-			      const struct sk_buff *skb);
-extern struct sk_buff *br_handle_vlan(struct net_bridge *br,
-				      const struct net_port_vlans *v,
-				      struct sk_buff *skb);
-extern int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
-extern int br_vlan_delete(struct net_bridge *br, u16 vid);
-extern void br_vlan_flush(struct net_bridge *br);
-extern int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
-extern int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
-extern int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
-extern void nbp_vlan_flush(struct net_bridge_port *port);
-extern bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
+bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
+			struct sk_buff *skb, u16 *vid);
+bool br_allowed_egress(struct net_bridge *br, const struct net_port_vlans *v,
+		       const struct sk_buff *skb);
+struct sk_buff *br_handle_vlan(struct net_bridge *br,
+			       const struct net_port_vlans *v,
+			       struct sk_buff *skb);
+int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
+int br_vlan_delete(struct net_bridge *br, u16 vid);
+void br_vlan_flush(struct net_bridge *br);
+int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
+int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
+void nbp_vlan_flush(struct net_bridge_port *port);
+bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
 
 static inline struct net_port_vlans *br_get_vlan_info(
 						const struct net_bridge *br)
@@ -727,9 +708,9 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
 
 /* br_netfilter.c */
 #ifdef CONFIG_BRIDGE_NETFILTER
-extern int br_netfilter_init(void);
-extern void br_netfilter_fini(void);
-extern void br_netfilter_rtable_init(struct net_bridge *);
+int br_netfilter_init(void);
+void br_netfilter_fini(void);
+void br_netfilter_rtable_init(struct net_bridge *);
 #else
 #define br_netfilter_init()	(0)
 #define br_netfilter_fini()	do { } while(0)
@@ -737,43 +718,39 @@ extern void br_netfilter_rtable_init(struct net_bridge *);
 #endif
 
 /* br_stp.c */
-extern void br_log_state(const struct net_bridge_port *p);
-extern struct net_bridge_port *br_get_port(struct net_bridge *br,
-					   u16 port_no);
-extern void br_init_port(struct net_bridge_port *p);
-extern void br_become_designated_port(struct net_bridge_port *p);
+void br_log_state(const struct net_bridge_port *p);
+struct net_bridge_port *br_get_port(struct net_bridge *br, u16 port_no);
+void br_init_port(struct net_bridge_port *p);
+void br_become_designated_port(struct net_bridge_port *p);
 
-extern void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
-extern int br_set_forward_delay(struct net_bridge *br, unsigned long x);
-extern int br_set_hello_time(struct net_bridge *br, unsigned long x);
-extern int br_set_max_age(struct net_bridge *br, unsigned long x);
+void __br_set_forward_delay(struct net_bridge *br, unsigned long t);
+int br_set_forward_delay(struct net_bridge *br, unsigned long x);
+int br_set_hello_time(struct net_bridge *br, unsigned long x);
+int br_set_max_age(struct net_bridge *br, unsigned long x);
 
 
 /* br_stp_if.c */
-extern void br_stp_enable_bridge(struct net_bridge *br);
-extern void br_stp_disable_bridge(struct net_bridge *br);
-extern void br_stp_set_enabled(struct net_bridge *br, unsigned long val);
-extern void br_stp_enable_port(struct net_bridge_port *p);
-extern void br_stp_disable_port(struct net_bridge_port *p);
-extern bool br_stp_recalculate_bridge_id(struct net_bridge *br);
-extern void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *a);
-extern void br_stp_set_bridge_priority(struct net_bridge *br,
-				       u16 newprio);
-extern int br_stp_set_port_priority(struct net_bridge_port *p,
-				    unsigned long newprio);
-extern int br_stp_set_path_cost(struct net_bridge_port *p,
-				unsigned long path_cost);
-extern ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
+void br_stp_enable_bridge(struct net_bridge *br);
+void br_stp_disable_bridge(struct net_bridge *br);
+void br_stp_set_enabled(struct net_bridge *br, unsigned long val);
+void br_stp_enable_port(struct net_bridge_port *p);
+void br_stp_disable_port(struct net_bridge_port *p);
+bool br_stp_recalculate_bridge_id(struct net_bridge *br);
+void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *a);
+void br_stp_set_bridge_priority(struct net_bridge *br, u16 newprio);
+int br_stp_set_port_priority(struct net_bridge_port *p, unsigned long newprio);
+int br_stp_set_path_cost(struct net_bridge_port *p, unsigned long path_cost);
+ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
 /* br_stp_bpdu.c */
 struct stp_proto;
-extern void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
-		       struct net_device *dev);
+void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
+		struct net_device *dev);
 
 /* br_stp_timer.c */
-extern void br_stp_timer_init(struct net_bridge *br);
-extern void br_stp_port_timer_init(struct net_bridge_port *p);
-extern unsigned long br_timer_value(const struct timer_list *timer);
+void br_stp_timer_init(struct net_bridge *br);
+void br_stp_port_timer_init(struct net_bridge_port *p);
+unsigned long br_timer_value(const struct timer_list *timer);
 
 /* br.c */
 #if IS_ENABLED(CONFIG_ATM_LANE)
@@ -782,23 +759,23 @@ extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr)
 
 /* br_netlink.c */
 extern struct rtnl_link_ops br_link_ops;
-extern int br_netlink_init(void);
-extern void br_netlink_fini(void);
-extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
-extern int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
-extern int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg);
-extern int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-		      struct net_device *dev, u32 filter_mask);
+int br_netlink_init(void);
+void br_netlink_fini(void);
+void br_ifinfo_notify(int event, struct net_bridge_port *port);
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
+int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg);
+int br_getlink(struct sk_buff *skb, u32 pid, u32 seq, struct net_device *dev,
+	       u32 filter_mask);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
 extern const struct sysfs_ops brport_sysfs_ops;
-extern int br_sysfs_addif(struct net_bridge_port *p);
-extern int br_sysfs_renameif(struct net_bridge_port *p);
+int br_sysfs_addif(struct net_bridge_port *p);
+int br_sysfs_renameif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
-extern int br_sysfs_addbr(struct net_device *dev);
-extern void br_sysfs_delbr(struct net_device *dev);
+int br_sysfs_addbr(struct net_device *dev);
+void br_sysfs_delbr(struct net_device *dev);
 
 #else
 
diff --git a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
index 0c0fe36..2fe910c 100644
--- a/net/bridge/br_private_stp.h
+++ b/net/bridge/br_private_stp.h
@@ -51,19 +51,19 @@ static inline int br_is_designated_port(const struct net_bridge_port *p)
 
 
 /* br_stp.c */
-extern void br_become_root_bridge(struct net_bridge *br);
-extern void br_config_bpdu_generation(struct net_bridge *);
-extern void br_configuration_update(struct net_bridge *);
-extern void br_port_state_selection(struct net_bridge *);
-extern void br_received_config_bpdu(struct net_bridge_port *p,
-				    const struct br_config_bpdu *bpdu);
-extern void br_received_tcn_bpdu(struct net_bridge_port *p);
-extern void br_transmit_config(struct net_bridge_port *p);
-extern void br_transmit_tcn(struct net_bridge *br);
-extern void br_topology_change_detection(struct net_bridge *br);
+void br_become_root_bridge(struct net_bridge *br);
+void br_config_bpdu_generation(struct net_bridge *);
+void br_configuration_update(struct net_bridge *);
+void br_port_state_selection(struct net_bridge *);
+void br_received_config_bpdu(struct net_bridge_port *p,
+			     const struct br_config_bpdu *bpdu);
+void br_received_tcn_bpdu(struct net_bridge_port *p);
+void br_transmit_config(struct net_bridge_port *p);
+void br_transmit_tcn(struct net_bridge *br);
+void br_topology_change_detection(struct net_bridge *br);
 
 /* br_stp_bpdu.c */
-extern void br_send_config_bpdu(struct net_bridge_port *, struct br_config_bpdu *);
-extern void br_send_tcn_bpdu(struct net_bridge_port *);
+void br_send_config_bpdu(struct net_bridge_port *, struct br_config_bpdu *);
+void br_send_tcn_bpdu(struct net_bridge_port *);
 
 #endif
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 1dccb4c..6de58b4 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -108,9 +108,9 @@ struct s_pstats {
 extern struct dev_rcv_lists can_rx_alldev_list;
 
 /* function prototypes for the CAN networklayer procfs (proc.c) */
-extern void can_init_proc(void);
-extern void can_remove_proc(void);
-extern void can_stat_update(unsigned long data);
+void can_init_proc(void);
+void can_remove_proc(void);
+void can_stat_update(unsigned long data);
 
 /* structures and variables from af_can.c needed in proc.c for reading */
 extern struct timer_list can_stattimer;    /* timer for statistics update */
diff --git a/net/ceph/auth_none.h b/net/ceph/auth_none.h
index ed7d088..059a3ce 100644
--- a/net/ceph/auth_none.h
+++ b/net/ceph/auth_none.h
@@ -23,7 +23,7 @@ struct ceph_auth_none_info {
 	struct ceph_none_authorizer au;   /* we only need one; it's static */
 };
 
-extern int ceph_auth_none_init(struct ceph_auth_client *ac);
+int ceph_auth_none_init(struct ceph_auth_client *ac);
 
 #endif
 
diff --git a/net/ceph/auth_x.h b/net/ceph/auth_x.h
index c5a058d..65ee720 100644
--- a/net/ceph/auth_x.h
+++ b/net/ceph/auth_x.h
@@ -45,7 +45,7 @@ struct ceph_x_info {
 	struct ceph_x_authorizer auth_authorizer;
 };
 
-extern int ceph_x_init(struct ceph_auth_client *ac);
+int ceph_x_init(struct ceph_auth_client *ac);
 
 #endif
 
diff --git a/net/ceph/crypto.h b/net/ceph/crypto.h
index 3572dc5..d149822 100644
--- a/net/ceph/crypto.h
+++ b/net/ceph/crypto.h
@@ -20,34 +20,32 @@ static inline void ceph_crypto_key_destroy(struct ceph_crypto_key *key)
 		kfree(key->key);
 }
 
-extern int ceph_crypto_key_clone(struct ceph_crypto_key *dst,
-				 const struct ceph_crypto_key *src);
-extern int ceph_crypto_key_encode(struct ceph_crypto_key *key,
-				  void **p, void *end);
-extern int ceph_crypto_key_decode(struct ceph_crypto_key *key,
-				  void **p, void *end);
-extern int ceph_crypto_key_unarmor(struct ceph_crypto_key *key, const char *in);
+int ceph_crypto_key_clone(struct ceph_crypto_key *dst,
+			  const struct ceph_crypto_key *src);
+int ceph_crypto_key_encode(struct ceph_crypto_key *key, void **p, void *end);
+int ceph_crypto_key_decode(struct ceph_crypto_key *key, void **p, void *end);
+int ceph_crypto_key_unarmor(struct ceph_crypto_key *key, const char *in);
 
 /* crypto.c */
-extern int ceph_decrypt(struct ceph_crypto_key *secret,
-			void *dst, size_t *dst_len,
-			const void *src, size_t src_len);
-extern int ceph_encrypt(struct ceph_crypto_key *secret,
-			void *dst, size_t *dst_len,
-			const void *src, size_t src_len);
-extern int ceph_decrypt2(struct ceph_crypto_key *secret,
-			void *dst1, size_t *dst1_len,
-			void *dst2, size_t *dst2_len,
-			const void *src, size_t src_len);
-extern int ceph_encrypt2(struct ceph_crypto_key *secret,
-			 void *dst, size_t *dst_len,
-			 const void *src1, size_t src1_len,
-			 const void *src2, size_t src2_len);
-extern int ceph_crypto_init(void);
-extern void ceph_crypto_shutdown(void);
+int ceph_decrypt(struct ceph_crypto_key *secret,
+		 void *dst, size_t *dst_len,
+		 const void *src, size_t src_len);
+int ceph_encrypt(struct ceph_crypto_key *secret,
+		 void *dst, size_t *dst_len,
+		 const void *src, size_t src_len);
+int ceph_decrypt2(struct ceph_crypto_key *secret,
+		  void *dst1, size_t *dst1_len,
+		  void *dst2, size_t *dst2_len,
+		  const void *src, size_t src_len);
+int ceph_encrypt2(struct ceph_crypto_key *secret,
+		  void *dst, size_t *dst_len,
+		  const void *src1, size_t src1_len,
+		  const void *src2, size_t src2_len);
+int ceph_crypto_init(void);
+void ceph_crypto_shutdown(void);
 
 /* armor.c */
-extern int ceph_armor(char *dst, const char *src, const char *end);
-extern int ceph_unarmor(char *dst, const char *src, const char *end);
+int ceph_armor(char *dst, const char *src, const char *end);
+int ceph_unarmor(char *dst, const char *src, const char *end);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
