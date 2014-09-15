From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/3] bonding: trivial: style and comment fixes
Date: Mon, 15 Sep 2014 17:19:34 +0200
Message-ID: <1410794375-7386-3-git-send-email-nikolay@redhat.com>
References: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331AbaIOPUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 11:20:08 -0400
In-Reply-To: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First adjust a couple of locking comments that were left inaccurate,
then adjust comments to use the netdev styling and remove extra new
lines where necessary and add a couple of new lines between declarations
and code. These are all trivial styling changes, no functional change.
Also removed a couple of outdated or obvious comments.
This patch is by no means a complete fix of all netdev style violations
but it gets the bonding closer.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c     |   5 +-
 drivers/net/bonding/bond_alb.c     |  48 ++++-----
 drivers/net/bonding/bond_debugfs.c |   4 +-
 drivers/net/bonding/bond_main.c    | 199 +++++++++++++------------------------
 drivers/net/bonding/bond_sysfs.c   |   1 -
 drivers/net/bonding/bonding.h      |   3 +-
 6 files changed, 93 insertions(+), 167 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 2bb360f32a64..7e9e522fd476 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -297,15 +297,14 @@ static u16 __get_link_speed(struct port *port)
 static u8 __get_duplex(struct port *port)
 {
 	struct slave *slave = port->slave;
-
 	u8 retval;
 
 	/* handling a special case: when the configuration starts with
 	 * link down, it sets the duplex to 0.
 	 */
-	if (slave->link != BOND_LINK_UP)
+	if (slave->link != BOND_LINK_UP) {
 		retval = 0x0;
-	else {
+	} else {
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval = 0x1;
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 4efdeb67ab7c..615f3bebd019 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -261,14 +261,15 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index,
 					u32 skb_len)
 {
 	struct slave *tx_slave;
-	/*
-	 * We don't need to disable softirq here, becase
+
+	/* We don't need to disable softirq here, becase
 	 * tlb_choose_channel() is only called by bond_alb_xmit()
 	 * which already has softirq disabled.
 	 */
 	spin_lock(&bond->mode_lock);
 	tx_slave = __tlb_choose_channel(bond, hash_index, skb_len);
 	spin_unlock(&bond->mode_lock);
+
 	return tx_slave;
 }
 
@@ -569,7 +570,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 			netdev_err(bond->dev, "found a client with no channel in the client's hash table\n");
 			continue;
 		}
-		/*update all clients using this src_ip, that are not assigned
+		/* update all clients using this src_ip, that are not assigned
 		 * to the team's address (curr_active_slave) and have a known
 		 * unicast mac address.
 		 */
@@ -695,9 +696,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		return NULL;
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
-		/* the arp must be sent on the selected
-		* rx channel
-		*/
+		/* the arp must be sent on the selected rx channel */
 		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave)
 			ether_addr_copy(arp->mac_src, tx_slave->dev->dev_addr);
@@ -756,7 +755,7 @@ static void rlb_rebalance(struct bonding *bond)
 	spin_unlock_bh(&bond->mode_lock);
 }
 
-/* Caller must hold rx_hashtbl lock */
+/* Caller must hold mode_lock */
 static void rlb_init_table_entry_dst(struct rlb_client_info *entry)
 {
 	entry->used_next = RLB_NULL_INDEX;
@@ -844,8 +843,9 @@ static void rlb_src_link(struct bonding *bond, u32 ip_src_hash, u32 ip_dst_hash)
 	bond_info->rx_hashtbl[ip_src_hash].src_first = ip_dst_hash;
 }
 
-/* deletes all rx_hashtbl entries with  arp->ip_src if their mac_src does
- * not match arp->mac_src */
+/* deletes all rx_hashtbl entries with arp->ip_src if their mac_src does
+ * not match arp->mac_src
+ */
 static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -1022,8 +1022,9 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
 		return 0;
 	}
 
-	/* for rlb each slave must have a unique hw mac addresses so that */
-	/* each slave will receive packets destined to a different mac */
+	/* for rlb each slave must have a unique hw mac addresses so that
+	 * each slave will receive packets destined to a different mac
+	 */
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
 	if (dev_set_mac_address(dev, &s_addr)) {
@@ -1034,13 +1035,10 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
 	return 0;
 }
 
