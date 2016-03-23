From: Bjorn Helgaas <bhelgaas@google.com>
Subject: [PATCH] net: Fix typos and whitespace.
Date: Wed, 23 Mar 2016 08:45:30 -0500
Message-ID: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix typos.  Capitalize CPU, NAPI, RCU consistently.  Align structure
indentation.  No functional change intended; only comment and whitespace
changes.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 include/linux/netdevice.h |  215 ++++++++++++++++++++++-----------------------
 1 file changed, 106 insertions(+), 109 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 009c85a..45e980e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -81,8 +81,8 @@ void netdev_set_default_ethtool_ops(struct net_device *dev,
  * function. Real network devices commonly used with qdiscs should only return
  * the driver transmit return codes though - when qdiscs are used, the actual
  * transmission happens asynchronously, so the value is not propagated to
- * higher layers. Virtual network devices transmit synchronously, in this case
- * the driver transmit return codes are consumed by dev_queue_xmit(), all
+ * higher layers. Virtual network devices transmit synchronously; in this case
+ * the driver transmit return codes are consumed by dev_queue_xmit(), and all
  * others are propagated to higher layers.
  */
 
@@ -129,7 +129,7 @@ static inline bool dev_xmit_complete(int rc)
 }
 
 /*
- *	Compute the worst case header length according to the protocols
+ *	Compute the worst-case header length according to the protocols
  *	used.
  */
 
@@ -246,7 +246,7 @@ struct hh_cache {
 	unsigned long	hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];
 };
 
-/* Reserve HH_DATA_MOD byte aligned hard_header_len, but at least that much.
+/* Reserve HH_DATA_MOD byte-aligned hard_header_len, but at least that much.
  * Alternative is:
  *   dev->hard_header_len ? (dev->hard_header_len +
  *                           (HH_DATA_MOD - 1)) & ~(HH_DATA_MOD - 1) : 0
@@ -272,7 +272,7 @@ struct header_ops {
 };
 
 /* These flag bits are private to the generic network queueing
- * layer, they may not be explicitly referenced by any other
+ * layer; they may not be explicitly referenced by any other
  * code.
  */
 
