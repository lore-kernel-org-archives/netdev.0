From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 r12/17] bonding: prefix bondname to log messages
Date: Fri, 8 Apr 2005 17:03:01 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081701150.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds <bondname>: prefix to logs printed to /var/log/messages to 
identify messages on a per bond basis.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_3ad.c linux-2.6.12-rc2/drivers/net/bonding/bond_3ad.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_3ad.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_3ad.c	2005-04-07 13:57:28.000000000 -0700
@@ -1378,8 +1378,9 @@
  			}
  		}
  		if (!curr_port) { // meaning: the port was related to an aggregator but was not on the aggregator port list
-			printk(KERN_WARNING DRV_NAME ": Warning: Port %d (on %s) was "
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: Port %d (on %s) was "
  			       "related to aggregator %d but was not on its port list\n",
+			       port->slave->dev->master->name,
  			       port->actor_port_number, port->slave->dev->name,
  			       port->aggregator->aggregator_identifier);
  		}
@@ -1450,7 +1451,8 @@

  			dprintk("Port %d joined LAG %d(new LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
  		} else {
-			printk(KERN_ERR DRV_NAME ": Port %d (on %s) did not find a suitable aggregator\n",
+			printk(KERN_ERR DRV_NAME ": %s: Port %d (on %s) did not find a suitable aggregator\n",
+			       port->slave->dev->master->name,
  			       port->actor_port_number, port->slave->dev->name);
  		}
  	}
@@ -1582,8 +1584,9 @@

  		// check if any partner replys
  		if (best_aggregator->is_individual) {
-			printk(KERN_WARNING DRV_NAME ": Warning: No 802.3ad response from the link partner "
-					"for any adapters in the bond\n");
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad response from "
+			       "the link partner for any adapters in the bond\n",
+			       best_aggregator->slave->dev->master->name);
  		}

  		// check if there are more than one aggregator
@@ -1991,7 +1994,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Trying to unbind an uninitialized port on %s\n", slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": Warning: %s: Trying to "
+		       "unbind an uninitialized port on %s\n", 
+		       slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2022,7 +2027,8 @@
  				dprintk("Some port(s) related to LAG %d - replaceing with LAG %d\n", aggregator->aggregator_identifier, new_aggregator->aggregator_identifier);

  				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
-					printk(KERN_INFO DRV_NAME ": Removing an active aggregator\n");
+					printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
+					       aggregator->slave->dev->master->name);
  					// select new active aggregator
  					 select_new_active_agg = 1;
  				}
@@ -2052,15 +2058,17 @@
  					ad_agg_selection_logic(__get_first_agg(port));
  				}
  			} else {
-				printk(KERN_WARNING DRV_NAME ": Warning: unbinding aggregator, "
-				       "and could not find a new aggregator for its ports\n");
+				printk(KERN_WARNING DRV_NAME ": %s: Warning: unbinding aggregator, "
+				       "and could not find a new aggregator for its ports\n",
+				       slave->dev->master->name);
  			}
  		} else { // in case that the only port related to this aggregator is the one we want to remove
  			select_new_active_agg = aggregator->is_active;
  			// clear the aggregator
  			ad_clear_agg(aggregator);
  			if (select_new_active_agg) {
-				printk(KERN_INFO "Removing an active aggregator\n");
+				printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
+				       slave->dev->master->name);
  				// select new active aggregator
  				ad_agg_selection_logic(__get_first_agg(port));
  			}
@@ -2133,7 +2141,8 @@
  		// select the active aggregator for the bond
  		if ((port = __get_first_port(bond))) {
  			if (!port->slave) {
-				printk(KERN_WARNING DRV_NAME ": Warning: bond's first port is uninitialized\n");
+				printk(KERN_WARNING DRV_NAME ": %s: Warning: bond's first port is "
+				       "uninitialized\n", bond->dev->name);
  				goto re_arm;
  			}

@@ -2145,7 +2154,8 @@
  	// for each port run the state machines
  	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
  		if (!port->slave) {
-			printk(KERN_WARNING DRV_NAME ": Warning: Found an uninitialized port\n");
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: Found an uninitialized "
+			       "port\n", bond->dev->name);
  			goto re_arm;
  		}