-/*
- * Swap MAC addresses between two slaves.
+/* Swap MAC addresses between two slaves.
  *
  * Called with RTNL held, and no other locks.
- *
  */
-
 static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
 {
 	u8 tmp_mac_addr[ETH_ALEN];
@@ -1051,8 +1049,7 @@ static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
 
 }
 
-/*
- * Send learning packets after MAC address swap.
+/* Send learning packets after MAC address swap.
  *
  * Called with RTNL and no other locks
  */
@@ -1125,7 +1122,6 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 		found_slave = bond_slave_has_mac(bond, slave->perm_hwaddr);
 
 		if (found_slave) {
-			/* locking: needs RTNL and nothing else */
 			alb_swap_mac_addr(slave, found_slave);
 			alb_fasten_mac_swap(bond, slave, found_slave);
 		}
@@ -1174,7 +1170,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 			return 0;
 
 		/* Try setting slave mac to bond address and fall-through
-		   to code handling that situation below... */
+		 * to code handling that situation below...
+		 */
 		alb_set_slave_mac_addr(slave, bond->dev->dev_addr);
 	}
 
@@ -1282,7 +1279,6 @@ int bond_alb_initialize(struct bonding *bond, int rlb_enabled)
 
 	if (rlb_enabled) {
 		bond->alb_info.rlb_enabled = 1;
-		/* initialize rlb */
 		res = rlb_initialize(bond);
 		if (res) {
 			tlb_deinitialize(bond);
@@ -1306,7 +1302,7 @@ void bond_alb_deinitialize(struct bonding *bond)
 }
 
 static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
-		struct slave *tx_slave)
+			    struct slave *tx_slave)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct ethhdr *eth_data = eth_hdr(skb);
@@ -1554,13 +1550,11 @@ void bond_alb_monitor(struct work_struct *work)
 		bond_info->tx_rebalance_counter = 0;
 	}
 
-	/* handle rlb stuff */
 	if (bond_info->rlb_enabled) {
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
-			/*
-			 * dev_set_promiscuity requires rtnl and
+			/* dev_set_promiscuity requires rtnl and
 			 * nothing else.  Avoid race with bond_close.
 			 */
 			rcu_read_unlock();
@@ -1630,8 +1624,7 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	return 0;
 }
 
-/*
- * Remove slave from tlb and rlb hash tables, and fix up MAC addresses
+/* Remove slave from tlb and rlb hash tables, and fix up MAC addresses
  * if necessary.
  *
  * Caller must hold RTNL and no other locks
@@ -1718,8 +1711,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	if (!swap_slave)
 		swap_slave = bond_slave_has_mac(bond, bond->dev->dev_addr);
 
-	/*
-	 * Arrange for swap_slave and new_slave to temporarily be
+	/* Arrange for swap_slave and new_slave to temporarily be
 	 * ignored so we can mess with their MAC addresses without
 	 * fear of interference from transmit activity.
 	 */
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 652f6c5d1bf7..8f99082f90eb 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -13,9 +13,7 @@
 
 static struct dentry *bonding_debug_root;
 
-/*
- *  Show RLB hash table
- */
+/* Show RLB hash table */
 static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
 {
 	struct bonding *bond = m->private;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2d90a8b7f62e..943a899fbfde 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -253,8 +253,7 @@ void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 		dev_queue_xmit(skb);
 }
 
-/*
- * In the following 2 functions, bond_vlan_rx_add_vid and bond_vlan_rx_kill_vid,
+/* In the following 2 functions, bond_vlan_rx_add_vid and bond_vlan_rx_kill_vid,
  * We don't protect the slave list iteration with a lock because:
  * a. This operation is performed in IOCTL context,
  * b. The operation is protected by the RTNL semaphore in the 8021q code,
@@ -326,8 +325,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 
 /*------------------------------- Link status -------------------------------*/
 
