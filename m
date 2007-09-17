From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Rename struct net to struct netns
Date: Mon, 17 Sep 2007 18:46:07 +0400
Message-ID: <46EE932F.2030206@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36995 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664AbXIQOsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 10:48:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name struct net is too generic. There already were
some people who wanted to have some better name (for
easier grep for example). I propose the struct netns one.

The patch is (already) huge (sorry), but it's nothing but
  sed -e s/struct net\>/struct netns/g

If this name is bad as well, let's select a new one
before the struct net floods the kernel.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 drivers/net/pppoe.c          |    2 -
 drivers/net/pppol2tp.c       |    2 -
 drivers/net/pppox.c          |    2 -
 fs/proc/proc_net.c           |   18 ++++++------
 include/linux/if_bridge.h    |    2 -
 include/linux/if_pppox.h     |    2 -
 include/linux/if_vlan.h      |    2 -
 include/linux/net.h          |    4 +-
 include/linux/netdevice.h    |   30 ++++++++++----------
 include/linux/netlink.h      |    6 ++--
 include/linux/nsproxy.h      |    2 -
 include/linux/proc_fs.h      |   14 ++++-----
 include/net/llc_conn.h       |    2 -
 include/net/net_namespace.h  |   22 +++++++--------
 include/net/rtnetlink.h      |    2 -
 include/net/sock.h           |    4 +-
 include/net/wext.h           |   14 ++++-----
 net/8021q/vlan.c             |    4 +-
 net/appletalk/ddp.c          |    2 -
 net/atm/common.c             |    2 -
 net/atm/common.h             |    2 -
 net/atm/pvc.c                |    2 -
 net/atm/svc.c                |    4 +-
 net/ax25/af_ax25.c           |    2 -
 net/bluetooth/af_bluetooth.c |    2 -
 net/bluetooth/bnep/sock.c    |    2 -
 net/bluetooth/cmtp/sock.c    |    2 -
 net/bluetooth/hci_sock.c     |    2 -
 net/bluetooth/hidp/sock.c    |    2 -
 net/bluetooth/l2cap.c        |    4 +-
 net/bluetooth/rfcomm/sock.c  |    4 +-
 net/bluetooth/sco.c          |    4 +-
 net/bridge/br_ioctl.c        |    2 -
 net/bridge/br_private.h      |    2 -
 net/core/dev.c               |   62 +++++++++++++++++++++----------------------
 net/core/dev_mcast.c         |    8 ++---
 net/core/ethtool.c           |    2 -
 net/core/fib_rules.c         |    2 -
 net/core/neighbour.c         |    4 +-
 net/core/net_namespace.c     |   24 ++++++++--------
 net/core/rtnetlink.c         |   20 ++++++-------
 net/core/sock.c              |    4 +-
 net/decnet/af_decnet.c       |    4 +-
 net/econet/af_econet.c       |    2 -
 net/ipv4/af_inet.c           |    2 -
 net/ipv6/af_inet6.c          |    2 -
 net/ipx/af_ipx.c             |    2 -
 net/irda/af_irda.c           |    4 +-
 net/irda/irnetlink.c         |    2 -
 net/key/af_key.c             |    2 -
 net/llc/af_llc.c             |    2 -
 net/llc/llc_conn.c           |    2 -
 net/netlink/af_netlink.c     |   26 +++++++++---------
 net/netrom/af_netrom.c       |    2 -
 net/packet/af_packet.c       |    2 -
 net/rose/af_rose.c           |    2 -
 net/rxrpc/af_rxrpc.c         |    2 -
 net/socket.c                 |   12 ++++----
 net/tipc/socket.c            |    2 -
 net/unix/af_unix.c           |    4 +-
 net/wireless/wext.c          |   10 +++---
 net/x25/af_x25.c             |    4 +-
 62 files changed, 195 insertions(+), 195 deletions(-)

