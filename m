From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/4] bonding: Neaten pr_<level>
Date: Sat, 15 Feb 2014 16:01:45 -0800
Message-ID: <37c734a41415d391c6de70ae89ee977da61ff7d0.1392508410.git.joe@perches.com>
References: <cover.1392508410.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392508410.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing terminating newlines.
Convert uses of pr_info to pr_cont in bond_check_params.
Standardize upper/lower case styles.
Typo fixes, remove unnecessary parentheses and periods.
Alignment neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c     |  11 ++--
 drivers/net/bonding/bond_main.c    | 103 ++++++++++++++++++-------------------
 drivers/net/bonding/bond_netlink.c |   6 +--
 drivers/net/bonding/bond_options.c | 102 +++++++++++++++++-------------------
 drivers/net/bonding/bond_procfs.c  |   2 +-
 drivers/net/bonding/bond_sysfs.c   |   8 +--
 6 files changed, 110 insertions(+), 122 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cce1f1b..f6eda2d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1079,7 +1079,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			/* detect loopback situation */
 			if (MAC_ADDRESS_EQUAL(&(lacpdu->actor_system),
 					      &(port->actor_system))) {
-				pr_err("%s: An illegal loopback occurred on adapter (%s).\nCheck the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
+				pr_err("%s: An illegal loopback occurred on adapter (%s)\n"
+				       "Check the configuration to verify that all adapters are connected to 802.3ad compliant switch ports\n",
 				       port->slave->bond->dev->name,
 				       port->slave->dev->name);
 				return;
@@ -1950,7 +1951,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			 * new aggregator
 			 */
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
-				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n",
+				pr_debug("Some port(s) related to LAG %d - replacing with LAG %d\n",
 					 aggregator->aggregator_identifier,
 					 new_aggregator->aggregator_identifier);
 
@@ -2300,9 +2301,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
 					     ~AD_SPEED_KEY_BITS);
 	}
-	pr_debug("Port %d changed link status to %s",
-		port->actor_port_number,
-		(link == BOND_LINK_UP) ? "UP" : "DOWN");
+	pr_debug("Port %d changed link status to %s\n",
+		 port->actor_port_number,
+		 link == BOND_LINK_UP ? "UP" : "DOWN");
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
 	 */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1d4dfc9..90994ed 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -802,7 +802,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
-				pr_info("%s: making interface %s the new active one %d ms earlier.\n",
+				pr_info("%s: making interface %s the new active one %d ms earlier\n",
 					bond->dev->name, new_active->dev->name,
 					(bond->params.updelay - new_active->delay) * bond->params.miimon);
 			}
@@ -817,7 +817,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
 			if (USES_PRIMARY(bond->params.mode)) {
-				pr_info("%s: making interface %s the new active one.\n",
+				pr_info("%s: making interface %s the new active one\n",
 					bond->dev->name, new_active->dev->name);
 			}
 		}
@@ -906,7 +906,7 @@ void bond_select_active_slave(struct bonding *bond)
 			pr_info("%s: first active interface up!\n",
 				bond->dev->name);
 		} else {
-			pr_info("%s: now running without any active interface !\n",
+			pr_info("%s: now running without any active interface!\n",
 				bond->dev->name);
 		}
 	}
@@ -1189,7 +1189,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* already enslaved */
 	if (slave_dev->flags & IFF_SLAVE) {
-		pr_debug("Error, Device was already enslaved\n");
+		pr_debug("Error: Device was already enslaved\n");
 		return -EBUSY;
 	}
 
@@ -1217,7 +1217,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * enslaving it; the old ifenslave will not.
 	 */
 	if ((slave_dev->flags & IFF_UP)) {
-		pr_err("%s is up. This may be due to an out of date ifenslave.\n",
+		pr_err("%s is up - this may be due to an out of date ifenslave\n",
 		       slave_dev->name);
 		res = -EPERM;
 		goto err_undo_flags;
@@ -1261,24 +1261,23 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 						 bond_dev);
 		}
 	} else if (bond_dev->type != slave_dev->type) {
-		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it.\n",
-		       slave_dev->name,
-		       slave_dev->type, bond_dev->type);
+		pr_err("%s ether type (%d) is different from other slaves (%d), can not enslave it\n",
+		       slave_dev->name, slave_dev->type, bond_dev->type);
 		res = -EINVAL;
 		goto err_undo_flags;
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
 		if (!bond_has_slaves(bond)) {
-			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address.\n",
+			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address\n",
 				bond_dev->name);
 			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
 				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