@@ -2186,7 +2196,8 @@
  		port = &(SLAVE_AD_INFO(slave).port);

  		if (!port->slave) {
-			printk(KERN_WARNING DRV_NAME ": Warning: port of slave %s is uninitialized\n", slave->dev->name);
+			printk(KERN_WARNING DRV_NAME ": %s: Warning: port of slave %s is "
+			       "uninitialized\n", slave->dev->name, slave->dev->master->name);
  			return;
  		}

@@ -2232,8 +2243,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: speed changed for uninitialized port on %s\n",
-		       slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": Warning: %s: speed "
+		       "changed for uninitialized port on %s\n", 
+		       slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2259,8 +2271,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: duplex changed for uninitialized port on %s\n",
-		       slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": %s: Warning: duplex changed "
+		       "for uninitialized port on %s\n",
+		       slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2287,8 +2300,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: link status changed for uninitialized port on %s\n",
-			slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": Warning: %s: link status changed for "
+		       "uninitialized port on %s\n", 
+			slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2396,7 +2410,8 @@
  	}

  	if (slave_agg_no >= 0) {
-		printk(KERN_ERR DRV_NAME ": Error: Couldn't find a slave to tx on for aggregator ID %d\n", agg_id);
+		printk(KERN_ERR DRV_NAME ": %s: Error: Couldn't find a slave to tx on "
+		       "for aggregator ID %d\n", dev->name, agg_id);
  		goto out;
  	}

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c	2005-04-07 13:57:29.000000000 -0700
@@ -515,7 +515,8 @@
  				 client_info->mac_dst);
  		if (!skb) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: failed to create an ARP packet\n");
+			       ": %s: Error: failed to create an ARP packet\n",
+			       client_info->slave->dev->master->name);
  			continue;
  		}

@@ -525,7 +526,8 @@
  			skb = vlan_put_tag(skb, client_info->vlan_id);
  			if (!skb) {
  				printk(KERN_ERR DRV_NAME
-				       ": Error: failed to insert VLAN tag\n");
+				       ": %s: Error: failed to insert VLAN tag\n",
+				       client_info->slave->dev->master->name);
  				continue;
  			}
  		}
@@ -608,8 +610,9 @@

  		if (!client_info->slave) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: found a client with no channel in "
-			       "the client's hash table\n");
+			       ": %s: Error: found a client with no channel in "
+			       "the client's hash table\n",
+			       bond->dev->name);
  			continue;
  		}
  		/*update all clients using this src_ip, that are not assigned
@@ -930,7 +933,8 @@
  			skb = vlan_put_tag(skb, vlan->vlan_id);
  			if (!skb) {
  				printk(KERN_ERR DRV_NAME
-				       ": Error: failed to insert VLAN tag\n");
+				       ": %s: Error: failed to insert VLAN tag\n",
+				       bond->dev->name);
  				continue;
  			}
  		}
@@ -959,11 +963,11 @@
  	s_addr.sa_family = dev->type;
  	if (dev_set_mac_address(dev, &s_addr)) {
  		printk(KERN_ERR DRV_NAME
-		       ": Error: dev_set_mac_address of dev %s failed! ALB "
+		       ": %s: Error: dev_set_mac_address of dev %s failed! ALB "
  		       "mode requires that the base driver support setting "
  		       "the hw address also when the network device's "
  		       "interface is open\n",
-		       dev->name);
+		       dev->master->name, dev->name);
  		return -EOPNOTSUPP;
  	}
  	return 0;
@@ -1113,9 +1117,9 @@
  			 * of the new slave
  			 */
  			printk(KERN_ERR DRV_NAME
-			       ": Error: the hw address of slave %s is not "
+			       ": %s: Error: the hw address of slave %s is not "
  			       "unique - cannot enslave it!",
-			       slave->dev->name);
+			       bond->dev->name, slave->dev->name);
  			return -EINVAL;
  		}