--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -486,7 +486,7 @@ static struct proto pppoe_sk_proto = {
  * Initialize a new struct sock.
  *
  **********************************************************************/
-static int pppoe_create(struct net *net, struct socket *sock)
+static int pppoe_create(struct netns *net, struct socket *sock)
 {
 	int error = -ENOMEM;
 	struct sock *sk;
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1423,7 +1423,7 @@ static struct proto pppol2tp_sk_proto = 
 
 /* socket() handler. Initialize a new struct sock.
  */
-static int pppol2tp_create(struct net *net, struct socket *sock)
+static int pppol2tp_create(struct netns *net, struct socket *sock)
 {
 	int error = -ENOMEM;
 	struct sock *sk;
--- a/drivers/net/pppox.c
+++ b/drivers/net/pppox.c
@@ -104,7 +104,7 @@ int pppox_ioctl(struct socket *sock, uns
 
 EXPORT_SYMBOL(pppox_ioctl);
 
-static int pppox_create(struct net *net, struct socket *sock, int protocol)
+static int pppox_create(struct netns *net, struct socket *sock, int protocol)
 {
 	int rc = -EPROTOTYPE;
 
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -26,14 +26,14 @@
 #include "internal.h"
 
 
-struct proc_dir_entry *proc_net_create(struct net *net,
+struct proc_dir_entry *proc_net_create(struct netns *net,
 	const char *name, mode_t mode, get_info_t *get_info)
 {
 	return create_proc_info_entry(name,mode, net->proc_net, get_info);
 }
 EXPORT_SYMBOL_GPL(proc_net_create);
 
-struct proc_dir_entry *proc_net_fops_create(struct net *net,
+struct proc_dir_entry *proc_net_fops_create(struct netns *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
 {
 	struct proc_dir_entry *res;
@@ -45,13 +45,13 @@ struct proc_dir_entry *proc_net_fops_cre
 }
 EXPORT_SYMBOL_GPL(proc_net_fops_create);
 
-void proc_net_remove(struct net *net, const char *name)
+void proc_net_remove(struct netns *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
 }
 EXPORT_SYMBOL_GPL(proc_net_remove);
 
-struct net *get_proc_net(const struct inode *inode)
+struct netns *get_proc_net(const struct inode *inode)
 {
 	return maybe_get_net(PDE_NET(PDE(inode)));
 }
@@ -86,7 +86,7 @@ out_de_put:
 
 static void *proc_net_follow_link(struct dentry *parent, struct nameidata *nd)
 {
-	struct net *net = current->nsproxy->net_ns;
+	struct netns *net = current->nsproxy->net_ns;
 	struct dentry *shadow;
 	shadow = proc_net_shadow_dentry(parent, net->proc_net);
 	if (!shadow)
@@ -103,7 +103,7 @@ static void *proc_net_follow_link(struct
 static struct dentry *proc_net_lookup(struct inode *dir, struct dentry *dentry,
 				      struct nameidata *nd)
 {
-	struct net *net = current->nsproxy->net_ns;
+	struct netns *net = current->nsproxy->net_ns;
 	struct dentry *shadow;
 
 	shadow = proc_net_shadow_dentry(nd->dentry, net->proc_net);
@@ -118,7 +118,7 @@ static struct dentry *proc_net_lookup(st
 
 static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
 {
-	struct net *net = current->nsproxy->net_ns;
+	struct netns *net = current->nsproxy->net_ns;
 	struct dentry *shadow;
 	int ret;
 
@@ -140,7 +140,7 @@ static struct inode_operations proc_net_
 	.setattr	= proc_net_setattr,
 };
 
-static int proc_net_ns_init(struct net *net)
+static int proc_net_ns_init(struct netns *net)
 {
 	struct proc_dir_entry *root, *netd, *net_statd;
 	int err;
@@ -178,7 +178,7 @@ free_root:
 	goto out;
 }
 
-static void proc_net_ns_exit(struct net *net)
+static void proc_net_ns_exit(struct netns *net)
 {
 	remove_proc_entry("stat", net->proc_net);
 	remove_proc_entry("net", net->proc_net_root);
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -104,7 +104,7 @@ struct __fdb_entry
 
 #include <linux/netdevice.h>
 
-extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
+extern void brioctl_set(int (*ioctl_hook)(struct netns *, unsigned int, void __user *));
 extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
 					       struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -172,7 +172,7 @@ static inline struct sock *sk_pppox(stru
 struct module;
 
 struct pppox_proto {
-	int		(*create)(struct net *net, struct socket *sock);
+	int		(*create)(struct netns *net, struct socket *sock);
 	int		(*ioctl)(struct socket *sock, unsigned int cmd,
 				 unsigned long arg);
 	struct module	*owner;
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -62,7 +62,7 @@ struct vlan_hdr {
 #define VLAN_VID_MASK	0xfff
 
 /* found in socket.c */
-extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
+extern void vlan_ioctl_set(int (*hook)(struct netns *, void __user *));
 
 #define VLAN_NAME "vlan"
 
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -23,7 +23,7 @@
 
 struct poll_table_struct;
 struct inode;
-struct net;
+struct netns;
 
 #define NPROTO		34		/* should be enough for now..	*/
 
@@ -170,7 +170,7 @@ struct proto_ops {
 
 struct net_proto_family {
 	int		family;
-	int		(*create)(struct net *net, struct socket *sock, int protocol);
+	int		(*create)(struct netns *net, struct socket *sock, int protocol);
 	struct module	*owner;
 };
 
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -668,7 +668,7 @@ struct net_device
 #endif
 
 	/* Network namespace this network device is inside */
-	struct net		*nd_net;
+	struct netns		*nd_net;
 
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
@@ -757,14 +757,14 @@ extern rwlock_t				dev_base_lock;		/* De
 static inline struct net_device *next_net_device(struct net_device *dev)
 {
 	struct list_head *lh;
-	struct net *net;
+	struct netns *net;
 
 	net = dev->nd_net;
 	lh = dev->dev_list.next;
 	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
 }
 
-static inline struct net_device *first_net_device(struct net *net)
+static inline struct net_device *first_net_device(struct netns *net)
 {
 	return list_empty(&net->dev_base_head) ? NULL :
 		net_device_entry(net->dev_base_head.next);
@@ -772,17 +772,17 @@ static inline struct net_device *first_n
 
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
-extern struct net_device    *dev_getbyhwaddr(struct net *net, unsigned short type, char *hwaddr);
-extern struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type);
-extern struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type);
+extern struct net_device    *dev_getbyhwaddr(struct netns *net, unsigned short type, char *hwaddr);
+extern struct net_device *dev_getfirstbyhwtype(struct netns *net, unsigned short type);
+extern struct net_device *__dev_getfirstbyhwtype(struct netns *net, unsigned short type);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
 
-extern struct net_device	*dev_get_by_flags(struct net *net, unsigned short flags,
+extern struct net_device	*dev_get_by_flags(struct netns *net, unsigned short flags,
 						  unsigned short mask);
-extern struct net_device	*dev_get_by_name(struct net *net, const char *name);
-extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
+extern struct net_device	*dev_get_by_name(struct netns *net, const char *name);
+extern struct net_device	*__dev_get_by_name(struct netns *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
@@ -794,8 +794,8 @@ extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
 extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
-extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
-extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
+extern struct net_device	*dev_get_by_index(struct netns *net, int ifindex);
+extern struct net_device	*__dev_get_by_index(struct netns *net, int ifindex);
 extern int		dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
@@ -1011,13 +1011,13 @@ extern int		netif_rx_ni(struct sk_buff *
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
-extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
-extern int		dev_ethtool(struct net *net, struct ifreq *);
+extern int		dev_ioctl(struct netns *net, unsigned int cmd, void __user *);
+extern int		dev_ethtool(struct netns *net, struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, char *);
 extern int		dev_change_net_namespace(struct net_device *,
-						 struct net *, const char *);
+						 struct netns *, const char *);
 extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
@@ -1349,7 +1349,7 @@ extern void		dev_set_allmulti(struct net
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
-extern void		dev_load(struct net *net, const char *name);
+extern void		dev_load(struct netns *net, const char *name);
 extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -27,7 +27,7 @@
 
 #define MAX_LINKS 32		
 
-struct net;
+struct netns;
 
 struct sockaddr_nl
 {
@@ -173,7 +173,7 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
-extern struct sock *netlink_kernel_create(struct net *net,
+extern struct sock *netlink_kernel_create(struct netns *net,
 					  int unit,unsigned int groups,
 					  void (*input)(struct sock *sk, int len),
 					  struct mutex *cb_mutex,
@@ -223,7 +223,7 @@ struct netlink_callback
 
 struct netlink_notify
 {
-	struct net *net;
+	struct netns *net;
 	int pid;
 	int protocol;
 };
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -29,7 +29,7 @@ struct nsproxy {
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 	struct user_namespace *user_ns;
-	struct net 	     *net_ns;
+	struct netns 	     *net_ns;
 };
 extern struct nsproxy init_nsproxy;
 
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -7,7 +7,7 @@
 #include <linux/magic.h>
 #include <asm/atomic.h>
 
-struct net;
+struct netns;
 struct completion;
 
 /*
@@ -192,11 +192,11 @@ static inline struct proc_dir_entry *cre
 	return res;
 }
 
-extern struct proc_dir_entry *proc_net_create(struct net *net,
+extern struct proc_dir_entry *proc_net_create(struct netns *net,
 	const char *name, mode_t mode, get_info_t *get_info);
-extern struct proc_dir_entry *proc_net_fops_create(struct net *net,
+extern struct proc_dir_entry *proc_net_fops_create(struct netns *net,
 	const char *name, mode_t mode, const struct file_operations *fops);
-extern void proc_net_remove(struct net *net, const char *name);
+extern void proc_net_remove(struct netns *net, const char *name);
 
 #else
 
@@ -205,7 +205,7 @@ extern void proc_net_remove(struct net *
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
 #define proc_net_create(net, name, mode, info)	({ (void)(mode), NULL; })
-static inline void proc_net_remove(struct net *net, const char *name) {}
+static inline void proc_net_remove(struct netns *net, const char *name) {}
 
 static inline void proc_flush_task(struct task_struct *task) { }
 
@@ -265,12 +265,12 @@ static inline struct proc_dir_entry *PDE
 	return PROC_I(inode)->pde;
 }
 
-static inline struct net *PDE_NET(struct proc_dir_entry *pde)
+static inline struct netns *PDE_NET(struct proc_dir_entry *pde)
 {
 	return pde->parent->data;
 }
 
-struct net *get_proc_net(const struct inode *inode);
+struct netns *get_proc_net(const struct inode *inode);
 
 struct proc_maps_private {
 	struct pid *pid;
--- a/include/net/llc_conn.h
+++ b/include/net/llc_conn.h
@@ -93,7 +93,7 @@ static __inline__ char llc_backlog_type(
 	return skb->cb[sizeof(skb->cb) - 1];
 }
 
-extern struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority,
+extern struct sock *llc_sk_alloc(struct netns *net, int family, gfp_t priority,
 				 struct proto *prot);
 extern void llc_sk_free(struct sock *sk);
 
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -9,7 +9,7 @@
 #include <linux/list.h>
 
 struct proc_dir_entry;
-struct net {
+struct netns {
 	atomic_t		count;		/* To decided when the network
 						 *  namespace should be freed.
 						 */
@@ -30,7 +30,7 @@ struct net {
 
 #ifdef CONFIG_NET
 /* Init's network namespace */
-extern struct net init_net;
+extern struct netns init_net;
 #define INIT_NET_NS(net_ns) .net_ns = &init_net,
 #else
 #define INIT_NET_NS(net_ns)
@@ -38,17 +38,17 @@ extern struct net init_net;
 
 extern struct list_head net_namespace_list;
 
-extern void __put_net(struct net *net);
+extern void __put_net(struct netns *net);
 
-static inline struct net *get_net(struct net *net)
+static inline struct netns *get_net(struct netns *net)
 {
 	atomic_inc(&net->count);
 	return net;
 }
 
-static inline struct net *maybe_get_net(struct net *net)
+static inline struct netns *maybe_get_net(struct netns *net)
 {
-	/* Used when we know struct net exists but we
+	/* Used when we know struct netns exists but we
 	 * aren't guaranteed a previous reference count
 	 * exists.  If the reference count is zero this
 	 * function fails and returns NULL.
@@ -58,19 +58,19 @@ static inline struct net *maybe_get_net(
 	return net;
 }
 
-static inline void put_net(struct net *net)
+static inline void put_net(struct netns *net)
 {
 	if (atomic_dec_and_test(&net->count))
 		__put_net(net);
 }
 
-static inline struct net *hold_net(struct net *net)
+static inline struct netns *hold_net(struct netns *net)
 {
 	atomic_inc(&net->use_count);
 	return net;
 }
 
-static inline void release_net(struct net *net)
+static inline void release_net(struct netns *net)
 {
 	atomic_dec(&net->use_count);
 }
@@ -84,8 +84,8 @@ extern void net_unlock(void);
 
 struct pernet_operations {
 	struct list_head list;
-	int (*init)(struct net *net);
-	void (*exit)(struct net *net);
+	int (*init)(struct netns *net);
+	void (*exit)(struct netns *net);
 };
 
 extern int register_pernet_subsys(struct pernet_operations *);
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -78,7 +78,7 @@ extern void	__rtnl_link_unregister(struc
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
 
-extern struct net_device *rtnl_create_link(struct net *net, char *ifname,
+extern struct net_device *rtnl_create_link(struct netns *net, char *ifname,
 		const struct rtnl_link_ops *ops, struct nlattr *tb[]);
 extern const struct nla_policy ifla_policy[IFLA_MAX+1];
 
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -121,7 +121,7 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
-	struct net	 	*skc_net;
+	struct netns	 	*skc_net;
 };
 
 /**
@@ -777,7 +777,7 @@ extern void FASTCALL(release_sock(struct
 				SINGLE_DEPTH_NESTING)
 #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
 
-extern struct sock		*sk_alloc(struct net *net, int family,
+extern struct sock		*sk_alloc(struct netns *net, int family,
 					  gfp_t priority,
 					  struct proto *prot, int zero_it);
 extern void			sk_free(struct sock *sk);
--- a/include/net/wext.h
+++ b/include/net/wext.h
@@ -5,23 +5,23 @@
  * wireless extensions interface to the core code
  */
 
-struct net;
+struct netns;
 
 #ifdef CONFIG_WIRELESS_EXT
-extern int wext_proc_init(struct net *net);
-extern void wext_proc_exit(struct net *net);
-extern int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+extern int wext_proc_init(struct netns *net);
+extern void wext_proc_exit(struct netns *net);
+extern int wext_handle_ioctl(struct netns *net, struct ifreq *ifr, unsigned int cmd,
 			     void __user *arg);
 #else
-static inline int wext_proc_init(struct net *net)
+static inline int wext_proc_init(struct netns *net)
 {
 	return 0;
 }
-static inline void wext_proc_exit(struct net *net)
+static inline void wext_proc_exit(struct netns *net)
 {
 	return;
 }
-static inline int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+static inline int wext_handle_ioctl(struct netns *net, struct ifreq *ifr, unsigned int cmd,
 				    void __user *arg)
 {
 	return -EINVAL;
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -51,7 +51,7 @@ static char vlan_copyright[] = "Ben Gree
 static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
 static int vlan_device_event(struct notifier_block *, unsigned long, void *);
-static int vlan_ioctl_handler(struct net *net, void __user *);
+static int vlan_ioctl_handler(struct netns *net, void __user *);
 static int unregister_vlan_dev(struct net_device *, unsigned short );
 
 static struct notifier_block vlan_notifier_block = {
@@ -697,7 +697,7 @@ out:
  *	o execute requested action or pass command to the device driver
  *   arg is really a struct vlan_ioctl_args __user *.
  */
-static int vlan_ioctl_handler(struct net *net, void __user *arg)
+static int vlan_ioctl_handler(struct netns *net, void __user *arg)
 {
 	int err;
 	unsigned short vid = 0;
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1029,7 +1029,7 @@ static struct proto ddp_proto = {
  * Create a socket. Initialise the socket, blank the addresses
  * set the state.
  */
-static int atalk_create(struct net *net, struct socket *sock, int protocol)
+static int atalk_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -125,7 +125,7 @@ static struct proto vcc_proto = {
 	.obj_size = sizeof(struct atm_vcc),
 };
 
-int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
+int vcc_create(struct netns *net, struct socket *sock, int protocol, int family)
 {
 	struct sock *sk;
 	struct atm_vcc *vcc;
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -10,7 +10,7 @@
 #include <linux/poll.h> /* for poll_table */
 
 
-int vcc_create(struct net *net, struct socket *sock, int protocol, int family);
+int vcc_create(struct netns *net, struct socket *sock, int protocol, int family);
 int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -124,7 +124,7 @@ static const struct proto_ops pvc_proto_
 };
 
 
-static int pvc_create(struct net *net, struct socket *sock,int protocol)
+static int pvc_create(struct netns *net, struct socket *sock,int protocol)
 {
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -25,7 +25,7 @@
 #include "signaling.h"
 #include "addr.h"
 
-static int svc_create(struct net *net, struct socket *sock,int protocol);
+static int svc_create(struct netns *net, struct socket *sock,int protocol);
 
 /*
  * Note: since all this is still nicely synchronized with the signaling demon,
@@ -627,7 +627,7 @@ static const struct proto_ops svc_proto_
 };
 
 
-static int svc_create(struct net *net, struct socket *sock,int protocol)
+static int svc_create(struct netns *net, struct socket *sock,int protocol)
 {
 	int error;
 
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -783,7 +783,7 @@ static struct proto ax25_proto = {
 	.obj_size = sizeof(struct sock),
 };
 
-static int ax25_create(struct net *net, struct socket *sock, int protocol)
+static int ax25_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	ax25_cb *ax25;
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -95,7 +95,7 @@ int bt_sock_unregister(int proto)
 }
 EXPORT_SYMBOL(bt_sock_unregister);
 
-static int bt_sock_create(struct net *net, struct socket *sock, int proto)
+static int bt_sock_create(struct netns *net, struct socket *sock, int proto)
 {
 	int err;
 
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -204,7 +204,7 @@ static struct proto bnep_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int bnep_sock_create(struct net *net, struct socket *sock, int protocol)
+static int bnep_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -195,7 +195,7 @@ static struct proto cmtp_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol)
+static int cmtp_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -634,7 +634,7 @@ static struct proto hci_sk_proto = {
 	.obj_size	= sizeof(struct hci_pinfo)
 };
 
-static int hci_sock_create(struct net *net, struct socket *sock, int protocol)
+static int hci_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -246,7 +246,7 @@ static struct proto hidp_proto = {
 	.obj_size	= sizeof(struct bt_sock)
 };
 
-static int hidp_sock_create(struct net *net, struct socket *sock, int protocol)
+static int hidp_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -518,7 +518,7 @@ static struct proto l2cap_proto = {
 	.obj_size	= sizeof(struct l2cap_pinfo)
 };
 
-static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio)
+static struct sock *l2cap_sock_alloc(struct netns *net, struct socket *sock, int proto, gfp_t prio)
 {
 	struct sock *sk;
 
@@ -543,7 +543,7 @@ static struct sock *l2cap_sock_alloc(str
 	return sk;
 }
 
-static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol)
+static int l2cap_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -282,7 +282,7 @@ static struct proto rfcomm_proto = {
 	.obj_size	= sizeof(struct rfcomm_pinfo)
 };
 
-static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio)
+static struct sock *rfcomm_sock_alloc(struct netns *net, struct socket *sock, int proto, gfp_t prio)
 {
 	struct rfcomm_dlc *d;
 	struct sock *sk;
@@ -323,7 +323,7 @@ static struct sock *rfcomm_sock_alloc(st
 	return sk;
 }
 
-static int rfcomm_sock_create(struct net *net, struct socket *sock, int protocol)
+static int rfcomm_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -414,7 +414,7 @@ static struct proto sco_proto = {
 	.obj_size	= sizeof(struct sco_pinfo)
 };
 
-static struct sock *sco_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio)
+static struct sock *sco_sock_alloc(struct netns *net, struct socket *sock, int proto, gfp_t prio)
 {
 	struct sock *sk;
 
@@ -439,7 +439,7 @@ static struct sock *sco_sock_alloc(struc
 	return sk;
 }
 
-static int sco_sock_create(struct net *net, struct socket *sock, int protocol)
+static int sco_sock_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -365,7 +365,7 @@ static int old_deviceless(void __user *u
 	return -EOPNOTSUPP;
 }
 
-int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uarg)
+int br_ioctl_deviceless_stub(struct netns *net, unsigned int cmd, void __user *uarg)
 {
 	switch (cmd) {
 	case SIOCGIFBR:
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -196,7 +196,7 @@ extern struct sk_buff *br_handle_frame(s
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-extern int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *arg);
+extern int br_ioctl_deviceless_stub(struct netns *net, unsigned int cmd, void __user *arg);
 
 /* br_netfilter.c */
 #ifdef CONFIG_BRIDGE_NETFILTER
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -197,13 +197,13 @@ EXPORT_SYMBOL(dev_base_lock);
 #define NETDEV_HASHBITS	8
 #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
 
-static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
+static inline struct hlist_head *dev_name_hash(struct netns *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
 	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
 }
 
-static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
+static inline struct hlist_head *dev_index_hash(struct netns *net, int ifindex)
 {
 	return &net->dev_index_head[ifindex & ((1 << NETDEV_HASHBITS) - 1)];
 }
@@ -211,7 +211,7 @@ static inline struct hlist_head *dev_ind
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
-	struct net *net = dev->nd_net;
+	struct netns *net = dev->nd_net;
 
 	ASSERT_RTNL();
 
@@ -572,7 +572,7 @@ __setup("netdev=", netdev_boot_setup);
  *	careful with locks.
  */
 
-struct net_device *__dev_get_by_name(struct net *net, const char *name)
+struct net_device *__dev_get_by_name(struct netns *net, const char *name)
 {
 	struct hlist_node *p;
 
@@ -596,7 +596,7 @@ struct net_device *__dev_get_by_name(str
  *	matching device is found.
  */
 
-struct net_device *dev_get_by_name(struct net *net, const char *name)
+struct net_device *dev_get_by_name(struct netns *net, const char *name)
 {
 	struct net_device *dev;
 
@@ -619,7 +619,7 @@ struct net_device *dev_get_by_name(struc
  *	or @dev_base_lock.
  */
 
-struct net_device *__dev_get_by_index(struct net *net, int ifindex)
+struct net_device *__dev_get_by_index(struct netns *net, int ifindex)
 {
 	struct hlist_node *p;
 
@@ -643,7 +643,7 @@ struct net_device *__dev_get_by_index(st
  *	dev_put to indicate they have finished with it.
  */
 
-struct net_device *dev_get_by_index(struct net *net, int ifindex)
+struct net_device *dev_get_by_index(struct netns *net, int ifindex)
 {
 	struct net_device *dev;
 
@@ -669,7 +669,7 @@ struct net_device *dev_get_by_index(stru
  *	If the API was consistent this would be __dev_get_by_hwaddr
  */
 
-struct net_device *dev_getbyhwaddr(struct net *net, unsigned short type, char *ha)
+struct net_device *dev_getbyhwaddr(struct netns *net, unsigned short type, char *ha)
 {
 	struct net_device *dev;
 
@@ -685,7 +685,7 @@ struct net_device *dev_getbyhwaddr(struc
 
 EXPORT_SYMBOL(dev_getbyhwaddr);
 
-struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type)
+struct net_device *__dev_getfirstbyhwtype(struct netns *net, unsigned short type)
 {
 	struct net_device *dev;
 
@@ -699,7 +699,7 @@ struct net_device *__dev_getfirstbyhwtyp
 
 EXPORT_SYMBOL(__dev_getfirstbyhwtype);
 
-struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
+struct net_device *dev_getfirstbyhwtype(struct netns *net, unsigned short type)
 {
 	struct net_device *dev;
 
@@ -724,7 +724,7 @@ EXPORT_SYMBOL(dev_getfirstbyhwtype);
  *	dev_put to indicate they have finished with it.
  */
 
-struct net_device * dev_get_by_flags(struct net *net, unsigned short if_flags, unsigned short mask)
+struct net_device * dev_get_by_flags(struct netns *net, unsigned short if_flags, unsigned short mask)
 {
 	struct net_device *dev, *ret;
 
@@ -781,7 +781,7 @@ int dev_valid_name(const char *name)
  *	Returns the number of the unit assigned or a negative errno code.
  */
 
-static int __dev_alloc_name(struct net *net, const char *name, char *buf)
+static int __dev_alloc_name(struct netns *net, const char *name, char *buf)
 {
 	int i = 0;
 	const char *p;
@@ -848,7 +848,7 @@ static int __dev_alloc_name(struct net *
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
 	char buf[IFNAMSIZ];
-	struct net *net;
+	struct netns *net;
 	int ret;
 
 	BUG_ON(!dev->nd_net);
@@ -873,7 +873,7 @@ int dev_change_name(struct net_device *d
 	char oldname[IFNAMSIZ];
 	int err = 0;
 	int ret;
-	struct net *net;
+	struct netns *net;
 
 	ASSERT_RTNL();
 	BUG_ON(!dev->nd_net);
@@ -961,7 +961,7 @@ void netdev_state_change(struct net_devi
  *	available in this kernel then it becomes a nop.
  */
 
-void dev_load(struct net *net, const char *name)
+void dev_load(struct netns *net, const char *name)
 {
 	struct net_device *dev;
 
@@ -1132,7 +1132,7 @@ int register_netdevice_notifier(struct n
 {
 	struct net_device *dev;
 	struct net_device *last;
-	struct net *net;
+	struct netns *net;
 	int err;
 
 	rtnl_lock();
@@ -2249,7 +2249,7 @@ int register_gifconf(unsigned int family
  *	match.  --pb
  */
 
-static int dev_ifname(struct net *net, struct ifreq __user *arg)
+static int dev_ifname(struct netns *net, struct ifreq __user *arg)
 {
 	struct net_device *dev;
 	struct ifreq ifr;
@@ -2282,7 +2282,7 @@ static int dev_ifname(struct net *net, s
  *	Thus we will need a 'compatibility mode'.
  */
 
-static int dev_ifconf(struct net *net, char __user *arg)
+static int dev_ifconf(struct netns *net, char __user *arg)
 {
 	struct ifconf ifc;
 	struct net_device *dev;
@@ -2340,7 +2340,7 @@ static int dev_ifconf(struct net *net, c
  */
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	loff_t off;
 	struct net_device *dev;
 
@@ -2358,7 +2358,7 @@ void *dev_seq_start(struct seq_file *seq
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	++*pos;
 	return v == SEQ_START_TOKEN ?
 		first_net_device(net) : next_net_device((struct net_device *)v);
@@ -2474,7 +2474,7 @@ static int dev_seq_open(struct inode *in
 static int dev_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	put_net(net);
 	return seq_release(inode, file);
 }
@@ -2636,7 +2636,7 @@ static const struct file_operations ptyp
 };
 
 
-static int dev_proc_net_init(struct net *net)
+static int dev_proc_net_init(struct netns *net)
 {
 	int rc = -ENOMEM;
 
@@ -2661,7 +2661,7 @@ out_dev:
 	goto out;
 }
 
-static void dev_proc_net_exit(struct net *net)
+static void dev_proc_net_exit(struct netns *net)
 {
 	wext_proc_exit(net);
 
@@ -3110,7 +3110,7 @@ int dev_set_mac_address(struct net_devic
 /*
  *	Perform the SIOCxIFxxx calls.
  */
-static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
+static int dev_ifsioc(struct netns *net, struct ifreq *ifr, unsigned int cmd)
 {
 	int err;
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
@@ -3265,7 +3265,7 @@ static int dev_ifsioc(struct net *net, s
  *	positive or a negative errno code on error.
  */
 
-int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
+int dev_ioctl(struct netns *net, unsigned int cmd, void __user *arg)
 {
 	struct ifreq ifr;
 	int ret;
@@ -3438,7 +3438,7 @@ int dev_ioctl(struct net *net, unsigned 
  *	number.  The caller must hold the rtnl semaphore or the
  *	dev_base_lock to be sure it remains unique.
  */
-static int dev_new_index(struct net *net)
+static int dev_new_index(struct netns *net)
 {
 	static int ifindex;
 	for (;;) {
@@ -3482,7 +3482,7 @@ int register_netdevice(struct net_device
 	struct hlist_head *head;
 	struct hlist_node *p;
 	int ret;
-	struct net *net;
+	struct netns *net;
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -3978,7 +3978,7 @@ EXPORT_SYMBOL(unregister_netdev);
  *	Callers must hold the rtnl semaphore.
  */
 
-int dev_change_net_namespace(struct net_device *dev, struct net *net, const char *pat)
+int dev_change_net_namespace(struct net_device *dev, struct netns *net, const char *pat)
 {
 	char buf[IFNAMSIZ];
 	const char *destname;
@@ -4287,7 +4287,7 @@ static struct hlist_head *netdev_create_
 }
 
 /* Initialize per network namespace state */
-static int netdev_init(struct net *net)
+static int netdev_init(struct netns *net)
 {
 	INIT_LIST_HEAD(&net->dev_base_head);
 	rwlock_init(&dev_base_lock);
@@ -4308,7 +4308,7 @@ err_name:
 	return -ENOMEM;
 }
 
-static void netdev_exit(struct net *net)
+static void netdev_exit(struct netns *net)
 {
 	kfree(net->dev_name_head);
 	kfree(net->dev_index_head);
@@ -4319,7 +4319,7 @@ static struct pernet_operations netdev_n
 	.exit = netdev_exit,
 };
 
-static void default_device_exit(struct net *net)
+static void default_device_exit(struct netns *net)
 {
 	struct net_device *dev, *next;
 	/*
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -187,7 +187,7 @@ EXPORT_SYMBOL(dev_mc_unsync);
 #ifdef CONFIG_PROC_FS
 static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	struct net_device *dev;
 	loff_t off = 0;
 
@@ -258,7 +258,7 @@ static int dev_mc_seq_open(struct inode 
 static int dev_mc_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	put_net(net);
 	return seq_release(inode, file);
 }
@@ -273,14 +273,14 @@ static const struct file_operations dev_
 
 #endif
 
-static int dev_mc_net_init(struct net *net)
+static int dev_mc_net_init(struct netns *net)
 {
 	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
 
-static void dev_mc_net_exit(struct net *net)
+static void dev_mc_net_exit(struct netns *net)
 {
 	proc_net_remove(net, "dev_mcast");
 }
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -779,7 +779,7 @@ static int ethtool_set_value(struct net_
 
 /* The main entry point in this file.  Called from net/core/dev.c */
 
-int dev_ethtool(struct net *net, struct ifreq *ifr)
+int dev_ethtool(struct netns *net, struct ifreq *ifr)
 {
 	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
 	void __user *useraddr = ifr->ifr_data;
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -199,7 +199,7 @@ errout:
 
 static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *r, *last = NULL;
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1441,7 +1441,7 @@ int neigh_table_clear(struct neigh_table
 
 static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	struct ndmsg *ndm;
 	struct nlattr *dst_attr;
 	struct neigh_table *tbl;
@@ -1507,7 +1507,7 @@ out:
 
 static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct neigh_table *tbl;
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -19,7 +19,7 @@ LIST_HEAD(net_namespace_list);
 
 static struct kmem_cache *net_cachep;
 
-struct net init_net;
+struct netns init_net;
 EXPORT_SYMBOL_GPL(init_net);
 
 void net_lock(void)
@@ -33,13 +33,13 @@ void net_unlock(void)
 }
 
 #if 0
-static struct net *net_alloc(void)
+static struct netns *net_alloc(void)
 {
 	return kmem_cache_alloc(net_cachep, GFP_KERNEL);
 }
 #endif
 
-static void net_free(struct net *net)
+static void net_free(struct netns *net)
 {
 	if (!net)
 		return;
@@ -56,9 +56,9 @@ static void net_free(struct net *net)
 static void cleanup_net(struct work_struct *work)
 {
 	struct pernet_operations *ops;
-	struct net *net;
+	struct netns *net;
 
-	net = container_of(work, struct net, work);
+	net = container_of(work, struct netns, work);
 
 	mutex_lock(&net_mutex);
 
@@ -85,7 +85,7 @@ static void cleanup_net(struct work_stru
 }
 
 
-void __put_net(struct net *net)
+void __put_net(struct netns *net)
 {
 	/* Cleanup the network namespace in process context */
 	INIT_WORK(&net->work, cleanup_net);
@@ -96,13 +96,13 @@ EXPORT_SYMBOL_GPL(__put_net);
 /*
  * setup_net runs the initializers for the network namespace object.
  */
-static int setup_net(struct net *net)
+static int setup_net(struct netns *net)
 {
 	/* Must be called with net_mutex held */
 	struct pernet_operations *ops;
 	int error;
 
-	memset(net, 0, sizeof(struct net));
+	memset(net, 0, sizeof(struct netns));
 	atomic_set(&net->count, 1);
 	atomic_set(&net->use_count, 0);
 
@@ -132,8 +132,8 @@ static int __init net_ns_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "net_namespace: %zd bytes\n", sizeof(struct net));
-	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
+	printk(KERN_INFO "net_namespace: %zd bytes\n", sizeof(struct netns));
+	net_cachep = kmem_cache_create("net_namespace", sizeof(struct netns),
 					SMP_CACHE_BYTES,
 					SLAB_PANIC, NULL);
 	mutex_lock(&net_mutex);
@@ -155,7 +155,7 @@ pure_initcall(net_ns_init);
 static int register_pernet_operations(struct list_head *list,
 				      struct pernet_operations *ops)
 {
-	struct net *net, *undo_net;
+	struct netns *net, *undo_net;
 	int error;
 
 	error = 0;
@@ -185,7 +185,7 @@ undone:
 
 static void unregister_pernet_operations(struct pernet_operations *ops)
 {
-	struct net *net;
+	struct netns *net;
 
 	list_del(&ops->list);
 	for_each_net(net)
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -307,7 +307,7 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
 void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 {
 	struct net_device *dev, *n;
-	struct net *net;
+	struct netns *net;
 
 	for_each_net(net) {
 		for_each_netdev_safe(net, dev, n) {
@@ -697,7 +697,7 @@ nla_put_failure:
 
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	int idx;
 	int s_idx = cb->args[0];
 	struct net_device *dev;
@@ -736,10 +736,10 @@ static const struct nla_policy ifla_info
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
 };
 
-static struct net *get_net_ns_by_pid(pid_t pid)
+static struct netns *get_net_ns_by_pid(pid_t pid)
 {
 	struct task_struct *tsk;
-	struct net *net;
+	struct netns *net;
 
 	/* Lookup the network namespace */
 	net = ERR_PTR(-ESRCH);
@@ -762,7 +762,7 @@ static int do_setlink(struct net_device 
 	int err;
 
 	if (tb[IFLA_NET_NS_PID]) {
-		struct net *net;
+		struct netns *net;
 		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
 		if (IS_ERR(net)) {
 			err = PTR_ERR(net);
@@ -897,7 +897,7 @@ errout:
 
 static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	struct ifinfomsg *ifm;
 	struct net_device *dev;
 	int err;
@@ -944,7 +944,7 @@ errout:
 
 static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	const struct rtnl_link_ops *ops;
 	struct net_device *dev;
 	struct ifinfomsg *ifm;
@@ -978,7 +978,7 @@ static int rtnl_dellink(struct sk_buff *
 	return 0;
 }
 
-struct net_device *rtnl_create_link(struct net *net, char *ifname,
+struct net_device *rtnl_create_link(struct netns *net, char *ifname,
 		const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
 	int err;
@@ -1023,7 +1023,7 @@ err:
 
 static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	const struct rtnl_link_ops *ops;
 	struct net_device *dev;
 	struct ifinfomsg *ifm;
@@ -1152,7 +1152,7 @@ replay:
 
 static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct netns *net = skb->sk->sk_net;
 	struct ifinfomsg *ifm;
 	struct nlattr *tb[IFLA_MAX+1];
 	struct net_device *dev = NULL;
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -372,7 +372,7 @@ int sock_setsockopt(struct socket *sock,
 		    char __user *optval, int optlen)
 {
 	struct sock *sk=sock->sk;
-	struct net *net = sk->sk_net;
+	struct netns *net = sk->sk_net;
 	struct sk_filter *filter;
 	int val;
 	int valbool;
@@ -864,7 +864,7 @@ static inline void sock_lock_init(struct
  *	@prot: struct proto associated with this new sock instance
  *	@zero_it: if we should zero the newly allocated sock
  */
-struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
+struct sock *sk_alloc(struct netns *net, int family, gfp_t priority,
 		      struct proto *prot, int zero_it)
 {
 	struct sock *sk = NULL;
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -471,7 +471,7 @@ static struct proto dn_proto = {
 	.obj_size		= sizeof(struct dn_sock),
 };
 
-static struct sock *dn_alloc_sock(struct net *net, struct socket *sock, gfp_t gfp)
+static struct sock *dn_alloc_sock(struct netns *net, struct socket *sock, gfp_t gfp)
 {
 	struct dn_scp *scp;
 	struct sock *sk = sk_alloc(net, PF_DECnet, gfp, &dn_proto, 1);
@@ -675,7 +675,7 @@ char *dn_addr2asc(__u16 addr, char *buf)
 
 
 
-static int dn_create(struct net *net, struct socket *sock, int protocol)
+static int dn_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -608,7 +608,7 @@ static struct proto econet_proto = {
  *	Create an Econet socket
  */
 
-static int econet_create(struct net *net, struct socket *sock, int protocol)
+static int econet_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct econet_sock *eo;
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -241,7 +241,7 @@ EXPORT_SYMBOL(build_ehash_secret);
  *	Create an inet socket.
  */
 
-static int inet_create(struct net *net, struct socket *sock, int protocol)
+static int inet_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct list_head *p;
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -81,7 +81,7 @@ static __inline__ struct ipv6_pinfo *ine
 	return (struct ipv6_pinfo *)(((u8 *)sk) + offset);
 }
 
-static int inet6_create(struct net *net, struct socket *sock, int protocol)
+static int inet6_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct inet_sock *inet;
 	struct ipv6_pinfo *np;
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1363,7 +1363,7 @@ static struct proto ipx_proto = {
 	.obj_size = sizeof(struct ipx_sock),
 };
 
-static int ipx_create(struct net *net, struct socket *sock, int protocol)
+static int ipx_create(struct netns *net, struct socket *sock, int protocol)
 {
 	int rc = -ESOCKTNOSUPPORT;
 	struct sock *sk;
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -60,7 +60,7 @@
 
 #include <net/irda/af_irda.h>
 
-static int irda_create(struct net *net, struct socket *sock, int protocol);
+static int irda_create(struct netns *net, struct socket *sock, int protocol);
 
 static const struct proto_ops irda_stream_ops;
 static const struct proto_ops irda_seqpacket_ops;
@@ -1057,7 +1057,7 @@ static struct proto irda_proto = {
  *    Create IrDA socket
  *
  */
-static int irda_create(struct net *net, struct socket *sock, int protocol)
+static int irda_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct irda_sock *self;
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -31,7 +31,7 @@ static struct genl_family irda_nl_family
 	.maxattr = IRDA_NL_CMD_MAX,
 };
 
-static struct net_device * ifname_to_netdev(struct net *net, struct genl_info *info)
+static struct net_device * ifname_to_netdev(struct netns *net, struct genl_info *info)
 {
 	char * ifname;
 
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -136,7 +136,7 @@ static struct proto key_proto = {
 	.obj_size = sizeof(struct pfkey_sock),
 };
 
-static int pfkey_create(struct net *net, struct socket *sock, int protocol)
+static int pfkey_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	int err;
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -150,7 +150,7 @@ static struct proto llc_proto = {
  *	socket type we have available.
  *	Returns 0 upon success, negative upon failure.
  */
-static int llc_ui_create(struct net *net, struct socket *sock, int protocol)
+static int llc_ui_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	int rc = -ESOCKTNOSUPPORT;
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -867,7 +867,7 @@ static void llc_sk_init(struct sock* sk)
  *	Allocates a LLC sock and initializes it. Returns the new LLC sock
  *	or %NULL if there's no memory available for one
  */
-struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority, struct proto *prot)
+struct sock *llc_sk_alloc(struct netns *net, int family, gfp_t priority, struct proto *prot)
 {
 	struct sock *sk = sk_alloc(net, family, priority, prot, 1);
 
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -211,7 +211,7 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static __inline__ struct sock *netlink_lookup(struct net *net, int protocol, u32 pid)
+static __inline__ struct sock *netlink_lookup(struct netns *net, int protocol, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[protocol].hash;
 	struct hlist_head *head;
@@ -328,7 +328,7 @@ netlink_update_listeners(struct sock *sk
 	 * makes sure updates are visible before bind or setsockopt return. */
 }
 
-static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
+static int netlink_insert(struct sock *sk, struct netns *net, u32 pid)
 {
 	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
 	struct hlist_head *head;
@@ -384,7 +384,7 @@ static struct proto netlink_proto = {
 	.obj_size = sizeof(struct netlink_sock),
 };
 
-static int __netlink_create(struct net *net, struct socket *sock,
+static int __netlink_create(struct netns *net, struct socket *sock,
 			    struct mutex *cb_mutex, int protocol)
 {
 	struct sock *sk;
@@ -412,7 +412,7 @@ static int __netlink_create(struct net *
 	return 0;
 }
 
-static int netlink_create(struct net *net, struct socket *sock, int protocol)
+static int netlink_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct module *module = NULL;
 	struct mutex *cb_mutex;
@@ -507,7 +507,7 @@ static int netlink_release(struct socket
 static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct netns *net = sk->sk_net;
 	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
 	struct hlist_head *head;
 	struct sock *osk;
@@ -599,7 +599,7 @@ static int netlink_realloc_groups(struct
 static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct netns *net = sk->sk_net;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
@@ -705,7 +705,7 @@ static void netlink_overrun(struct sock 
 static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
 {
 	int protocol = ssk->sk_protocol;
-	struct net *net;
+	struct netns *net;
 	struct sock *sock;
 	struct netlink_sock *nlk;
 
@@ -891,7 +891,7 @@ static __inline__ int netlink_broadcast_
 
 struct netlink_broadcast_data {
 	struct sock *exclude_sk;
-	struct net *net;
+	struct netns *net;
 	u32 pid;
 	u32 group;
 	int failure;
@@ -955,7 +955,7 @@ out:
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 		      u32 group, gfp_t allocation)
 {
-	struct net *net = ssk->sk_net;
+	struct netns *net = ssk->sk_net;
 	struct netlink_broadcast_data info;
 	struct hlist_node *node;
 	struct sock *sk;
@@ -1317,7 +1317,7 @@ static void netlink_data_ready(struct so
  */
 
 struct sock *
-netlink_kernel_create(struct net *net, int unit, unsigned int groups,
+netlink_kernel_create(struct netns *net, int unit, unsigned int groups,
 		      void (*input)(struct sock *sk, int len),
 		      struct mutex *cb_mutex, struct module *module)
 {
@@ -1724,7 +1724,7 @@ int nlmsg_notify(struct sock *sk, struct
 
 #ifdef CONFIG_PROC_FS
 struct nl_seq_iter {
-	struct net *net;
+	struct netns *net;
 	int link;
 	int hash_idx;
 };
@@ -1924,7 +1924,7 @@ static struct net_proto_family netlink_f
 	.owner	= THIS_MODULE,	/* for consistency 8) */
 };
 
-static int netlink_net_init(struct net *net)
+static int netlink_net_init(struct netns *net)
 {
 #ifdef CONFIG_PROC_FS
 	if (!proc_net_fops_create(net, "netlink", 0, &netlink_seq_fops))
@@ -1933,7 +1933,7 @@ static int netlink_net_init(struct net *
 	return 0;
 }
 
-static void netlink_net_exit(struct net *net)
+static void netlink_net_exit(struct netns *net)
 {
 #ifdef CONFIG_PROC_FS
 	proc_net_remove(net, "netlink");
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -412,7 +412,7 @@ static struct proto nr_proto = {
 	.obj_size = sizeof(struct nr_sock),
 };
 
-static int nr_create(struct net *net, struct socket *sock, int protocol)
+static int nr_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct nr_sock *nr;
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -986,7 +986,7 @@ static struct proto packet_proto = {
  *	Create a packet of type SOCK_PACKET.
  */
 
-static int packet_create(struct net *net, struct socket *sock, int protocol)
+static int packet_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct packet_sock *po;
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -502,7 +502,7 @@ static struct proto rose_proto = {
 	.obj_size = sizeof(struct rose_sock),
 };
 
-static int rose_create(struct net *net, struct socket *sock, int protocol)
+static int rose_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct rose_sock *rose;
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -606,7 +606,7 @@ static unsigned int rxrpc_poll(struct fi
 /*
  * create an RxRPC socket
  */
-static int rxrpc_create(struct net *net, struct socket *sock, int protocol)
+static int rxrpc_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct rxrpc_sock *rx;
 	struct sock *sk;
--- a/net/socket.c
+++ b/net/socket.c
@@ -794,9 +794,9 @@ static ssize_t sock_aio_write(struct kio
  */
 
 static DEFINE_MUTEX(br_ioctl_mutex);
-static int (*br_ioctl_hook) (struct net *, unsigned int cmd, void __user *arg) = NULL;
+static int (*br_ioctl_hook) (struct netns *, unsigned int cmd, void __user *arg) = NULL;
 
-void brioctl_set(int (*hook) (struct net *, unsigned int, void __user *))
+void brioctl_set(int (*hook) (struct netns *, unsigned int, void __user *))
 {
 	mutex_lock(&br_ioctl_mutex);
 	br_ioctl_hook = hook;
@@ -806,9 +806,9 @@ void brioctl_set(int (*hook) (struct net
 EXPORT_SYMBOL(brioctl_set);
 
 static DEFINE_MUTEX(vlan_ioctl_mutex);
-static int (*vlan_ioctl_hook) (struct net *, void __user *arg);
+static int (*vlan_ioctl_hook) (struct netns *, void __user *arg);
 
-void vlan_ioctl_set(int (*hook) (struct net *, void __user *))
+void vlan_ioctl_set(int (*hook) (struct netns *, void __user *))
 {
 	mutex_lock(&vlan_ioctl_mutex);
 	vlan_ioctl_hook = hook;
@@ -840,7 +840,7 @@ static long sock_ioctl(struct file *file
 	struct sock *sk;
 	void __user *argp = (void __user *)arg;
 	int pid, err;
-	struct net *net;
+	struct netns *net;
 
 	sock = file->private_data;
 	sk = sock->sk;
@@ -1079,7 +1079,7 @@ call_kill:
 	return 0;
 }
 
-static int __sock_create(struct net *net, int family, int type, int protocol,
+static int __sock_create(struct netns *net, int family, int type, int protocol,
 			 struct socket **res, int kern)
 {
 	int err;
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -162,7 +162,7 @@ static void advance_queue(struct tipc_so
  *
  * Returns 0 on success, errno otherwise
  */
-static int tipc_create(struct net *net, struct socket *sock, int protocol)
+static int tipc_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct tipc_sock *tsock;
 	struct tipc_port *port;
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -594,7 +594,7 @@ static struct proto unix_proto = {
  */
 static struct lock_class_key af_unix_sk_receive_queue_lock_key;
 
-static struct sock * unix_create1(struct net *net, struct socket *sock)
+static struct sock * unix_create1(struct netns *net, struct socket *sock)
 {
 	struct sock *sk = NULL;
 	struct unix_sock *u;
@@ -628,7 +628,7 @@ out:
 	return sk;
 }
 
-static int unix_create(struct net *net, struct socket *sock, int protocol)
+static int unix_create(struct netns *net, struct socket *sock, int protocol)
 {
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -690,7 +690,7 @@ static int wireless_seq_open(struct inod
 static int wireless_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
-	struct net *net = seq->private;
+	struct netns *net = seq->private;
 	put_net(net);
 	return seq_release(inode, file);
 }
@@ -703,7 +703,7 @@ static const struct file_operations wire
 	.release = wireless_seq_release,
 };
 
-int wext_proc_init(struct net *net)
+int wext_proc_init(struct netns *net)
 {
 	/* Create /proc/net/wireless entry */
 	if (!proc_net_fops_create(net, "wireless", S_IRUGO, &wireless_seq_fops))
@@ -712,7 +712,7 @@ int wext_proc_init(struct net *net)
 	return 0;
 }
 
-void wext_proc_exit(struct net *net)
+void wext_proc_exit(struct netns *net)
 {
 	proc_net_remove(net, "wireless");
 }
@@ -1035,7 +1035,7 @@ static int ioctl_private_call(struct net
  * Main IOCTl dispatcher.
  * Check the type of IOCTL and call the appropriate wrapper...
  */
-static int wireless_process_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd)
+static int wireless_process_ioctl(struct netns *net, struct ifreq *ifr, unsigned int cmd)
 {
 	struct net_device *dev;
 	iw_handler	handler;
@@ -1078,7 +1078,7 @@ static int wireless_process_ioctl(struct
 }
 
 /* entry point from dev ioctl */
-int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
+int wext_handle_ioctl(struct netns *net, struct ifreq *ifr, unsigned int cmd,
 		      void __user *arg)
 {
 	int ret;
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -469,7 +469,7 @@ static struct proto x25_proto = {
 	.obj_size = sizeof(struct x25_sock),
 };
 
-static struct sock *x25_alloc_socket(struct net *net)
+static struct sock *x25_alloc_socket(struct netns *net)
 {
 	struct x25_sock *x25;
 	struct sock *sk = sk_alloc(net, AF_X25, GFP_ATOMIC, &x25_proto, 1);
@@ -488,7 +488,7 @@ out:
 	return sk;
 }
 
-static int x25_create(struct net *net, struct socket *sock, int protocol)
+static int x25_create(struct netns *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 	struct x25_sock *x25;