-				pr_warn("%s: Setting fail_over_mac to active for active-backup mode.\n",
+				pr_warn("%s: Setting fail_over_mac to active for active-backup mode\n",
 					bond_dev->name);
 			}
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
-			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
+			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active\n",
 			       bond_dev->name);
 			res = -EOPNOTSUPP;
 			goto err_undo_flags;
@@ -1450,8 +1449,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (new_slave->link != BOND_LINK_DOWN)
 		new_slave->jiffies = jiffies;
 	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
-		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
-			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
+		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
+		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
@@ -1510,9 +1509,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	slave_dev->npinfo = bond->dev->npinfo;
 	if (slave_dev->npinfo) {
 		if (slave_enable_netpoll(new_slave)) {
-			pr_info("Error, %s: master_dev is using netpoll, "
-				 "but new slave device does not support netpoll.\n",
-				 bond_dev->name);
+			pr_info("Error, %s: master_dev is using netpoll, but new slave device does not support netpoll\n",
+				bond_dev->name);
 			res = -EBUSY;
 			goto err_detach;
 		}
@@ -1548,10 +1546,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
-	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
+	pr_info("%s: Enslaving %s as %s interface with %s link\n",
 		bond_dev->name, slave_dev->name,
-		bond_is_active_slave(new_slave) ? "n active" : " backup",
-		new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
+		bond_is_active_slave(new_slave) ? "an active" : "a backup",
+		new_slave->link != BOND_LINK_DOWN ? "an up" : "a down");
 
 	/* enslave is successful */
 	return 0;
@@ -1634,7 +1632,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    !netdev_has_upper_dev(slave_dev, bond_dev)) {
-		pr_err("%s: Error: cannot release %s.\n",
+		pr_err("%s: Error: cannot release %s\n",
 		       bond_dev->name, slave_dev->name);
 		return -EINVAL;
 	}
@@ -1668,7 +1666,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	write_unlock_bh(&bond->lock);
 
-	pr_info("%s: releasing %s interface %s\n",
+	pr_info("%s: Releasing %s interface %s\n",
 		bond_dev->name,
 		bond_is_active_slave(slave) ? "active" : "backup",
 		slave_dev->name);
@@ -1681,10 +1679,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 		     bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond_has_slaves(bond))
-			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
-				   bond_dev->name, slave_dev->name,
-				   slave->perm_hwaddr,
-				   bond_dev->name, slave_dev->name);
+			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
+				bond_dev->name, slave_dev->name,
+				slave->perm_hwaddr,
+				bond_dev->name, slave_dev->name);
 	}
 
 	if (bond->primary_slave == slave)
@@ -1743,7 +1741,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	bond_compute_features(bond);
 	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
 	    (old_features & NETIF_F_VLAN_CHALLENGED))