@@ -286,7 +286,7 @@ enum netdev_state_t {
 
 
 /*
- * This structure holds at boot time configured netdevice settings. They
+ * This structure holds boot-time configured netdevice settings. They
  * are then used in the device probing.
  */
 struct netdev_boot_setup {
@@ -304,7 +304,7 @@ struct napi_struct {
 	/* The poll_list must only be managed by the entity which
 	 * changes the state of the NAPI_STATE_SCHED bit.  This means
 	 * whoever atomically sets that bit can add this napi_struct
-	 * to the per-cpu poll_list, and whoever clears that bit
+	 * to the per-CPU poll_list, and whoever clears that bit
 	 * can remove from the list right before clearing the bit.
 	 */
 	struct list_head	poll_list;
@@ -350,7 +350,7 @@ typedef enum gro_result gro_result_t;
  * @RX_HANDLER_ANOTHER: Do another round in receive path. This is indicated in
  * case skb->dev was changed by rx_handler.
  * @RX_HANDLER_EXACT: Force exact delivery, no wildcard.
- * @RX_HANDLER_PASS: Do nothing, passe the skb as if no rx_handler was called.
+ * @RX_HANDLER_PASS: Do nothing, pass the skb as if no rx_handler was called.
  *
  * rx_handlers are functions called from inside __netif_receive_skb(), to do
  * special processing of the skb, prior to delivery to protocol handlers.
@@ -365,19 +365,19 @@ typedef enum gro_result gro_result_t;
  * Upon return, rx_handler is expected to tell __netif_receive_skb() what to
  * do with the skb.
  *
- * If the rx_handler consumed to skb in some way, it should return
+ * If the rx_handler consumed the skb in some way, it should return
  * RX_HANDLER_CONSUMED. This is appropriate when the rx_handler arranged for
- * the skb to be delivered in some other ways.
+ * the skb to be delivered in some other way.
  *
  * If the rx_handler changed skb->dev, to divert the skb to another
  * net_device, it should return RX_HANDLER_ANOTHER. The rx_handler for the
  * new device will be called if it exists.
  *
- * If the rx_handler consider the skb should be ignored, it should return
+ * If the rx_handler decides the skb should be ignored, it should return
  * RX_HANDLER_EXACT. The skb will only be delivered to protocol handlers that
  * are registered on exact device (ptype->dev == skb->dev).
  *
- * If the rx_handler didn't changed skb->dev, but want the skb to be normally
+ * If the rx_handler didn't change skb->dev, but wants the skb to be normally
  * delivered, it should return RX_HANDLER_PASS.
  *
  * A device without a registered rx_handler will behave as if rx_handler
@@ -402,11 +402,11 @@ static inline bool napi_disable_pending(struct napi_struct *n)
 }
 
 /**
- *	napi_schedule_prep - check if napi can be scheduled
- *	@n: napi context
+ *	napi_schedule_prep - check if NAPI can be scheduled
+ *	@n: NAPI context
  *
  * Test if NAPI routine is already running, and if not mark
- * it as running.  This is used as a condition variable
+ * it as running.  This is used as a condition variable to
  * insure only one NAPI poll instance runs.  We also make
  * sure there is no pending NAPI disable.
  */
@@ -418,7 +418,7 @@ static inline bool napi_schedule_prep(struct napi_struct *n)
 
 /**
  *	napi_schedule - schedule NAPI poll
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Schedule NAPI poll routine to be called if it is not already
  * running.
@@ -431,7 +431,7 @@ static inline void napi_schedule(struct napi_struct *n)
 
 /**
  *	napi_schedule_irqoff - schedule NAPI poll
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Variant of napi_schedule(), assuming hard irqs are masked.
  */
@@ -455,7 +455,7 @@ void __napi_complete(struct napi_struct *n);
 void napi_complete_done(struct napi_struct *n, int work_done);
 /**
  *	napi_complete - NAPI processing complete
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Mark NAPI processing as complete.
  * Consider using napi_complete_done() instead.
@@ -467,32 +467,32 @@ static inline void napi_complete(struct napi_struct *n)
 
 /**
  *	napi_hash_add - add a NAPI to global hashtable
- *	@napi: napi context
+ *	@napi: NAPI context
  *
- * generate a new napi_id and store a @napi under it in napi_hash
- * Used for busy polling (CONFIG_NET_RX_BUSY_POLL)
+ * Generate a new napi_id and store a @napi under it in napi_hash.
+ * Used for busy polling (CONFIG_NET_RX_BUSY_POLL).
  * Note: This is normally automatically done from netif_napi_add(),
- * so might disappear in a future linux version.
+ * so might disappear in a future Linux version.
  */
 void napi_hash_add(struct napi_struct *napi);
 
 /**
  *	napi_hash_del - remove a NAPI from global table
- *	@napi: napi context
+ *	@napi: NAPI context
  *
- * Warning: caller must observe rcu grace period
+ * Warning: caller must observe RCU grace period
  * before freeing memory containing @napi, if
  * this function returns true.
  * Note: core networking stack automatically calls it
- * from netif_napi_del()
+ * from netif_napi_del().
  * Drivers might want to call this helper to combine all
- * the needed rcu grace periods into a single one.
+ * the needed RCU grace periods into a single one.
  */
 bool napi_hash_del(struct napi_struct *napi);
 
 /**
  *	napi_disable - prevent NAPI from scheduling
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Stop NAPI from being scheduled on this context.
  * Waits till any outstanding processing completes.
@@ -501,7 +501,7 @@ void napi_disable(struct napi_struct *n);
 
 /**
  *	napi_enable - enable NAPI scheduling
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Resume NAPI from being scheduled on this context.
  * Must be paired with napi_disable.
@@ -516,7 +516,7 @@ static inline void napi_enable(struct napi_struct *n)
 
 /**
  *	napi_synchronize - wait until NAPI is not running
- *	@n: napi context
+ *	@n: NAPI context
  *
  * Wait until NAPI is done being scheduled on this context.
  * Waits till any outstanding processing completes but
@@ -559,7 +559,7 @@ enum netdev_queue_state_t {
 
 struct netdev_queue {
 /*
- * read mostly part
+ * read-mostly part
  */
 	struct net_device	*dev;
 	struct Qdisc __rcu	*qdisc;
@@ -571,7 +571,7 @@ struct netdev_queue {
 	int			numa_node;
 #endif
 /*
- * write mostly part
+ * write-mostly part
  */
 	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
 	int			xmit_lock_owner;
@@ -648,11 +648,11 @@ struct rps_dev_flow_table {
 /*
  * The rps_sock_flow_table contains mappings of flows to the last CPU
  * on which they were processed by the application (set in recvmsg).
- * Each entry is a 32bit value. Upper part is the high order bits
- * of flow hash, lower part is cpu number.
+ * Each entry is a 32bit value. Upper part is the high-order bits
+ * of flow hash, lower part is CPU number.
  * rps_cpu_mask is used to partition the space, depending on number of
- * possible cpus : rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1
- * For example, if 64 cpus are possible, rps_cpu_mask = 0x3f,
+ * possible CPUs : rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1
+ * For example, if 64 CPUs are possible, rps_cpu_mask = 0x3f,
  * meaning we use 32-6=26 bits for the hash.
  */
 struct rps_sock_flow_table {
@@ -674,7 +674,7 @@ static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
 		unsigned int index = hash & table->mask;
 		u32 val = hash & ~rps_cpu_mask;
 
-		/* We only give a hint, preemption can change cpu under us */
+		/* We only give a hint, preemption can change CPU under us */
 		val |= raw_smp_processor_id();
 
 		if (table->ents[index] != val)
@@ -807,21 +807,21 @@ struct tc_to_netdev {
  * optional and can be filled with a null pointer.
  *
  * int (*ndo_init)(struct net_device *dev);
- *     This function is called once when network device is registered.
- *     The network device can use this to any late stage initializaton
- *     or semantic validattion. It can fail with an error code which will
- *     be propogated back to register_netdev
+ *     This function is called once when a network device is registered.
+ *     The network device can use this for any late stage initialization
+ *     or semantic validation. It can fail with an error code which will
+ *     be propagated back to register_netdev.
  *
  * void (*ndo_uninit)(struct net_device *dev);
  *     This function is called when device is unregistered or when registration
  *     fails. It is not called if init fails.
  *
  * int (*ndo_open)(struct net_device *dev);
- *     This function is called when network device transistions to the up
+ *     This function is called when a network device transitions to the up
  *     state.
  *
  * int (*ndo_stop)(struct net_device *dev);
- *     This function is called when network device transistions to the down
+ *     This function is called when a network device transitions to the down
  *     state.
  *
  * netdev_tx_t (*ndo_start_xmit)(struct sk_buff *skb,
@@ -832,7 +832,7 @@ struct tc_to_netdev {
  *	corner cases, but the stack really does a non-trivial amount
  *	of useless work if you return NETDEV_TX_BUSY.
  *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
- *	Required can not be NULL.
+ *	Required; cannot be NULL.
  *
  * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
  *		netdev_features_t features);
@@ -842,34 +842,34 @@ struct tc_to_netdev {
  *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
  *                         void *accel_priv, select_queue_fallback_t fallback);
- *	Called to decide which queue to when device supports multiple
+ *	Called to decide which queue to use when device supports multiple
  *	transmit queues.
  *
  * void (*ndo_change_rx_flags)(struct net_device *dev, int flags);
  *	This function is called to allow device receiver to make
- *	changes to configuration when multicast or promiscious is enabled.
+ *	changes to configuration when multicast or promiscuous is enabled.
  *
  * void (*ndo_set_rx_mode)(struct net_device *dev);
  *	This function is called device changes address list filtering.
  *	If driver handles unicast address filtering, it should set
- *	IFF_UNICAST_FLT to its priv_flags.
+ *	IFF_UNICAST_FLT in its priv_flags.
  *
  * int (*ndo_set_mac_address)(struct net_device *dev, void *addr);
  *	This function  is called when the Media Access Control address
  *	needs to be changed. If this interface is not defined, the
- *	mac address can not be changed.
+ *	MAC address can not be changed.
  *
  * int (*ndo_validate_addr)(struct net_device *dev);
  *	Test if Media Access Control address is valid for the device.
  *
  * int (*ndo_do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
- *	Called when a user request an ioctl which can't be handled by
- *	the generic interface code. If not defined ioctl's return
+ *	Called when a user requests an ioctl which can't be handled by
+ *	the generic interface code. If not defined ioctls return
  *	not supported error code.
  *
  * int (*ndo_set_config)(struct net_device *dev, struct ifmap *map);
  *	Used to set network devices bus interface parameters. This interface
- *	is retained for legacy reason, new devices should use the bus
+ *	is retained for legacy reasons; new devices should use the bus
  *	interface (PCI) for low level management.
  *
  * int (*ndo_change_mtu)(struct net_device *dev, int new_mtu);
@@ -878,7 +878,7 @@ struct tc_to_netdev {
  *	will return an error.
  *
  * void (*ndo_tx_timeout)(struct net_device *dev);
- *	Callback uses when the transmitter has not made any progress
+ *	Callback used when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
  * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
@@ -896,11 +896,11 @@ struct tc_to_netdev {
  *	   neither operation.
  *
  * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16 vid);
- *	If device support VLAN filtering this function is called when a
+ *	If device supports VLAN filtering this function is called when a
  *	VLAN id is registered.
  *
  * int (*ndo_vlan_rx_kill_vid)(struct net_device *dev, __be16 proto, u16 vid);
- *	If device support VLAN filtering this function is called when a
+ *	If device supports VLAN filtering this function is called when a
  *	VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
@@ -920,7 +920,7 @@ struct tc_to_netdev {
  *
  *      Enable or disable the VF ability to query its RSS Redirection Table and
  *      Hash Key. This is needed since on some devices VF share this information
- *      with PF and querying it may adduce a theoretical security risk.
+ *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  * int (*ndo_setup_tc)(struct net_device *dev, u8 tc)
@@ -1030,20 +1030,20 @@ struct tc_to_netdev {
  *
  * void (*ndo_add_vxlan_port)(struct  net_device *dev,
  *			      sa_family_t sa_family, __be16 port);
- *	Called by vxlan to notiy a driver about the UDP port and socket
- *	address family that vxlan is listnening to. It is called only when
+ *	Called by vxlan to notify a driver about the UDP port and socket
+ *	address family that vxlan is listening to. It is called only when
  *	a new port starts listening. The operation is protected by the
  *	vxlan_net->sock_lock.
  *
  * void (*ndo_add_geneve_port)(struct net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
+ *			       sa_family_t sa_family, __be16 port);
  *	Called by geneve to notify a driver about the UDP port and socket
  *	address family that geneve is listnening to. It is called only when
  *	a new port starts listening. The operation is protected by the
  *	geneve_net->sock_lock.
  *
  * void (*ndo_del_geneve_port)(struct net_device *dev,
- *			      sa_family_t sa_family, __be16 port);
+ *			       sa_family_t sa_family, __be16 port);
  *	Called by geneve to notify the driver about a UDP port and socket
  *	address family that geneve is not listening to anymore. The operation
  *	is protected by the geneve_net->sock_lock.
@@ -1072,9 +1072,9 @@ struct tc_to_netdev {
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
- * netdev_features_t (*ndo_features_check) (struct sk_buff *skb,
- *					    struct net_device *dev
- *					    netdev_features_t features);
+ * netdev_features_t (*ndo_features_check)(struct sk_buff *skb,
+ *					   struct net_device *dev
+ *					   netdev_features_t features);
  *	Called by core transmit path to determine if device is capable of
  *	performing offload operations on a given packet. This is to give
  *	the device an opportunity to implement any restrictions that cannot
@@ -1088,7 +1088,7 @@ struct tc_to_netdev {
  * int (*ndo_get_iflink)(const struct net_device *dev);
  *	Called to get the iflink value of this device.
  * void (*ndo_change_proto_down)(struct net_device *dev,
- *				  bool proto_down);
+ *				 bool proto_down);
  *	This function is used to pass protocol port error state information
  *	to the switch driver. The switch driver can react to the proto_down
  *      by doing a phys down on the associated switch port.
@@ -1100,7 +1100,7 @@ struct tc_to_netdev {
  *	This function is used to specify the headroom that the skb must
  *	consider when allocation skb during packet reception. Setting
  *	appropriate rx headroom value allows avoiding skb head copy on
- *	forward. Setting a negative value reset the rx headroom to the
+ *	forward. Setting a negative value resets the rx headroom to the
  *	default value.
  *
  */
@@ -1299,7 +1299,7 @@ struct net_device_ops {
  *
  * These are the &struct net_device, they are only set internally
  * by drivers and used in the kernel. These flags are invisible to
- * userspace, this means that the order of these flags can change
+ * userspace; this means that the order of these flags can change
  * during any kernel release.
  *
  * You should have a pretty good reason to be extending these flags.
@@ -1413,10 +1413,10 @@ enum netdev_priv_flags {
  *
  *	@state:		Generic network queuing layer state, see netdev_state_t
  *	@dev_list:	The global list of network devices
- *	@napi_list:	List entry, that is used for polling napi devices
- *	@unreg_list:	List entry, that is used, when we are unregistering the
- *			device, see the function unregister_netdev
- *	@close_list:	List entry, that is used, when we are closing the device
+ *	@napi_list:	List entry used for polling NAPI devices
+ *	@unreg_list:	List entry used when we are unregistering the
+ *			device; see the function unregister_netdev()
+ *	@close_list:	List entry used when we are closing the device
  *
  *	@adj_list:	Directly linked devices, like slaves for bonding
  *	@all_adj_list:	All linked devices, *including* neighbours
@@ -1434,7 +1434,7 @@ enum netdev_priv_flags {
  *	@mpls_features:	Mask of features inheritable by MPLS
  *
  *	@ifindex:	interface index
- *	@group:		The group, that the device belongs to
+ *	@group:		The group the device belongs to
  *
  *	@stats:		Statistics struct, which was left as a legacy, use
  *			rtnl_link_stats64 instead
@@ -1488,7 +1488,7 @@ enum netdev_priv_flags {
  * 	@dev_port:		Used to differentiate devices that share
  * 				the same function
  *	@addr_list_lock:	XXX: need comments on this one
- *	@uc_promisc:		Counter, that indicates, that promiscuous mode
+ *	@uc_promisc:		Counter that indicates promiscuous mode
  *				has been enabled due to the need to listen to
  *				additional unicast addresses in a device that
  *				does not implement ndo_set_rx_mode()
@@ -1496,9 +1496,9 @@ enum netdev_priv_flags {
  *	@mc:			multicast mac addresses
  *	@dev_addrs:		list of device hw addresses
  *	@queues_kset:		Group of all Kobjects in the Tx and RX queues
- *	@promiscuity:		Number of times, the NIC is told to work in
- *				Promiscuous mode, if it becomes 0 the NIC will
- *				exit from working in Promiscuous mode
+ *	@promiscuity:		Number of times the NIC is told to work in
+ *				promiscuous mode; if it becomes 0 the NIC will
+ *				exit promiscuous mode
  *	@allmulti:		Counter, enables or disables allmulticast mode
  *
  *	@vlan_info:	VLAN info
@@ -1544,7 +1544,7 @@ enum netdev_priv_flags {
  *
  *	@trans_start:		Time (in jiffies) of last Tx
  *	@watchdog_timeo:	Represents the timeout that is used by
- *				the watchdog ( see dev_watchdog() )
+ *				the watchdog (see dev_watchdog())
  *	@watchdog_timer:	List of timers
  *
  *	@pcpu_refcnt:		Number of references to this device
@@ -1661,8 +1661,8 @@ struct net_device {
 	atomic_long_t		rx_nohandler;
 
 #ifdef CONFIG_WIRELESS_EXT
-	const struct iw_handler_def *	wireless_handlers;
-	struct iw_public_data *	wireless_data;
+	const struct iw_handler_def *wireless_handlers;
+	struct iw_public_data	*wireless_data;
 #endif
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
@@ -1715,7 +1715,7 @@ struct net_device {
 	unsigned int		allmulti;
 
 
-	/* Protocol specific pointers */
+	/* Protocol-specific pointers */
 
 #if IS_ENABLED(CONFIG_VLAN_8021Q)
 	struct vlan_info __rcu	*vlan_info;
@@ -1745,13 +1745,11 @@ struct net_device {
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		*dev_addr;
 
-
 #ifdef CONFIG_SYSFS
 	struct netdev_rx_queue	*_rx;
 
 	unsigned int		num_rx_queues;
 	unsigned int		real_num_rx_queues;
-
 #endif
 
 	unsigned long		gro_flush_timeout;
@@ -1843,7 +1841,7 @@ struct net_device {
 	struct garp_port __rcu	*garp_port;
 	struct mrp_port __rcu	*mrp_port;
 
-	struct device	dev;
+	struct device		dev;
 	const struct attribute_group *sysfs_groups[4];
 	const struct attribute_group *sysfs_rx_queue_group;
 
@@ -1858,9 +1856,9 @@ struct net_device {
 #ifdef CONFIG_DCB
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
-	u8 num_tc;
-	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
-	u8 prio_tc_map[TC_BITMASK + 1];
+	u8			num_tc;
+	struct netdev_tc_txq	tc_to_txq[TC_MAX_QUEUE];
+	u8			prio_tc_map[TC_BITMASK + 1];
 
 #if IS_ENABLED(CONFIG_FCOE)
 	unsigned int		fcoe_ddp_xid;
@@ -1868,9 +1866,9 @@ struct net_device {
 #if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 	struct netprio_map __rcu *priomap;
 #endif
-	struct phy_device *phydev;
-	struct lock_class_key *qdisc_tx_busylock;
-	bool proto_down;
+	struct phy_device	*phydev;
+	struct lock_class_key	*qdisc_tx_busylock;
+	bool			proto_down;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -2018,7 +2016,7 @@ static inline void *netdev_priv(const struct net_device *dev)
 
 /* Set the sysfs device type for the network logical device to allow
  * fine-grained identification of different network device types. For
- * example Ethernet, Wirelss LAN, Bluetooth, WiMAX etc.
+ * example Ethernet, Wireless LAN, Bluetooth, WiMAX etc.
  */
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
@@ -2028,22 +2026,22 @@ static inline void *netdev_priv(const struct net_device *dev)
 #define NAPI_POLL_WEIGHT 64
 
 /**
- *	netif_napi_add - initialize a napi context
+ *	netif_napi_add - initialize a NAPI context
  *	@dev:  network device
- *	@napi: napi context
+ *	@napi: NAPI context
  *	@poll: polling function
  *	@weight: default weight
  *
- * netif_napi_add() must be used to initialize a napi context prior to calling
- * *any* of the other napi related functions.
+ * netif_napi_add() must be used to initialize a NAPI context prior to calling
+ * *any* of the other NAPI-related functions.
  */
 void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight);
 
 /**
- *	netif_tx_napi_add - initialize a napi context
+ *	netif_tx_napi_add - initialize a NAPI context
  *	@dev:  network device
- *	@napi: napi context
+ *	@napi: NAPI context
  *	@poll: polling function
  *	@weight: default weight
  *
@@ -2061,22 +2059,22 @@ static inline void netif_tx_napi_add(struct net_device *dev,
 }
 
 /**
- *  netif_napi_del - remove a napi context
- *  @napi: napi context
+ *  netif_napi_del - remove a NAPI context
+ *  @napi: NAPI context
  *
- *  netif_napi_del() removes a napi context from the network device napi list
+ *  netif_napi_del() removes a NAPI context from the network device NAPI list
  */
 void netif_napi_del(struct napi_struct *napi);
 
 struct napi_gro_cb {
 	/* Virtual address of skb_shinfo(skb)->frags[0].page + offset. */
-	void *frag0;
+	void	*frag0;
 
 	/* Length of frag0. */
 	unsigned int frag0_len;
 
 	/* This indicates where we are processing relative to skb->data. */
-	int data_offset;
+	int	data_offset;
 
 	/* This is non-zero if the packet cannot be merged with the new skb. */
 	u16	flush;
@@ -2172,7 +2170,7 @@ struct udp_offload {
 	struct udp_offload_callbacks callbacks;
 };
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
+/* often modified stats are per-CPU, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
 	u64     rx_bytes;
@@ -2269,7 +2267,7 @@ struct netdev_notifier_changeupper_info {
 	struct netdev_notifier_info info; /* must be first */
 	struct net_device *upper_dev; /* new upper dev */
 	bool master; /* is upper dev master */
-	bool linking; /* is the nofication for link or unlink */
+	bool linking; /* is the notification for link or unlink */
 	void *upper_info; /* upper dev info */
 };
 
@@ -2734,7 +2732,7 @@ extern int netdev_flow_limit_table_len;
 #endif /* CONFIG_NET_FLOW_LIMIT */
 
 /*
- * Incoming packets are placed on per-cpu queues
+ * Incoming packets are placed on per-CPU queues
  */
 struct softnet_data {
 	struct list_head	poll_list;
@@ -2904,7 +2902,7 @@ netif_xmit_frozen_or_drv_stopped(const struct netdev_queue *dev_queue)
  *	@dev_queue: pointer to transmit queue
  *
  * BQL enabled drivers might use this helper in their ndo_start_xmit(),
- * to give appropriate hint to the cpu.
+ * to give appropriate hint to the CPU.
  */
 static inline void netdev_txq_bql_enqueue_prefetchw(struct netdev_queue *dev_queue)
 {
@@ -2918,7 +2916,7 @@ static inline void netdev_txq_bql_enqueue_prefetchw(struct netdev_queue *dev_que
  *	@dev_queue: pointer to transmit queue
  *
  * BQL enabled drivers might use this helper in their TX completion path,
- * to give appropriate hint to the cpu.
+ * to give appropriate hint to the CPU.
  */
 static inline void netdev_txq_bql_complete_prefetchw(struct netdev_queue *dev_queue)
 {
@@ -3057,7 +3055,7 @@ static inline bool netif_running(const struct net_device *dev)
 }
 
 /*
- * Routines to manage the subqueues on a device.  We only need start
+ * Routines to manage the subqueues on a device.  We only need start,
  * stop, and a check if it's stopped.  All other device management is
  * done at the overall netdevice level.
  * Also test the device if we're multiqueue.
@@ -3341,7 +3339,6 @@ void netif_carrier_off(struct net_device *dev);
  * in a "pending" state, waiting for some external event.  For "on-
  * demand" interfaces, this new state identifies the situation where the
  * interface is waiting for events to place it in the up state.
- *
  */
 static inline void netif_dormant_on(struct net_device *dev)
 {
@@ -3676,7 +3673,7 @@ void dev_uc_init(struct net_device *dev);
  *
  *  Add newly added addresses to the interface, and release
  *  addresses that have been deleted.
- **/
+ */
 static inline int __dev_uc_sync(struct net_device *dev,
 				int (*sync)(struct net_device *,
 					    const unsigned char *),
@@ -3692,7 +3689,7 @@ static inline int __dev_uc_sync(struct net_device *dev,
  *  @unsync: function to call if address should be removed
  *
  *  Remove all addresses that were added to the device by dev_uc_sync().
- **/
+ */
 static inline void __dev_uc_unsync(struct net_device *dev,
 				   int (*unsync)(struct net_device *,
 						 const unsigned char *))
@@ -3720,7 +3717,7 @@ void dev_mc_init(struct net_device *dev);
  *
  *  Add newly added addresses to the interface, and release
  *  addresses that have been deleted.
- **/
+ */
 static inline int __dev_mc_sync(struct net_device *dev,
 				int (*sync)(struct net_device *,
 					    const unsigned char *),
@@ -3736,7 +3733,7 @@ static inline int __dev_mc_sync(struct net_device *dev,
  *  @unsync: function to call if address should be removed
  *
  *  Remove all addresses that were added to the device by dev_mc_sync().
- **/
+ */
 static inline void __dev_mc_unsync(struct net_device *dev,
 				   int (*unsync)(struct net_device *,
 						 const unsigned char *))
