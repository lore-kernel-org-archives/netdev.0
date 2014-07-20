From: Karoly Kemeny <karoly.kemeny@gmail.com>
Subject: [PATCH] kernel-doc compliant documentation for net_device
Date: Sun, 20 Jul 2014 17:37:02 +0200
Message-ID: <1405870622-17222-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=y
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karoly Kemeny <karoly.kemeny@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org, trivial@kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Net_device is a vast and important structure, but it has no kernel-doc =
compliant
documentation. this patch extracts the comments from the structure to c=
lean it up,
and let the scripts extract documentation from it, i know it's big, but=
 it is just
reordering of comments into the appropriate form.

Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
---
 include/linux/netdevice.h | 367 +++++++++++++++++++++++++++++---------=
--------
 1 file changed, 232 insertions(+), 135 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66f9a04..937e980 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1230,41 +1230,205 @@ enum netdev_priv_flags {
 #define IFF_MACVLAN			IFF_MACVLAN
=20
 /*
- *	The DEVICE structure.
- *	Actually, this whole structure is a big mistake.  It mixes I/O
- *	data with strictly "high-level" data, and it has to know about
- *	almost every data structure used in the INET module.
+ *	struct net_device - The DEVICE structure.
+ *		Actually, this whole structure is a big mistake.  It mixes I/O
+ *		data with strictly "high-level" data, and it has to know about
+ *		almost every data structure used in the INET module.
+ *=09
+ *	@name:	This is the first field of the "visible" part of this struct=
ure
+ *		(i.e. as seen by users in the "Space.c" file).  It is the name
+ *	 	of the interface.
+ *
+ *	@hlist_node: 	Device name hash chain, please keep it close to name[=
]
+ *	@ifalias:	Snmp alias
+ *	@mem_end:	Shared memory end
+ *	@mem_start:	Shared memory start
+ *	@base_addr:	Device I/O address
+ *	@irq:		Device IRQ number
+ *	@adj_list:	Directly linked devices, like slaves for bonding
+ *	@all_adj_list:	All linked devices, *including* neighbours
+ *	@features:	Currently active device features
+ *	@hw_features:	User-changable features
+ *=09
+ *	@wanted_features:	User-requested features
+ *	@vlan_features:		Mask of features inheritable by VLAN devices
+ *=09
+ *	@hw_enc_features:	Mask of features inherited by enapsulating device=
s
+ *				This field indicates what encapsulation=20
+ *				offloads the hardware is capable of doing,
+ *				and drivers will need to set them appropriately.
+ *=09
+ *	@mpls_features:	Mask of features intheritable by MPLS
+ *
+ *	@ifindex:	interface index
+ *	@iflink:	unique device indentifier
+ *
+ *	@rx_dropped:	dropped packets by core network,=20
+ *			do not use this in drivers
+ *	@tx_dropped:	dropped packets by core network,=20
+ *			do not use this in drivers
+ *
+ *	@carrier_changes:	Stats to monitor carrier on<->off transitions
+ *
+ *	@wireless_handlers:	List of functions to handle Wireless Extensions=
,
+ *				instead of ioctl,=20
+ *				see <net/iw_handler.h> for details.
+ *	@wireless_data:	Instance data managed by the core of wireless exten=
sions
+=20
+ *	@netdev_ops:	Management operations
+ *	@ethtool_ops:	Management operations
+ *	@fwd_ops:	Management operations
+=20
+ *	@header_ops:	Hardware header description
+ *	@flags:		interface flags (a la BSD)
+ *	@priv_flags:	like 'flags' but invisible to userspace,=20
+ *			see if.h definitions
+ *	@gflags:	TODO: need comment on this one
+ *	@padded:	How much padding added by alloc_netdev()
+ *	@operstate:	RFC2863 operstate
+ *	@link_mode:	mapping policy to operstate
+ *	@if_port:	Selectable AUI, TP, ...
+ *	@dma:		DMA channel
+ *	@mtu:		interface MTU value
+ *	@type:		interface hardware type
+ *	@hard_header_len: hardware header length
+ *=09
+ *	@needed_headroom: extra headroom the hardware may need, but not in =
all
+ *			  cases can this be guaranteed
+ *	@needed_tailroom: extra tai=C3=A9room the hardware may need, but no=
t in all
+ *			  cases can this be guaranteed. Some cases also use
+ *			  LL_MAX_HEADER instead to allocate the skb
+ *
+ *	interface address info:
+ *
+ * 	@perm_addr:		permanent hw address
+ * 	@addr_assign_type:	hw address assignment type
+ * 	@addr_len:		hardware address length
+ * 	@neigh_priv_len;	TODO: need comments on this one
+ * 	@dev_id:		Used to differentiate devices that share
+ * 				the same link layer address
+ * 	@dev_port:		Used to differentiate devices that share
+ * 				the same function
+ *	@addr_list_lock:	TODO: need comments on this one
+ *	@uc:			unicast mac addresses
+ *	@mc:			multicas mac addresses
+ *	@dev_addrs:		list of device hw addresses
+ *	@queues_kset:		TODO: need comments on this one
+ *	@uc_promisc:		TODO: need comments on this one
+ *	@promiscuity:		TODO: need comments on this one
+ *	@allmulti:		TODO: need comments on this one
+ *
+ *	@vlan_info:	VLAN info
+ *	@dsa_ptr:	dsa specific data
+ *	@tipc_ptr:	TIPC specific data
+ *	@atalk_ptr:	AppleTalk link
+ *	@ip_ptr:	IPv4 specific data
+ *	@dn_ptr:	DECnet specific data
+ *	@ip6_ptr:	IPv6 specific data
+ *	@ax25:		AX.25 specific data
+ *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registerin=
g
+ *=09
+ *	@last_rx:	Time of last Rx
+ *	@dev_addr:	hw address (before bcast,=20
+ *			because most packets are unicast)
+ *=09
+ *	@_rx:			TODO: need comments on this one
+ *	@num_rx_queues:		number of RX queues=20
+ *				allocated at register_netdev() time
+ *	@real_num_rx_queues: 	number of RX queues currently active in devic=
e
+ *
+ *	@rx_handler:		handler for received packets
+ *	@rx_handler_data: 	TODO: need comments on this one
+ *	@ingress_queue:		TODO: need comments on this one
+ *	@broadcast:		hw bcast address
+ *
+ *	@_tx:			TODO: need comments on this one
+ *	@num_tx_queues:		Number of TX queues allocated at alloc_netdev_mq()=
 time
+ *	@real_num_tx_queues: 	Number of TX queues currently active in devic=
e
+ *	@qdisc:			Root qdisc form userspace point of view
+ *	@tx_queue_len:		Max frames per queue allowed
+ *	@tx_global_lock: 	TODO: need comments on this one
+ *=09
+ *	@xps_maps:	TODO: need comments on this one
+ *=09
+ *	@rx_cpu_rmap:	CPU reverse-mapping for RX completion interrupts,
+ *			indexed by RX queue number. Assigned by driver.
+ *			This must only be set if the ndo_rx_flow_steer
+ *			operation is defined
+ *=09
+ *	@trans_start:		Time (in jiffies) of last Tx
+ *	@watchdog_timeo:	Used by dev_watchdog()
+ *	@watchdog_timer:	TODO: need comments on this one
+ *
+ *	@pcpu_refcnt:		Number of references to this device
+ *	@todo_list:		delayed register/unregister
+ *	@index_hlist:		device index hash chain
+ *	@link_watch_list:	TODO: need comments on this one
+ *=09
+ *	@reg_state:		register/unregister state machine
+ *	@dismantle:		device is going to be freed
+ *	@rtnl_link_state:	TODO: need comments on this one
+ *
+ *	@destructor:		Called from unregister,
+ *				can be used to call free_netdev
+ *
+ * 	@nd_net:		Network namespace this network device is inside
+ *
+ * 	@ml_priv:	mid-layer private
+ * 	@lstats:	loopback stats
+ * 	@tstats:	TODO: need comments on this one
+ * 	@dstats:	dummy stats
+ * 	@vstats:	veth stats
+ *=09
+ *	@garp_port:	GARP
+ *	@mrp_port:	MRP
+ *
+ *	@dev:		class/net/name entry
+ *	@sysfs_groups:	space for optional device, statistics and wireless
+ *			sysfs groups
+ *=09
+ *	@sysfs_rx_queue_group:	space for optional per-rx queue attributes
+ *	@rtnl_link_ops:	rtnl_link_ops
+ *=09
+ *	@gso_max_size:	TODO: need comments on this one
+ *	@gso_max_segs:	TODO: need comments on this one
+ *
+ *	@dcbnl_ops:	Data Center Bridging netlink ops
+ *	@num_tc:	TODO: need comments on this one
+ *	@tc_to_txq:	TODO: need comments on this one
+ *	@prio_tc_map	TODO: need comments on this one
+ *
+ *	@fcoe_ddp_xid:	Max exchange id for FCoE LRO by ddp
+ *
+ *	@priomap:	TODO: need comments on this one
+ *	@phydev:	physical device may attach itself=20
+ *			for hardware timestamping
+ *
+ *	@qdisc_tx_busylock:	TODO: need comments on this one=20
+ *=09
+ *	@group:		Group the device belongs to
+ *	@pm_qos_req:	TODO: need comments on this one
  *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
  */
=20
 struct net_device {
-
-	/*
-	 * This is the first field of the "visible" part of this structure
-	 * (i.e. as seen by users in the "Space.c" file).  It is the name
-	 * of the interface.
-	 */
 	char			name[IFNAMSIZ];
-
-	/* device name hash chain, please keep it close to name[] */
 	struct hlist_node	name_hlist;
-
-	/* snmp alias */
 	char 			*ifalias;
-
 	/*
 	 *	I/O specific fields
 	 *	FIXME: Merge these and struct ifmap into one
 	 */
-	unsigned long		mem_end;	/* shared mem end	*/
-	unsigned long		mem_start;	/* shared mem start	*/
-	unsigned long		base_addr;	/* device I/O address	*/
-	int			irq;		/* device IRQ number	*/
+	unsigned long		mem_end;
+	unsigned long		mem_start;
+	unsigned long		base_addr;
+	int			irq;
=20
 	/*
-	 *	Some hardware also needs these fields, but they are not
+	 *	Some hardware also needs these fields (state,dev_list,
+	 *	napi_list,unreg_list,close_list) but they are not
 	 *	part of the usual set specified in Space.c.
 	 */
=20
@@ -1275,106 +1439,74 @@ struct net_device {
 	struct list_head	unreg_list;
 	struct list_head	close_list;
=20
-	/* directly linked devices, like slaves for bonding */
 	struct {
 		struct list_head upper;
 		struct list_head lower;
 	} adj_list;
=20
-	/* all linked devices, *including* neighbours */
 	struct {
 		struct list_head upper;
 		struct list_head lower;
 	} all_adj_list;
-
-
-	/* currently active device features */
+=09
 	netdev_features_t	features;
-	/* user-changeable features */
 	netdev_features_t	hw_features;
-	/* user-requested features */
 	netdev_features_t	wanted_features;
-	/* mask of features inheritable by VLAN devices */
 	netdev_features_t	vlan_features;
-	/* mask of features inherited by encapsulating devices
-	 * This field indicates what encapsulation offloads
-	 * the hardware is capable of doing, and drivers will
-	 * need to set them appropriately.
-	 */
 	netdev_features_t	hw_enc_features;
-	/* mask of fetures inheritable by MPLS */
 	netdev_features_t	mpls_features;
-
-	/* Interface index. Unique device identifier	*/
+=09
 	int			ifindex;
 	int			iflink;
=20
 	struct net_device_stats	stats;
-
-	/* dropped packets by core network, Do not use this in drivers */
+=09
 	atomic_long_t		rx_dropped;
 	atomic_long_t		tx_dropped;
-
-	/* Stats to monitor carrier on<->off transitions */
+=09
 	atomic_t		carrier_changes;
=20
 #ifdef CONFIG_WIRELESS_EXT
-	/* List of functions to handle Wireless Extensions (instead of ioctl)=
=2E
-	 * See <net/iw_handler.h> for details. Jean II */
 	const struct iw_handler_def *	wireless_handlers;
-	/* Instance data managed by the core of Wireless Extensions. */
 	struct iw_public_data *	wireless_data;
 #endif
-	/* Management operations */
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
 	const struct forwarding_accel_ops *fwd_ops;
=20
-	/* Hardware header description */
 	const struct header_ops *header_ops;
=20
-	unsigned int		flags;	/* interface flags (a la BSD)	*/
-	unsigned int		priv_flags; /* Like 'flags' but invisible to userspace.
-					     * See if.h for definitions. */
+	unsigned int		flags;
+	unsigned int		priv_flags;
+					 =20
 	unsigned short		gflags;
-	unsigned short		padded;	/* How much padding added by alloc_netdev() *=
/
+	unsigned short		padded;
=20
-	unsigned char		operstate; /* RFC2863 operstate */
-	unsigned char		link_mode; /* mapping policy to operstate */
+	unsigned char		operstate;
+	unsigned char		link_mode;
=20
-	unsigned char		if_port;	/* Selectable AUI, TP,..*/
-	unsigned char		dma;		/* DMA channel		*/
+	unsigned char		if_port;
+	unsigned char		dma;
=20
-	unsigned int		mtu;	/* interface MTU value		*/
-	unsigned short		type;	/* interface hardware type	*/
-	unsigned short		hard_header_len;	/* hardware hdr length	*/
+	unsigned int		mtu;
+	unsigned short		type;
+	unsigned short		hard_header_len;
=20
-	/* extra head- and tailroom the hardware may need, but not in all cas=
es
-	 * can this be guaranteed, especially tailroom. Some cases also use
-	 * LL_MAX_HEADER instead to allocate the skb.
-	 */
 	unsigned short		needed_headroom;
 	unsigned short		needed_tailroom;
=20
 	/* Interface address info. */
-	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
-	unsigned char		addr_assign_type; /* hw address assignment type */
-	unsigned char		addr_len;	/* hardware address length	*/
+	unsigned char		perm_addr[MAX_ADDR_LEN];
+	unsigned char		addr_assign_type;
+	unsigned char		addr_len;
 	unsigned short		neigh_priv_len;
-	unsigned short          dev_id;		/* Used to differentiate devices
-						 * that share the same link
-						 * layer address
-						 */
-	unsigned short          dev_port;	/* Used to differentiate
-						 * devices that share the same
-						 * function
-						 */
+	unsigned short          dev_id;
+	unsigned short          dev_port;=09
 	spinlock_t		addr_list_lock;
-	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
-	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
-	struct netdev_hw_addr_list	dev_addrs; /* list of device
-						    * hw addresses
-						    */
+	struct netdev_hw_addr_list	uc;
+	struct netdev_hw_addr_list	mc;
+	struct netdev_hw_addr_list	dev_addrs;=20
+
 #ifdef CONFIG_SYSFS
 	struct kset		*queues_kset;
 #endif
@@ -1387,40 +1519,34 @@ struct net_device {
 	/* Protocol specific pointers */
=20
 #if IS_ENABLED(CONFIG_VLAN_8021Q)
-	struct vlan_info __rcu	*vlan_info;	/* VLAN info */
+	struct vlan_info __rcu	*vlan_info;
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
-	struct dsa_switch_tree	*dsa_ptr;	/* dsa specific data */
+	struct dsa_switch_tree	*dsa_ptr;=09
 #endif
 #if IS_ENABLED(CONFIG_TIPC)
-	struct tipc_bearer __rcu *tipc_ptr;	/* TIPC specific data */
+	struct tipc_bearer __rcu *tipc_ptr;
 #endif
-	void 			*atalk_ptr;	/* AppleTalk link 	*/
-	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
-	struct dn_dev __rcu     *dn_ptr;        /* DECnet specific data */
-	struct inet6_dev __rcu	*ip6_ptr;       /* IPv6 specific data */
-	void			*ax25_ptr;	/* AX.25 specific data */
-	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
-						   assign before registering */
+	void 			*atalk_ptr;
+	struct in_device __rcu	*ip_ptr;
+	struct dn_dev __rcu     *dn_ptr;
+	struct inet6_dev __rcu	*ip6_ptr;
+	void			*ax25_ptr;
+	struct wireless_dev	*ieee80211_ptr;
=20
 /*
  * Cache lines mostly used on receive path (including eth_type_trans()=
)
  */
-	unsigned long		last_rx;	/* Time of last Rx */
+	unsigned long		last_rx;
=20
 	/* Interface address info used in eth_type_trans() */
-	unsigned char		*dev_addr;	/* hw address, (before bcast
-						   because most packets are
-						   unicast) */
+	unsigned char		*dev_addr;
=20
=20
 #ifdef CONFIG_SYSFS
 	struct netdev_rx_queue	*_rx;
=20
-	/* Number of RX queues allocated at register_netdev() time */
 	unsigned int		num_rx_queues;
-
-	/* Number of RX queues currently active in device */
 	unsigned int		real_num_rx_queues;
=20
 #endif
@@ -1429,33 +1555,23 @@ struct net_device {
 	void __rcu		*rx_handler_data;
=20
 	struct netdev_queue __rcu *ingress_queue;
-	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
+	unsigned char		broadcast[MAX_ADDR_LEN];
=20
=20
 /*
  * Cache lines mostly used on transmit path
  */
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
-
-	/* Number of TX queues allocated at alloc_netdev_mq() time  */
 	unsigned int		num_tx_queues;
-
-	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
-
-	/* root qdisc from userspace point of view */
 	struct Qdisc		*qdisc;
-
-	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	unsigned long		tx_queue_len;
 	spinlock_t		tx_global_lock;
=20
 #ifdef CONFIG_XPS
 	struct xps_dev_maps __rcu *xps_maps;
 #endif
 #ifdef CONFIG_RFS_ACCEL
-	/* CPU reverse-mapping for RX completion interrupts, indexed
-	 * by RX queue number.  Assigned by driver.  This must only be
-	 * set if the ndo_rx_flow_steer operation is defined. */
 	struct cpu_rmap		*rx_cpu_rmap;
 #endif
=20
@@ -1465,22 +1581,17 @@ struct net_device {
 	 * trans_start here is expensive for high speed devices on SMP,
 	 * please use netdev_queue->trans_start instead.
 	 */
-	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
+	unsigned long		trans_start;=09
=20
-	int			watchdog_timeo; /* used by dev_watchdog() */
+	int			watchdog_timeo;
 	struct timer_list	watchdog_timer;
-
-	/* Number of references to this device */
+=09
 	int __percpu		*pcpu_refcnt;
-
-	/* delayed register/unregister */
 	struct list_head	todo_list;
-	/* device index hash chain */
+=09
 	struct hlist_node	index_hlist;
-
 	struct list_head	link_watch_list;
=20
-	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=3D0,
 	       NETREG_REGISTERED,	/* completed register_netdevice */
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
@@ -1489,14 +1600,13 @@ struct net_device {
 	       NETREG_DUMMY,		/* dummy device for NAPI poll */
 	} reg_state:8;
=20
-	bool dismantle; /* device is going do be freed */
+	bool dismantle;
=20
 	enum {
 		RTNL_LINK_INITIALIZED,
 		RTNL_LINK_INITIALIZING,
 	} rtnl_link_state:16;
=20
-	/* Called from unregister, can be used to call free_netdev */
 	void (*destructor)(struct net_device *dev);
=20
 #ifdef CONFIG_NETPOLL
@@ -1504,31 +1614,25 @@ struct net_device {
 #endif
=20
 #ifdef CONFIG_NET_NS
-	/* Network namespace this network device is inside */
 	struct net		*nd_net;
 #endif
=20
 	/* mid-layer private */
 	union {
-		void				*ml_priv;
-		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
+		void					*ml_priv;
+		struct pcpu_lstats __percpu		*lstats;=20
 		struct pcpu_sw_netstats __percpu	*tstats;
-		struct pcpu_dstats __percpu	*dstats; /* dummy stats */
-		struct pcpu_vstats __percpu	*vstats; /* veth stats */
+		struct pcpu_dstats __percpu		*dstats;
+		struct pcpu_vstats __percpu		*vstats;
 	};
-	/* GARP */
+=09
 	struct garp_port __rcu	*garp_port;
-	/* MRP */
 	struct mrp_port __rcu	*mrp_port;
=20
-	/* class/net/name entry */
-	struct device		dev;
-	/* space for optional device, statistics, and wireless sysfs groups *=
/
+	struct device	dev;
 	const struct attribute_group *sysfs_groups[4];
-	/* space for optional per-rx queue attributes */
 	const struct attribute_group *sysfs_rx_queue_group;
=20
-	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
=20
 	/* for setting kernel sock attribute on TCP connection setup */
@@ -1538,7 +1642,6 @@ struct net_device {
 	u16			gso_max_segs;
=20
 #ifdef CONFIG_DCB
-	/* Data Center Bridging netlink ops */
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
 	u8 num_tc;
@@ -1546,20 +1649,14 @@ struct net_device {
 	u8 prio_tc_map[TC_BITMASK + 1];
=20
 #if IS_ENABLED(CONFIG_FCOE)
-	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
 #if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 	struct netprio_map __rcu *priomap;
 #endif
-	/* phy device may attach itself for hardware timestamping */
 	struct phy_device *phydev;
-
 	struct lock_class_key *qdisc_tx_busylock;
-
-	/* group the device belongs to */
 	int group;
-
 	struct pm_qos_request	pm_qos_req;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
--=20
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