-		pr_info("%s: last VLAN challenged slave %s left bond %s. VLAN blocking is removed\n",
+		pr_info("%s: last VLAN challenged slave %s left bond %s - VLAN blocking is removed\n",
 			bond_dev->name, slave_dev->name, bond_dev->name);
 
 	/* must do this from outside any spinlocks */
@@ -1811,7 +1809,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	ret = bond_release(bond_dev, slave_dev);
 	if (ret == 0 && !bond_has_slaves(bond)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		pr_info("%s: destroying bond %s.\n",
+		pr_info("%s: Destroying bond %s\n",
 			bond_dev->name, bond_dev->name);
 		unregister_netdevice(bond_dev);
 	}
@@ -1880,7 +1878,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
-				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms.\n",
+				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms\n",
 					bond->dev->name,
 					(bond->params.mode ==
 					 BOND_MODE_ACTIVEBACKUP) ?
@@ -1897,7 +1895,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 				 */
 				slave->link = BOND_LINK_UP;
 				slave->jiffies = jiffies;
-				pr_info("%s: link status up again after %d ms for interface %s.\n",
+				pr_info("%s: link status up again after %d ms for interface %s\n",
 					bond->dev->name,
 					(bond->params.downdelay - slave->delay) *
 					bond->params.miimon,
@@ -1922,7 +1920,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
-				pr_info("%s: link status up for interface %s, enabling it in %d ms.\n",
+				pr_info("%s: link status up for interface %s, enabling it in %d ms\n",
 					bond->dev->name, slave->dev->name,
 					ignore_updelay ? 0 :
 					bond->params.updelay *
@@ -1932,7 +1930,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				slave->link = BOND_LINK_DOWN;
-				pr_info("%s: link status down again after %d ms for interface %s.\n",
+				pr_info("%s: link status down again after %d ms for interface %s\n",
 					bond->dev->name,
 					(bond->params.updelay - slave->delay) *
 					bond->params.miimon,
@@ -1984,7 +1982,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_set_backup_slave(slave);
 			}
 
-			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
+			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex\n",
 				bond->dev->name, slave->dev->name,
 				slave->speed == SPEED_UNKNOWN ? 0 : slave->speed,
 				slave->duplex ? "full" : "half");
@@ -2132,8 +2130,8 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 {
 	struct sk_buff *skb;
 
-	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 vid %d\n", arp_op,
-		 slave_dev->name, &dest_ip, &src_ip, vlan_id);
+	pr_debug("arp %d on slave %s: dst %pI4 src %pI4 vid %d\n",
+		 arp_op, slave_dev->name, &dest_ip, &src_ip, vlan_id);
 
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
@@ -2385,7 +2383,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 				 * is closed.
 				 */
 				if (!oldcurrent) {
-					pr_info("%s: link status definitely up for interface %s, ",
+					pr_info("%s: link status definitely up for interface %s\n",
 						bond->dev->name,
 						slave->dev->name);
 					do_failover = 1;
@@ -2411,9 +2409,8 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
 
-				pr_info("%s: interface %s is now down.\n",
-					bond->dev->name,
-					slave->dev->name);
+				pr_info("%s: interface %s is now down\n",
+					bond->dev->name, slave->dev->name);
 
 				if (slave == oldcurrent)
 					do_failover = 1;
@@ -2562,7 +2559,7 @@ static void bond_ab_arp_commit(struct bonding *bond)
 					bond->current_arp_slave = NULL;
 				}
 
-				pr_info("%s: link status definitely up for interface %s.\n",
+				pr_info("%s: link status definitely up for interface %s\n",
 					bond->dev->name, slave->dev->name);
 
 				if (!bond->curr_active_slave ||
@@ -2675,7 +2672,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 
 			bond_set_slave_inactive_flags(slave);
 
-			pr_info("%s: backup interface %s is now down.\n",
+			pr_info("%s: backup interface %s is now down\n",
 				bond->dev->name, slave->dev->name);
 		}
 		if (slave == curr_arp_slave)
@@ -2861,9 +2858,9 @@ static int bond_slave_netdev_event(unsigned long event,
 			break;
 		}
 
-		pr_info("%s: Primary slave changed to %s, reselecting active slave.\n",
-			bond->dev->name, bond->primary_slave ? slave_dev->name :
-							       "none");
+		pr_info("%s: Primary slave changed to %s, reselecting active slave\n",
+			bond->dev->name,
+			bond->primary_slave ? slave_dev->name : "none");
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
@@ -2896,8 +2893,7 @@ static int bond_netdev_event(struct notifier_block *this,
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
 	pr_debug("event_dev: %s, event: %lx\n",
-		 event_dev ? event_dev->name : "None",
-		 event);
+		 event_dev ? event_dev->name : "None", event);
 
 	if (!(event_dev->priv_flags & IFF_BONDING))
 		return NOTIFY_DONE;
@@ -3352,8 +3348,8 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 	struct list_head *iter;
 	int res = 0;
 
-	pr_debug("bond=%p, name=%s, new_mtu=%d\n", bond,
-		 (bond_dev ? bond_dev->name : "None"), new_mtu);
+	pr_debug("bond=%p, name=%s, new_mtu=%d\n",
+		 bond, bond_dev ? bond_dev->name : "None", new_mtu);
 
 	/* Can't hold bond->lock with bh disabled here since
 	 * some base drivers panic. On the other hand we can't
@@ -3372,8 +3368,7 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
 	bond_for_each_slave(bond, slave, iter) {
 		pr_debug("s %p c_m %p\n",
-			 slave,
-			 slave->dev->netdev_ops->ndo_change_mtu);
+			 slave, slave->dev->netdev_ops->ndo_change_mtu);
 
 		res = dev_set_mtu(slave->dev, new_mtu);
 
@@ -3927,7 +3922,7 @@ static void bond_uninit(struct net_device *bond_dev)
 	/* Release the bonded slaves */
 	bond_for_each_slave(bond, slave, iter)
 		__bond_release_one(bond_dev, slave->dev, true);
-	pr_info("%s: released all slaves\n", bond_dev->name);
+	pr_info("%s: Released all slaves\n", bond_dev->name);
 
 	list_del(&bond->bond_list);
 
@@ -4005,7 +4000,7 @@ static int bond_check_params(struct bond_params *params)
 		if ((bond_mode != BOND_MODE_XOR) &&
 		    (bond_mode != BOND_MODE_8023AD)) {
 			pr_info("xmit_hash_policy param is irrelevant in mode %s\n",
-			       bond_mode_name(bond_mode));
+				bond_mode_name(bond_mode));
 		} else {
 			bond_opt_initstr(&newval, xmit_hash_policy);
 			valptr = bond_opt_parse(bond_opt_get(BOND_OPT_XMIT_HASH),
@@ -4236,15 +4231,15 @@ static int bond_check_params(struct bond_params *params)
 			arp_interval, valptr->string, arp_ip_count);
 
 		for (i = 0; i < arp_ip_count; i++)
-			pr_info(" %s", arp_ip_target[i]);
+			pr_cont(" %s", arp_ip_target[i]);
 
-		pr_info("\n");
+		pr_cont("\n");
 
 	} else if (max_bonds) {
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
-		pr_debug("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
+		pr_debug("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details\n");
 	}
 
 	if (primary && !USES_PRIMARY(bond_mode)) {
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 70651f8..20659b1 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -181,7 +181,7 @@ static int bond_changelink(struct net_device *bond_dev,
 		int arp_interval = nla_get_u32(data[IFLA_BOND_ARP_INTERVAL]);
 
 		if (arp_interval && miimon) {
-			pr_err("%s: ARP monitoring cannot be used with MII monitoring.\n",
+			pr_err("%s: ARP monitoring cannot be used with MII monitoring\n",
 			       bond->dev->name);
 			return -EINVAL;
 		}
@@ -207,7 +207,7 @@ static int bond_changelink(struct net_device *bond_dev,
 			i++;
 		}
 		if (i == 0 && bond->params.arp_interval)
-			pr_warn("%s: removing last arp target with arp_interval on\n",
+			pr_warn("%s: Removing last arp target with arp_interval on\n",
 				bond->dev->name);
 		if (err)
 			return err;
@@ -216,7 +216,7 @@ static int bond_changelink(struct net_device *bond_dev,
 		int arp_validate = nla_get_u32(data[IFLA_BOND_ARP_VALIDATE]);
 
 		if (arp_validate && miimon) {
-			pr_err("%s: ARP validating cannot be used with MII monitoring.\n",
+			pr_err("%s: ARP validating cannot be used with MII monitoring\n",
 			       bond->dev->name);
 			return -EINVAL;
 		}
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 832d6e9..f3eb44d 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -473,10 +473,10 @@ static void bond_opt_error_interpret(struct bonding *bond,
 				p = strchr(val->string, '\n');
 				if (p)
 					*p = '\0';
-				pr_err("%s: option %s: invalid value (%s).\n",
+				pr_err("%s: option %s: invalid value (%s)\n",
 				       bond->dev->name, opt->name, val->string);
 			} else {
-				pr_err("%s: option %s: invalid value (%llu).\n",
+				pr_err("%s: option %s: invalid value (%llu)\n",
 				       bond->dev->name, opt->name, val->value);
 			}
 		}
@@ -484,7 +484,7 @@ static void bond_opt_error_interpret(struct bonding *bond,
 		maxval = bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
 		if (!maxval)
 			break;
-		pr_err("%s: option %s: allowed values %llu - %llu.\n",
+		pr_err("%s: option %s: allowed values %llu - %llu\n",
 		       bond->dev->name, opt->name, minval ? minval->value : 0,
 		       maxval->value);
 		break;
@@ -492,11 +492,11 @@ static void bond_opt_error_interpret(struct bonding *bond,
 		bond_opt_dep_print(bond, opt);
 		break;
 	case -ENOTEMPTY:
-		pr_err("%s: option %s: unable to set because the bond device has slaves.\n",
+		pr_err("%s: option %s: unable to set because the bond device has slaves\n",
 		       bond->dev->name, opt->name);
 		break;
 	case -EBUSY:
-		pr_err("%s: option %s: unable to set because the bond device is up.\n",
+		pr_err("%s: option %s: unable to set because the bond device is up\n",
 		       bond->dev->name, opt->name);
 		break;
 	default:
@@ -589,7 +589,7 @@ int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval)
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
 		bond->params.miimon = BOND_DEFAULT_MIIMON;
-		pr_info("%s: Setting MII monitoring interval to %d.\n",
+		pr_info("%s: Setting MII monitoring interval to %d\n",
 			bond->dev->name, bond->params.miimon);
 	}
 
@@ -636,13 +636,13 @@ int bond_option_active_slave_set(struct bonding *bond,
 
 	if (slave_dev) {
 		if (!netif_is_bond_slave(slave_dev)) {
-			pr_err("Device %s is not bonding slave.\n",
+			pr_err("Device %s is not bonding slave\n",
 			       slave_dev->name);
 			return -EINVAL;
 		}
 
 		if (bond->dev != netdev_master_upper_dev_get(slave_dev)) {
-			pr_err("%s: Device %s is not our slave.\n",
+			pr_err("%s: Device %s is not our slave\n",
 			       bond->dev->name, slave_dev->name);
 			return -EINVAL;
 		}
@@ -653,8 +653,7 @@ int bond_option_active_slave_set(struct bonding *bond,
 
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
-		pr_info("%s: Clearing current active slave.\n",
-		bond->dev->name);
+		pr_info("%s: Clearing current active slave\n", bond->dev->name);
 		rcu_assign_pointer(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
@@ -665,16 +664,16 @@ int bond_option_active_slave_set(struct bonding *bond,
 
 		if (new_active == old_active) {
 			/* do nothing */
-			pr_info("%s: %s is already the current active slave.\n",
+			pr_info("%s: %s is already the current active slave\n",
 				bond->dev->name, new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
 			    IS_UP(new_active->dev)) {
-				pr_info("%s: Setting %s as active slave.\n",
+				pr_info("%s: Setting %s as active slave\n",
 					bond->dev->name, new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
 			} else {
-				pr_err("%s: Could not set %s as active slave; either %s is down or the link is down.\n",
+				pr_err("%s: Could not set %s as active slave; either %s is down or the link is down\n",
 				       bond->dev->name, new_active->dev->name,
 				       new_active->dev->name);
 				ret = -EINVAL;
@@ -690,19 +689,19 @@ int bond_option_active_slave_set(struct bonding *bond,
 
 int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting MII monitoring interval to %llu.\n",
+	pr_info("%s: Setting MII monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
 	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
-		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value.\n",
+		pr_info("%s: Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
 			bond->dev->name,
 			bond->params.updelay * bond->params.miimon);
 	if (bond->params.downdelay)
-		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value.\n",
+		pr_info("%s: Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
 			bond->dev->name,
 			bond->params.downdelay * bond->params.miimon);
 	if (newval->value && bond->params.arp_interval) {
-		pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
+		pr_info("%s: MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n",
 			bond->dev->name);
 		bond->params.arp_interval = 0;
 		if (bond->params.arp_validate)
@@ -742,9 +741,8 @@ int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
 			bond->params.miimon);
 	}
 	bond->params.updelay = value / bond->params.miimon;
-	pr_info("%s: Setting up delay to %d.\n",
-		bond->dev->name,
-		bond->params.updelay * bond->params.miimon);
+	pr_info("%s: Setting up delay to %d\n",
+		bond->dev->name, bond->params.updelay * bond->params.miimon);
 
 	return 0;
 }
@@ -767,9 +765,8 @@ int bond_option_downdelay_set(struct bonding *bond,
 			bond->params.miimon);
 	}
 	bond->params.downdelay = value / bond->params.miimon;
-	pr_info("%s: Setting down delay to %d.\n",
-		bond->dev->name,
-		bond->params.downdelay * bond->params.miimon);
+	pr_info("%s: Setting down delay to %d\n",
+		bond->dev->name, bond->params.downdelay * bond->params.miimon);
 
 	return 0;
 }
@@ -777,7 +774,7 @@ int bond_option_downdelay_set(struct bonding *bond,
 int bond_option_use_carrier_set(struct bonding *bond,
 				struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting use_carrier to %llu.\n",
+	pr_info("%s: Setting use_carrier to %llu\n",
 		bond->dev->name, newval->value);
 	bond->params.use_carrier = newval->value;
 
@@ -787,17 +784,17 @@ int bond_option_use_carrier_set(struct bonding *bond,
 int bond_option_arp_interval_set(struct bonding *bond,
 				 struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting ARP monitoring interval to %llu.\n",
+	pr_info("%s: Setting ARP monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
 	bond->params.arp_interval = newval->value;
 	if (newval->value) {
 		if (bond->params.miimon) {
-			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
+			pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring\n",
 				bond->dev->name, bond->dev->name);
 			bond->params.miimon = 0;
 		}
 		if (!bond->params.arp_targets[0])
-			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
+			pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified\n",
 				bond->dev->name);
 	}
 	if (bond->dev->flags & IFF_UP) {
@@ -856,12 +853,11 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 
 	ind = bond_get_targets_ip(targets, 0); /* first free slot */
 	if (ind == -1) {
-		pr_err("%s: ARP target table is full!\n",
-		       bond->dev->name);
+		pr_err("%s: ARP target table is full!\n", bond->dev->name);
 		return -EINVAL;
 	}
 
-	pr_info("%s: adding ARP target %pI4.\n", bond->dev->name, &target);
+	pr_info("%s: Adding ARP target %pI4\n", bond->dev->name, &target);
 
 	_bond_options_arp_ip_target_set(bond, ind, target, jiffies);
 
@@ -896,17 +892,16 @@ int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 
 	ind = bond_get_targets_ip(targets, target);
 	if (ind == -1) {
-		pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
+		pr_err("%s: unable to remove nonexistent ARP target %pI4\n",
 		       bond->dev->name, &target);
 		return -EINVAL;
 	}
 
 	if (ind == 0 && !targets[1] && bond->params.arp_interval)
-		pr_warn("%s: removing last arp target with arp_interval on\n",
+		pr_warn("%s: Removing last arp target with arp_interval on\n",
 			bond->dev->name);
 
-	pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
-		&target);
+	pr_info("%s: Removing ARP target %pI4\n", bond->dev->name, &target);
 
 	/* not to race with bond_arp_rcv */
 	write_lock_bh(&bond->lock);
@@ -954,7 +949,7 @@ int bond_option_arp_ip_targets_set(struct bonding *bond,
 		else if (newval->string[0] == '-')
 			ret = bond_option_arp_ip_target_rem(bond, target);
 		else
-			pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
+			pr_err("no command found in arp_ip_targets file for bond %s - use +<addr> or -<addr>\n",
 			       bond->dev->name);
 	} else {
 		target = newval->value;
@@ -967,7 +962,7 @@ int bond_option_arp_ip_targets_set(struct bonding *bond,
 int bond_option_arp_validate_set(struct bonding *bond,
 				 struct bond_opt_value *newval)
 {
-	pr_info("%s: setting arp_validate to %s (%llu).\n",
+	pr_info("%s: Setting arp_validate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
@@ -984,7 +979,7 @@ int bond_option_arp_validate_set(struct bonding *bond,
 int bond_option_arp_all_targets_set(struct bonding *bond,
 				    struct bond_opt_value *newval)
 {
-	pr_info("%s: setting arp_all_targets to %s (%llu).\n",
+	pr_info("%s: Setting arp_all_targets to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.arp_all_targets = newval->value;
 
@@ -1006,8 +1001,7 @@ int bond_option_primary_set(struct bonding *bond, struct bond_opt_value *newval)
 		*p = '\0';
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
-		pr_info("%s: Setting primary slave to None.\n",
-			bond->dev->name);
+		pr_info("%s: Setting primary slave to None\n", bond->dev->name);
 		bond->primary_slave = NULL;
 		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
@@ -1016,7 +1010,7 @@ int bond_option_primary_set(struct bonding *bond, struct bond_opt_value *newval)
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
-			pr_info("%s: Setting %s as primary slave.\n",
+			pr_info("%s: Setting %s as primary slave\n",
 				bond->dev->name, slave->dev->name);
 			bond->primary_slave = slave;
 			strcpy(bond->params.primary, slave->dev->name);
@@ -1026,15 +1020,14 @@ int bond_option_primary_set(struct bonding *bond, struct bond_opt_value *newval)
 	}
 
 	if (bond->primary_slave) {
-		pr_info("%s: Setting primary slave to None.\n",
-			bond->dev->name);
+		pr_info("%s: Setting primary slave to None\n", bond->dev->name);
 		bond->primary_slave = NULL;
 		bond_select_active_slave(bond);
 	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
-	pr_info("%s: Recording %s as primary, but it has not been enslaved to %s yet.\n",
+	pr_info("%s: Recording %s as primary, but it has not been enslaved to %s yet\n",
 		bond->dev->name, primary, bond->dev->name);
 
 out:
@@ -1048,7 +1041,7 @@ out:
 int bond_option_primary_reselect_set(struct bonding *bond,
 				     struct bond_opt_value *newval)
 {
-	pr_info("%s: setting primary_reselect to %s (%llu).\n",
+	pr_info("%s: Setting primary_reselect to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.primary_reselect = newval->value;
 
@@ -1064,7 +1057,7 @@ int bond_option_primary_reselect_set(struct bonding *bond,
 int bond_option_fail_over_mac_set(struct bonding *bond,
 				  struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting fail_over_mac to %s (%llu).\n",
+	pr_info("%s: Setting fail_over_mac to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.fail_over_mac = newval->value;
 
@@ -1074,7 +1067,7 @@ int bond_option_fail_over_mac_set(struct bonding *bond,
 int bond_option_xmit_hash_policy_set(struct bonding *bond,
 				     struct bond_opt_value *newval)
 {
-	pr_info("%s: setting xmit hash policy to %s (%llu).\n",
+	pr_info("%s: Setting xmit hash policy to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.xmit_policy = newval->value;
 
@@ -1084,7 +1077,7 @@ int bond_option_xmit_hash_policy_set(struct bonding *bond,
 int bond_option_resend_igmp_set(struct bonding *bond,
 				struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting resend_igmp to %llu.\n",
+	pr_info("%s: Setting resend_igmp to %llu\n",
 		bond->dev->name, newval->value);
 	bond->params.resend_igmp = newval->value;
 
@@ -1158,7 +1151,7 @@ int bond_option_pps_set(struct bonding *bond, struct bond_opt_value *newval)
 int bond_option_lacp_rate_set(struct bonding *bond,
 			      struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting LACP rate to %s (%llu).\n",
+	pr_info("%s: Setting LACP rate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
@@ -1169,7 +1162,7 @@ int bond_option_lacp_rate_set(struct bonding *bond,
 int bond_option_ad_select_set(struct bonding *bond,
 			      struct bond_opt_value *newval)
 {
-	pr_info("%s: Setting ad_select to %s (%llu).\n",
+	pr_info("%s: Setting ad_select to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
 	bond->params.ad_select = newval->value;
 
@@ -1231,8 +1224,7 @@ out:
 	return ret;
 
 err_no_cmd:
-	pr_info("invalid input for queue_id set for %s.\n",
-		bond->dev->name);
+	pr_info("invalid input for queue_id set for %s\n", bond->dev->name);
 	ret = -EPERM;
 	goto out;
 
@@ -1253,7 +1245,7 @@ int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval)
 
 	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 	if (!dev) {
-		pr_info("%s: Interface %s does not exist!\n",
+		pr_info("%s: interface %s does not exist!\n",
 			bond->dev->name, ifname);
 		ret = -ENODEV;
 		goto out;
@@ -1261,12 +1253,12 @@ int bond_option_slaves_set(struct bonding *bond, struct bond_opt_value *newval)
 
 	switch (command[0]) {
 	case '+':
-		pr_info("%s: Adding slave %s.\n", bond->dev->name, dev->name);
+		pr_info("%s: Adding slave %s\n", bond->dev->name, dev->name);
 		ret = bond_enslave(bond->dev, dev);
 		break;
 
 	case '-':
-		pr_info("%s: Removing slave %s.\n", bond->dev->name, dev->name);
+		pr_info("%s: Removing slave %s\n", bond->dev->name, dev->name);
 		ret = bond_release(bond->dev, dev);
 		break;
 
@@ -1278,7 +1270,7 @@ out:
 	return ret;
 
 err_no_cmd:
-	pr_err("no command found in slaves file for bond %s. Use +ifname or -ifname.\n",
+	pr_err("no command found in slaves file for bond %s - use +ifname or -ifname\n",
 	       bond->dev->name);
 	ret = -EPERM;
 	goto out;
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index f86fcc7..434df73 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -281,7 +281,7 @@ void __net_init bond_create_proc_dir(struct bond_net *bn)
 	if (!bn->proc_dir) {
 		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
 		if (!bn->proc_dir)
-			pr_warn("Warning: cannot create /proc/net/%s\n",
+			pr_warn("Warning: Cannot create /proc/net/%s\n",
 				DRV_NAME);
 	}
 }
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 643fcc1..225ee69 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -117,9 +117,9 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		rv = bond_create(bn->net, ifname);
 		if (rv) {
 			if (rv == -EEXIST)
-				pr_info("%s already exists.\n", ifname);
+				pr_info("%s already exists\n", ifname);
 			else
-				pr_info("%s creation failed.\n", ifname);
+				pr_info("%s creation failed\n", ifname);
 			res = rv;
 		}
 	} else if (command[0] == '-') {
@@ -144,7 +144,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
 	return res;
 
 err_no_cmd:
-	pr_err("no command found in bonding_masters. Use +ifname or -ifname.\n");
+	pr_err("no command found in bonding_masters - use +ifname or -ifname\n");
 	return -EPERM;
 }
 
@@ -1135,7 +1135,7 @@ int bond_create_sysfs(struct bond_net *bn)
 		/* Is someone being kinky and naming a device bonding_master? */
 		if (__dev_get_by_name(bn->net,
 				      class_attr_bonding_masters.attr.name))
-			pr_err("network device named %s already exists in sysfs",
+			pr_err("network device named %s already exists in sysfs\n",
 			       class_attr_bonding_masters.attr.name);
 		ret = 0;
 	}
-- 
1.8.1.2.459.gbcd45b4.dirty