@@ -1161,16 +1165,16 @@
  				       bond->alb_info.rlb_enabled);

  		printk(KERN_WARNING DRV_NAME
-		       ": Warning: the hw address of slave %s is in use by "
+		       ": %s: Warning: the hw address of slave %s is in use by "
  		       "the bond; giving it the hw address of %s\n",
-		       slave->dev->name, free_mac_slave->dev->name);
+		       bond->dev->name, slave->dev->name, free_mac_slave->dev->name);

  	} else if (has_bond_addr) {
  		printk(KERN_ERR DRV_NAME
-		       ": Error: the hw address of slave %s is in use by the "
+		       ": %s: Error: the hw address of slave %s is in use by the "
  		       "bond; couldn't find a slave with a free hw address to "
  		       "give it (this should not have happened)\n",
-		       slave->dev->name);
+		       bond->dev->name, slave->dev->name);
  		return -EFAULT;
  	}

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -1592,8 +1592,8 @@

  	if (slave_dev->do_ioctl == NULL) {
  		printk(KERN_WARNING DRV_NAME
-		       ": Warning : no link monitoring support for %s\n",
-		       slave_dev->name);
+		       ": %s: Warning: no link monitoring support for %s\n",
+		       bond_dev->name, slave_dev->name);
  	}

  	/* bond must be initialized by bond_open() before enslaving */
@@ -1614,17 +1614,17 @@
  		dprintk("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
  		if (!list_empty(&bond->vlan_list)) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: cannot enslave VLAN "
+			       ": %s: Error: cannot enslave VLAN "
  			       "challenged slave %s on VLAN enabled "
-			       "bond %s\n", slave_dev->name,
+			       "bond %s\n", bond_dev->name, slave_dev->name,
  			       bond_dev->name);
  			return -EPERM;
  		} else {
  			printk(KERN_WARNING DRV_NAME
-			       ": Warning: enslaved VLAN challenged "
+			       ": %s: Warning: enslaved VLAN challenged "
  			       "slave %s. Adding VLANs will be blocked as "
  			       "long as %s is part of bond %s\n",
-			       slave_dev->name, slave_dev->name,
+			       bond_dev->name, slave_dev->name, slave_dev->name,
  			       bond_dev->name);
  			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
  		}
@@ -1644,8 +1694,8 @@
  		 */
  		if ((slave_dev->flags & IFF_UP)) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: %s is up\n",
-			       slave_dev->name);
+			       ": %s: Error: %s is up\n",
+			       bond_dev->name, slave_dev->name);
  			res = -EPERM;
  			goto err_undo_flags;
  		}
@@ -1667,8 +1667,8 @@
  		 */
  		if (!(slave_dev->flags & IFF_UP)) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: %s is not running\n",
-			       slave_dev->name);
+			       ": %s: Error: %s is not running\n",
+			       bond_dev->name, slave_dev->name);
  			res = -EINVAL;
  			goto err_undo_flags;
  		}
@@ -1677,9 +1677,9 @@
  		    (bond->params.mode == BOND_MODE_TLB)    ||
  		    (bond->params.mode == BOND_MODE_ALB)) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: to use %s mode, you must upgrade "
+			       ": %s: Error: to use %s mode, you must upgrade "
  			       "ifenslave.\n",
-			       bond_mode_name(bond->params.mode));
+			       bond_dev->name, bond_mode_name(bond->params.mode));
  			res = -EOPNOTSUPP;
  			goto err_undo_flags;
  		}
@@ -1800,21 +1800,21 @@
  			 * the messages for netif_carrier.
  			 */
  			printk(KERN_WARNING DRV_NAME
-			       ": Warning: MII and ETHTOOL support not "
+			       ": %s: Warning: MII and ETHTOOL support not "
  			       "available for interface %s, and "
  			       "arp_interval/arp_ip_target module parameters "
  			       "not specified, thus bonding will not detect "
  			       "link failures! see bonding.txt for details.\n",
-			       slave_dev->name);
+			       bond_dev->name, slave_dev->name);
  		} else if (link_reporting == -1) {
  			/* unable get link status using mii/ethtool */
  			printk(KERN_WARNING DRV_NAME
-			       ": Warning: can't get link status from "
+			       ": %s: Warning: can't get link status from "
  			       "interface %s; the network driver associated "
  			       "with this interface does not support MII or "
  			       "ETHTOOL link status reporting, thus miimon "
  			       "has no effect on this interface.\n",
-			       slave_dev->name);
+			       bond_dev->name, slave_dev->name);
  		}
  	}