-/*
- * Set the carrier state for the master according to the state of its
+/* Set the carrier state for the master according to the state of its
  * slaves.  If any slaves are up, the master is up.  In 802.3ad mode,
  * do special 802.3ad magic.
  *
@@ -362,8 +360,7 @@ down:
 	return 0;
 }
 
-/*
- * Get link speed and duplex from the slave's base driver
+/* Get link speed and duplex from the slave's base driver
  * using ethtool. If for some reason the call fails or the
  * values are invalid, set speed and duplex to -1,
  * and return.
@@ -416,8 +413,7 @@ const char *bond_slave_link_status(s8 link)
 	}
 }
 
-/*
- * if <dev> supports MII link status reporting, check its link status.
+/* if <dev> supports MII link status reporting, check its link status.
  *
  * We either do MII/ETHTOOL ioctls, or check netif_carrier_ok(),
  * depending upon the setting of the use_carrier parameter.
@@ -454,14 +450,14 @@ static int bond_check_dev_link(struct bonding *bond,
 	/* Ethtool can't be used, fallback to MII ioctls. */
 	ioctl = slave_ops->ndo_do_ioctl;
 	if (ioctl) {
-		/* TODO: set pointer to correct ioctl on a per team member */
-		/*       bases to make this more efficient. that is, once  */
-		/*       we determine the correct ioctl, we will always    */
-		/*       call it and not the others for that team          */
-		/*       member.                                           */
-
-		/*
-		 * We cannot assume that SIOCGMIIPHY will also read a
+		/* TODO: set pointer to correct ioctl on a per team member
+		 *       bases to make this more efficient. that is, once
+		 *       we determine the correct ioctl, we will always
+		 *       call it and not the others for that team
+		 *       member.
+		 */
+
+		/* We cannot assume that SIOCGMIIPHY will also read a
 		 * register; not all network drivers (e.g., e100)
 		 * support that.
 		 */
@@ -476,8 +472,7 @@ static int bond_check_dev_link(struct bonding *bond,
 		}
 	}
 
-	/*
-	 * If reporting, report that either there's no dev->do_ioctl,
+	/* If reporting, report that either there's no dev->do_ioctl,
 	 * or both SIOCGMIIREG and get_link failed (meaning that we
 	 * cannot report link status).  If not reporting, pretend
 	 * we're ok.
@@ -487,9 +482,7 @@ static int bond_check_dev_link(struct bonding *bond,
 
 /*----------------------------- Multicast list ------------------------------*/
 
-/*
- * Push the promiscuity flag down to appropriate slaves
- */
+/* Push the promiscuity flag down to appropriate slaves */
 static int bond_set_promiscuity(struct bonding *bond, int inc)
 {
 	struct list_head *iter;
@@ -512,9 +505,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	return err;
 }
 
-/*
- * Push the allmulti flag down to all slaves
- */
+/* Push the allmulti flag down to all slaves */
 static int bond_set_allmulti(struct bonding *bond, int inc)
 {
 	struct list_head *iter;
@@ -537,8 +528,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	return err;
 }
 
-/*
- * Retrieve the list of registered multicast addresses for the bonding
+/* Retrieve the list of registered multicast addresses for the bonding
  * device and retransmit an IGMP JOIN request to the current active
  * slave.
  */
@@ -560,8 +550,7 @@ static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 	rtnl_unlock();
 }
 
-/* Flush bond's hardware addresses from slave
- */
+/* Flush bond's hardware addresses from slave */
 static void bond_hw_addr_flush(struct net_device *bond_dev,
 			       struct net_device *slave_dev)
 {
@@ -632,8 +621,7 @@ static void bond_set_dev_addr(struct net_device *bond_dev,
 	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
 }
 
-/*
- * bond_do_fail_over_mac
+/* bond_do_fail_over_mac
  *
  * Perform special MAC address swapping for fail_over_mac settings
  *
@@ -653,8 +641,7 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			bond_set_dev_addr(bond->dev, new_active->dev);
 		break;
 	case BOND_FOM_FOLLOW:
-		/*
-		 * if new_active && old_active, swap them
+		/* if new_active && old_active, swap them
 		 * if just old_active, do nothing (going to no active slave)
 		 * if just new_active, set new_active to bond's MAC
 		 */
@@ -863,7 +850,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	/* resend IGMP joins since active slave has changed or
 	 * all were sent on curr_active_slave.
 	 * resend only if bond is brought up with the affected
-	 * bonding modes and the retransmission is enabled */
+	 * bonding modes and the retransmission is enabled
+	 */
 	if (netif_running(bond->dev) && (bond->params.resend_igmp > 0) &&
 	    ((bond_uses_primary(bond) && new_active) ||
 	     BOND_MODE(bond) == BOND_MODE_ROUNDROBIN)) {
@@ -1229,8 +1217,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			   slave_dev->name);
 	}
 