@@ -1841,9 +1890,9 @@
  	if (bond_update_speed_duplex(new_slave) &&
  	    (new_slave->link != BOND_LINK_DOWN)) {
  		printk(KERN_WARNING DRV_NAME
-		       ": Warning: failed to get speed and duplex from %s, "
+		       ": %s: Warning: failed to get speed and duplex from %s, "
  		       "assumed to be 100Mb/sec and Full.\n",
-		       new_slave->dev->name);
+		       bond_dev->name, new_slave->dev->name);

  		if (bond->params.mode == BOND_MODE_8023AD) {
  			printk(KERN_WARNING DRV_NAME
@@ -2042,11 +2042,12 @@
  				 ETH_ALEN);
  	if (!mac_addr_differ && (bond->slave_cnt > 1)) {
  		printk(KERN_WARNING DRV_NAME
-		       ": Warning: the permanent HWaddr of %s "
+		       ": %s: Warning: the permanent HWaddr of %s "
  		       "- %02X:%02X:%02X:%02X:%02X:%02X - is "
  		       "still in use by %s. Set the HWaddr of "
  		       "%s to a different address to avoid "
  		       "conflicts.\n",
+		       bond_dev->name,
  		       slave_dev->name,
  		       slave->perm_hwaddr[0],
  		       slave->perm_hwaddr[1],
@@ -2120,19 +2164,20 @@
  			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
  		} else {
  			printk(KERN_WARNING DRV_NAME
-			       ": Warning: clearing HW address of %s while it "
+			       ": %s: Warning: clearing HW address of %s while it "
  			       "still has VLANs.\n",
-			       bond_dev->name);
+			       bond_dev->name, bond_dev->name);
  			printk(KERN_WARNING DRV_NAME
-			       ": When re-adding slaves, make sure the bond's "
-			       "HW address matches its VLANs'.\n");
+			       ": %s: When re-adding slaves, make sure the bond's "
+			       "HW address matches its VLANs'.\n",
+			       bond_dev->name);
  		}
  	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
  		   !bond_has_challenged_slaves(bond)) {
  		printk(KERN_INFO DRV_NAME
-		       ": last VLAN challenged slave %s "
+		       ": %s: last VLAN challenged slave %s "
  		       "left bond %s. VLAN blocking is removed\n",
-		       slave_dev->name, bond_dev->name);
+		       bond_dev->name, slave_dev->name, bond_dev->name);
  		bond_dev->features &= ~NETIF_F_VLAN_CHALLENGED;
  	}

@@ -2232,6 +2234,7 @@
  		 */
  		write_unlock_bh(&bond->lock);

+		bond_destroy_slave_symlinks(bond_dev, slave_dev);
  		bond_del_vlans_from_slave(bond, slave_dev);

  		/* If the mode USES_PRIMARY, then we should only remove its
@@ -2288,12 +2291,13 @@
  		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
  	} else {
  		printk(KERN_WARNING DRV_NAME
-		       ": Warning: clearing HW address of %s while it "
+		       ": %s: Warning: clearing HW address of %s while it "
  		       "still has VLANs.\n",
-		       bond_dev->name);
+		       bond_dev->name, bond_dev->name);
  		printk(KERN_WARNING DRV_NAME
-		       ": When re-adding slaves, make sure the bond's "
-		       "HW address matches its VLANs'.\n");
+		       ": %s: When re-adding slaves, make sure the bond's "
+		       "HW address matches its VLANs'.\n",
+		       bond_dev->name);
  	}

  	printk(KERN_INFO DRV_NAME
@@ -2385,8 +2389,9 @@
  						     &endptr, 0);
  			if (*endptr) {
  				printk(KERN_ERR DRV_NAME
-				       ": Error: got invalid ABI "
-				       "version from application\n");
+				       ": %s: Error: got invalid ABI "
+				       "version from application\n",
+				       bond_dev->name);

  				return -EINVAL;
  			}
@@ -4207,8 +4212,9 @@
  				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
  				if (!skb2) {
  					printk(KERN_ERR DRV_NAME
-					       ": Error: bond_xmit_broadcast(): "
-					       "skb_clone() failed\n");
+					       ": %s: Error: bond_xmit_broadcast(): "
+					       "skb_clone() failed\n",
+					       bond_dev->name);
  					continue;
  				}

@@ -4267,7 +4273,8 @@
  	default:
  		/* Should never happen, mode already checked */
  		printk(KERN_ERR DRV_NAME
-		       ": Error: Unknown bonding mode %d\n",
+		       ": %s: Error: Unknown bonding mode %d\n",
+		       bond_dev->name,
  		       mode);
  		break;
  	}