-	/*
-	 * Old ifenslave binaries are no longer supported.  These can
+	/* Old ifenslave binaries are no longer supported.  These can
 	 * be identified with moderate accuracy by the state of the slave:
 	 * the current ifenslave will set the interface down prior to
 	 * enslaving it; the old ifenslave will not.
@@ -1302,7 +1289,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	call_netdevice_notifiers(NETDEV_JOIN, slave_dev);
 
 	/* If this is the first slave, then we need to set the master's hardware
-	 * address to be the same as the slave's. */
+	 * address to be the same as the slave's.
+	 */
 	if (!bond_has_slaves(bond) &&
 	    bond->dev->addr_assign_type == NET_ADDR_RANDOM)
 		bond_set_dev_addr(bond->dev, slave_dev);
@@ -1315,8 +1303,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	new_slave->bond = bond;
 	new_slave->dev = slave_dev;
-	/*
-	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
+	/* Set the new_slave's queue_id to be zero.  Queue ID mapping
 	 * is set via sysfs or module option if desired.
 	 */
 	new_slave->queue_id = 0;
@@ -1329,8 +1316,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_free;
 	}
 
-	/*
-	 * Save slave's original ("permanent") mac address for modes
+	/* Save slave's original ("permanent") mac address for modes
 	 * that need it, and for restoring it upon release, and then
 	 * set it to the master's address
 	 */
@@ -1338,8 +1324,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (!bond->params.fail_over_mac ||
 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
-		/*
-		 * Set slave to master's mac address.  The application already
+		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
 		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
@@ -1425,8 +1410,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
 
 		if ((link_reporting == -1) && !bond->params.arp_interval) {
-			/*
-			 * miimon is set but a bonded network driver
+			/* miimon is set but a bonded network driver
 			 * does not support ETHTOOL/MII and
 			 * arp_interval is not set.  Note: if
 			 * use_carrier is enabled, we will never go
@@ -1626,8 +1610,7 @@ err_undo_flags:
 	return res;
 }
 
-/*
- * Try to release the slave device <slave> from the bond device <master>
+/* Try to release the slave device <slave> from the bond device <master>
  * It is legal to access curr_active_slave without a lock because all the function
  * is RTNL-locked. If "all" is true it means that the function is being called
  * while destroying a bond interface and all slaves are being released.
@@ -1713,8 +1696,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (all) {
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 	} else if (oldcurrent == slave) {
-		/*
-		 * Note that we hold RTNL over this sequence, so there
+		/* Note that we hold RTNL over this sequence, so there
 		 * is no concern that another slave add/remove event
 		 * will interfere.
 		 */
@@ -1741,10 +1723,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 		netdev_info(bond_dev, "last VLAN challenged slave %s left bond %s - VLAN blocking is removed\n",
 			    slave_dev->name, bond_dev->name);
 
-	/* must do this from outside any spinlocks */
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
 
-	/* If the mode uses primary, then this cases was handled above by
+	/* If the mode uses primary, then this case was handled above by
 	 * bond_change_active_slave(..., NULL)
 	 */
 	if (!bond_uses_primary(bond)) {
@@ -1784,7 +1765,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	bond_free_slave(slave);
 
-	return 0;  /* deletion OK */
+	return 0;
 }
 
 /* A wrapper used because of ndo_del_link */
@@ -1793,10 +1774,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	return __bond_release_one(bond_dev, slave_dev, false);
 }
 
-/*
-* First release a slave and then destroy the bond if no more slaves are left.
-* Must be under rtnl_lock when this function is called.
-*/
+/* First release a slave and then destroy the bond if no more slaves are left.
+ * Must be under rtnl_lock when this function is called.
+ */
 static int  bond_release_and_destroy(struct net_device *bond_dev,
 				     struct net_device *slave_dev)
 {
@@ -1819,7 +1799,6 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 
 	info->bond_mode = BOND_MODE(bond);
 	info->miimon = bond->params.miimon;
-
 	info->num_slaves = bond->slave_cnt;
 
 	return 0;
@@ -1882,9 +1861,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			/*FALLTHRU*/
 		case BOND_LINK_FAIL:
 			if (link_state) {
-				/*
-				 * recovered before downdelay expired
-				 */
+				/* recovered before downdelay expired */
 				slave->link = BOND_LINK_UP;
 				slave->last_link_up = jiffies;
 				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
@@ -2036,8 +2013,7 @@ do_failover:
 	bond_set_carrier(bond);
 }
 
-/*
- * bond_mii_monitor
+/* bond_mii_monitor
  *
  * Really a wrapper that splits the mii monitor into two phases: an
  * inspection, then (if inspection indicates something needs to be done)
@@ -2109,8 +2085,7 @@ static bool bond_has_this_ip(struct bonding *bond, __be32 ip)
 	return ret;
 }
 
-/*
- * We go to the (large) trouble of VLAN tagging ARP frames because
+/* We go to the (large) trouble of VLAN tagging ARP frames because
  * switches in VLAN mode (especially if ports are configured as
  * "native" to a VLAN) might not pass non-tagged frames.
  */
@@ -2337,8 +2312,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 
 	curr_active_slave = rcu_dereference(bond->curr_active_slave);
 
-	/*
-	 * Backup slaves won't see the ARP reply, but do come through
+	/* Backup slaves won't see the ARP reply, but do come through
 	 * here for each ARP probe (so we swap the sip/tip to validate
 	 * the probe).  In a "redundant switch, common router" type of
 	 * configuration, the ARP probe will (hopefully) travel from
@@ -2378,8 +2352,7 @@ static bool bond_time_in_interval(struct bonding *bond, unsigned long last_act,
 			     last_act + mod * delta_in_ticks + delta_in_ticks/2);
 }
 
-/*
- * this function is called regularly to monitor each slave's link
+/* This function is called regularly to monitor each slave's link
  * ensuring that traffic is being sent and received when arp monitoring
  * is used in load-balancing mode. if the adapter has been dormant, then an
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
@@ -2488,8 +2461,7 @@ re_arm:
 				   msecs_to_jiffies(bond->params.arp_interval));
 }
 
-/*
- * Called to inspect slaves for active-backup mode ARP monitor link state
+/* Called to inspect slaves for active-backup mode ARP monitor link state
  * changes.  Sets new_link in slaves to specify what action should take
  * place for the slave.  Returns 0 if no changes are found, >0 if changes
  * to link states must be committed.
@@ -2515,16 +2487,14 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 			continue;
 		}
 
-		/*
-		 * Give slaves 2*delta after being enslaved or made
+		/* Give slaves 2*delta after being enslaved or made
 		 * active.  This avoids bouncing, as the last receive
 		 * times need a full ARP monitor cycle to be updated.
 		 */
 		if (bond_time_in_interval(bond, slave->last_link_up, 2))
 			continue;
 
-		/*
-		 * Backup slave is down if:
+		/* Backup slave is down if:
 		 * - No current_arp_slave AND
 		 * - more than 3*delta since last receive AND
 		 * - the bond has an IP address
@@ -2543,8 +2513,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 			commit++;
 		}
 
-		/*
-		 * Active slave is down if:
+		/* Active slave is down if:
 		 * - more than 2*delta since transmitting OR
 		 * - (more than 2*delta since receive AND
 		 *    the bond has an IP address)
@@ -2561,8 +2530,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 	return commit;
 }
 
-/*
- * Called to commit link state changes noted by inspection step of
+/* Called to commit link state changes noted by inspection step of
  * active-backup mode ARP monitor.
  *
  * Called with RTNL hold.
@@ -2639,8 +2607,7 @@ do_failover:
 	bond_set_carrier(bond);
 }
 
-/*
- * Send ARP probes for active-backup mode ARP monitor.
+/* Send ARP probes for active-backup mode ARP monitor.
  *
  * Called with rcu_read_lock held.
  */
@@ -2782,9 +2749,7 @@ re_arm:
 
 /*-------------------------- netdev event handling --------------------------*/
 
-/*
- * Change device name
- */
+/* Change device name */
 static int bond_event_changename(struct bonding *bond)
 {
 	bond_remove_proc_entry(bond);
@@ -2861,13 +2826,9 @@ static int bond_slave_netdev_event(unsigned long event,
 		}
 		break;
 	case NETDEV_DOWN:
-		/*
-		 * ... Or is it this?
-		 */
 		break;
 	case NETDEV_CHANGEMTU:
-		/*
-		 * TODO: Should slaves be allowed to
+		/* TODO: Should slaves be allowed to
 		 * independently alter their MTU?  For
 		 * an active-backup bond, slaves need
 		 * not be the same type of device, so
@@ -2916,8 +2877,7 @@ static int bond_slave_netdev_event(unsigned long event,
 	return NOTIFY_DONE;
 }
 
-/*
- * bond_netdev_event: handle netdev notifier chain events.
+/* bond_netdev_event: handle netdev notifier chain events.
  *
  * This function receives events for the netdev chain.  The caller (an
  * ioctl handler calling blocking_notifier_call_chain) holds the necessary
@@ -3187,8 +3147,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		mii->phy_id = 0;
 		/* Fall Through */
 	case SIOCGMIIREG:
-		/*
-		 * We do this again just in case we were called by SIOCGMIIREG
+		/* We do this again just in case we were called by SIOCGMIIREG
 		 * instead of SIOCGMIIPHY.
 		 */
 		mii = if_mii(ifr);
@@ -3229,7 +3188,6 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 		return res;
 	default:
-		/* Go on */
 		break;
 	}
 
@@ -3291,7 +3249,6 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 	struct list_head *iter;
 	struct slave *slave;
 
-
 	rcu_read_lock();
 	if (bond_uses_primary(bond)) {
 		slave = rcu_dereference(bond->curr_active_slave);
@@ -3329,8 +3286,7 @@ static int bond_neigh_init(struct neighbour *n)
 	if (ret)
 		return ret;
 
-	/*
-	 * Assign slave's neigh_cleanup to neighbour in case cleanup is called
+	/* Assign slave's neigh_cleanup to neighbour in case cleanup is called
 	 * after the last slave has been detached.  Assumes that all slaves
 	 * utilize the same neigh_cleanup (true at this writing as only user
 	 * is ipoib).
@@ -3343,8 +3299,7 @@ static int bond_neigh_init(struct neighbour *n)
 	return parms.neigh_setup(n);
 }
 
-/*
- * The bonding ndo_neigh_setup is called at init time beofre any
+/* The bonding ndo_neigh_setup is called at init time beofre any
  * slave exists. So we must declare proxy setup function which will
  * be used at run time to resolve the actual slave neigh param setup.
  *
@@ -3362,9 +3317,7 @@ static int bond_neigh_setup(struct net_device *dev,
 	return 0;
 }
 
-/*
- * Change the MTU of all of a master's slaves to match the master
- */
+/* Change the MTU of all of a master's slaves to match the master */
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3417,8 +3370,7 @@ unwind:
 	return res;
 }
 
-/*
- * Change HW address
+/* Change HW address
  *
  * Note that many devices must be down to change the HW address, and
  * downing the master releases all slaves.  We can make bonds full of
@@ -3588,8 +3540,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	return NETDEV_TX_OK;
 }
 
-/*
- * in active-backup mode, we know that bond->curr_active_slave is always valid if
+/* In active-backup mode, we know that bond->curr_active_slave is always valid if
  * the bond has a usable interface.
  */
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_dev)
@@ -3651,9 +3602,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 
 /*------------------------- Device initialization ---------------------------*/
 
-/*
- * Lookup the slave that corresponds to a qid
- */
+/* Lookup the slave that corresponds to a qid */
 static inline int bond_slave_override(struct bonding *bond,
 				      struct sk_buff *skb)
 {
@@ -3682,17 +3631,14 @@ static inline int bond_slave_override(struct bonding *bond,
 static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb,
 			     void *accel_priv, select_queue_fallback_t fallback)
 {
-	/*
-	 * This helper function exists to help dev_pick_tx get the correct
+	/* This helper function exists to help dev_pick_tx get the correct
 	 * destination queue.  Using a helper function skips a call to
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
 	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
 
-	/*
-	 * Save the original txq to restore before passing to the driver
-	 */
+	/* Save the original txq to restore before passing to the driver */
 	qdisc_skb_cb(skb)->slave_dev_queue_mapping = skb->queue_mapping;
 
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
@@ -3740,8 +3686,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bonding *bond = netdev_priv(dev);
 	netdev_tx_t ret = NETDEV_TX_OK;
 
-	/*
-	 * If we risk deadlock from transmitting this in the
+	/* If we risk deadlock from transmitting this in the
 	 * netpoll path, tell netpoll to queue the frame for later tx
 	 */
 	if (unlikely(is_netpoll_tx_blocked(dev)))
@@ -3865,8 +3810,7 @@ void bond_setup(struct net_device *bond_dev)
 	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
-	/* don't acquire bond device's netif_tx_lock when
-	 * transmitting */
+	/* don't acquire bond device's netif_tx_lock when transmitting */
 	bond_dev->features |= NETIF_F_LLTX;
 
 	/* By default, we declare the bond to be fully
@@ -3889,10 +3833,9 @@ void bond_setup(struct net_device *bond_dev)
 	bond_dev->features |= bond_dev->hw_features;
 }
 
-/*
-* Destroy a bonding device.
-* Must be under rtnl_lock when this function is called.
-*/
+/* Destroy a bonding device.
+ * Must be under rtnl_lock when this function is called.
+ */
 static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3920,9 +3863,7 @@ static int bond_check_params(struct bond_params *params)
 	const struct bond_opt_value *valptr;
 	int arp_all_targets_value;
 
-	/*
-	 * Convert string parameters.
-	 */
+	/* Convert string parameters. */
 	if (mode) {
 		bond_opt_initstr(&newval, mode);
 		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_MODE), &newval);
@@ -4099,9 +4040,9 @@ static int bond_check_params(struct bond_params *params)
 
 	for (arp_ip_count = 0, i = 0;
 	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[i]; i++) {
-		/* not complete check, but should be good enough to
-		   catch mistakes */
 		__be32 ip;
+
+		/* not a complete check, but good enough to catch mistakes */
 		if (!in4_pton(arp_ip_target[i], -1, (u8 *)&ip, -1, NULL) ||
 		    !bond_is_ip_target_ok(ip)) {
 			pr_warn("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
@@ -4284,9 +4225,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
 }
 
-/*
- * Called from registration process
- */
+/* Called from registration process */
 static int bond_init(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -4440,9 +4379,7 @@ static void __exit bonding_exit(void)
 	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	/*
-	 * Make sure we don't have an imbalance on our netpoll blocking
-	 */
+	/* Make sure we don't have an imbalance on our netpoll blocking */
 	WARN_ON(atomic_read(&netpoll_block_tx));
 #endif
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 5555517284db..8ffbafd500fd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -91,7 +91,6 @@ static struct net_device *bond_get_by_name(struct bond_net *bn, const char *ifna
  * creates and deletes entire bonds.
  *
  * The class parameter is ignored.
- *
  */
 static ssize_t bonding_store_bonds(struct class *cls,
 				   struct class_attribute *attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 3aff1a815e89..6140bf0264a4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -197,7 +197,8 @@ struct bonding {
 			      struct slave *);
 	/* mode_lock is used for mode-specific locking needs, currently used by:
 	 * 3ad mode (4) - protect against running bond_3ad_unbind_slave() and
-	 *                bond_3ad_state_machine_handler() concurrently.
+	 *                bond_3ad_state_machine_handler() concurrently and also
+	 *                the access to the state machine shared variables.
 	 * TLB mode (5) - to sync the use and modifications of its hash table
 	 * ALB mode (6) - to sync the use and modifications of its hash table
 	 */
-- 
1.9.3
