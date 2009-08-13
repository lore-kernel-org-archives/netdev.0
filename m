From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: wipe out printk's
Date: Thu, 13 Aug 2009 16:11:52 +0200
Message-ID: <20090813141151.GA10449@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38895 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbZHMOMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 10:12:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did not introduce new lines over 80 chars. I even eliminated some of them.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index be799d2..cea5cfe 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1124,7 +1124,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			// detect loopback situation
 			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
 				// INFO_RECEIVED_LOOPBACK_FRAMES
-				printk(KERN_ERR DRV_NAME ": %s: An illegal loopback occurred on "
+				pr_err(DRV_NAME ": %s: An illegal loopback occurred on "
 				       "adapter (%s). Check the configuration to verify that all "
 				       "Adapters are connected to 802.3ad compliant switch ports\n",
 				       port->slave->dev->master->name, port->slave->dev->name);
@@ -1306,11 +1306,13 @@ static void ad_port_selection_logic(struct port *port)
 			}
 		}
 		if (!curr_port) { // meaning: the port was related to an aggregator but was not on the aggregator port list
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: Port %d (on %s) was "
-			       "related to aggregator %d but was not on its port list\n",
-			       port->slave->dev->master->name,
-			       port->actor_port_number, port->slave->dev->name,
-			       port->aggregator->aggregator_identifier);
+			pr_warning(DRV_NAME ": %s: Warning: Port %d (on %s) "
+				   "was related to aggregator %d but was not "
+				   "on its port list\n",
+				   port->slave->dev->master->name,
+				   port->actor_port_number,
+				   port->slave->dev->name,
+				   port->aggregator->aggregator_identifier);
 		}
 	}
 	// search on all aggregators for a suitable aggregator for this port
@@ -1379,7 +1381,8 @@ static void ad_port_selection_logic(struct port *port)
 
 			pr_debug("Port %d joined LAG %d(new LAG)\n", port->actor_port_number, port->aggregator->aggregator_identifier);
 		} else {
-			printk(KERN_ERR DRV_NAME ": %s: Port %d (on %s) did not find a suitable aggregator\n",
+			pr_err(DRV_NAME ": %s: Port %d (on %s) did not find "
+			       "a suitable aggregator\n",
 			       port->slave->dev->master->name,
 			       port->actor_port_number, port->slave->dev->name);
 		}
@@ -1456,10 +1459,10 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 		break;
 
 	default:
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Impossible agg select mode %d\n",
-		       curr->slave->dev->master->name,
-		       __get_agg_selection_mode(curr->lag_ports));
+		pr_warning(DRV_NAME
+			   ": %s: Impossible agg select mode %d\n",
+			   curr->slave->dev->master->name,
+			   __get_agg_selection_mode(curr->lag_ports));
 		break;
 	}
 
@@ -1562,7 +1565,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 
 		// check if any partner replys
 		if (best->is_individual) {
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: No 802.3ad"
+			pr_warning(DRV_NAME ": %s: Warning: No 802.3ad"
 			       " response from the link partner for any"
 			       " adapters in the bond\n",
 			       best->slave->dev->master->name);
@@ -1885,7 +1888,8 @@ int bond_3ad_bind_slave(struct slave *slave)
 	struct aggregator *aggregator;
 
 	if (bond == NULL) {
-		printk(KERN_ERR DRV_NAME ": %s: The slave %s is not attached to its bond\n",
+		pr_err(DRV_NAME ": %s: The slave %s is not attached to "
+		       "its bond\n",
 		       slave->dev->master->name, slave->dev->name);
 		return -1;
 	}
@@ -1961,9 +1965,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: %s: Trying to "
-		       "unbind an uninitialized port on %s\n",
-		       slave->dev->master->name, slave->dev->name);
+		pr_warning(DRV_NAME ": Warning: %s: Trying to "
+			   "unbind an uninitialized port on %s\n",
+			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
@@ -1994,8 +1998,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				pr_debug("Some port(s) related to LAG %d - replaceing with LAG %d\n", aggregator->aggregator_identifier, new_aggregator->aggregator_identifier);
 
 				if ((new_aggregator->lag_ports == port) && new_aggregator->is_active) {
-					printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
-					       aggregator->slave->dev->master->name);
+					pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+						aggregator->slave->dev->master->name);
 					// select new active aggregator
 					 select_new_active_agg = 1;
 				}
@@ -2025,17 +2029,17 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					ad_agg_selection_logic(__get_first_agg(port));
 				}
 			} else {
-				printk(KERN_WARNING DRV_NAME ": %s: Warning: unbinding aggregator, "
-				       "and could not find a new aggregator for its ports\n",
-				       slave->dev->master->name);
+				pr_warning(DRV_NAME ": %s: Warning: unbinding aggregator, "
+					   "and could not find a new aggregator for its ports\n",
+					   slave->dev->master->name);
 			}
 		} else { // in case that the only port related to this aggregator is the one we want to remove
 			select_new_active_agg = aggregator->is_active;
 			// clear the aggregator
 			ad_clear_agg(aggregator);
 			if (select_new_active_agg) {
-				printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
-				       slave->dev->master->name);
+				pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+					slave->dev->master->name);
 				// select new active aggregator
 				ad_agg_selection_logic(__get_first_agg(port));
 			}
@@ -2061,8 +2065,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 					// clear the aggregator
 					ad_clear_agg(temp_aggregator);
 					if (select_new_active_agg) {
-						printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
-						       slave->dev->master->name);
+						pr_info(DRV_NAME ": %s: Removing an active aggregator\n",
+							slave->dev->master->name);
 						// select new active aggregator
 						ad_agg_selection_logic(__get_first_agg(port));
 					}
@@ -2110,8 +2114,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		// select the active aggregator for the bond
 		if ((port = __get_first_port(bond))) {
 			if (!port->slave) {
-				printk(KERN_WARNING DRV_NAME ": %s: Warning: bond's first port is "
-				       "uninitialized\n", bond->dev->name);
+				pr_warning(DRV_NAME ": %s: Warning: bond's first port is "
+					   "uninitialized\n", bond->dev->name);
 				goto re_arm;
 			}
 
@@ -2124,8 +2128,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	// for each port run the state machines
 	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
 		if (!port->slave) {
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: Found an uninitialized "
-			       "port\n", bond->dev->name);
+			pr_warning(DRV_NAME ": %s: Warning: Found an uninitialized "
+				   "port\n", bond->dev->name);
 			goto re_arm;
 		}
 
@@ -2166,8 +2170,9 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
 		port = &(SLAVE_AD_INFO(slave).port);
 
 		if (!port->slave) {
-			printk(KERN_WARNING DRV_NAME ": %s: Warning: port of slave %s is "
-			       "uninitialized\n", slave->dev->name, slave->dev->master->name);
+			pr_warning(DRV_NAME ": %s: Warning: port of slave %s "
+				   "is uninitialized\n",
+				   slave->dev->name, slave->dev->master->name);
 			return;
 		}
 
@@ -2212,9 +2217,9 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: %s: speed "
-		       "changed for uninitialized port on %s\n",
-		       slave->dev->master->name, slave->dev->name);
+		pr_warning(DRV_NAME ": Warning: %s: speed "
+			   "changed for uninitialized port on %s\n",
+			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
@@ -2240,9 +2245,9 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": %s: Warning: duplex changed "
-		       "for uninitialized port on %s\n",
-		       slave->dev->master->name, slave->dev->name);
+		pr_warning(DRV_NAME ": %s: Warning: duplex changed "
+			   "for uninitialized port on %s\n",
+			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
@@ -2269,9 +2274,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	// if slave is null, the whole port is not initialized
 	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: %s: link status changed for "
-		       "uninitialized port on %s\n",
-			slave->dev->master->name, slave->dev->name);
+		pr_warning(DRV_NAME ": Warning: %s: link status changed for "
+			   "uninitialized port on %s\n",
+			   slave->dev->master->name, slave->dev->name);
 		return;
 	}
 
@@ -2375,8 +2380,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		printk(KERN_DEBUG DRV_NAME ": %s: Error: "
-		       "bond_3ad_get_active_agg_info failed\n", dev->name);
+		pr_debug(DRV_NAME ": %s: Error: "
+			 "bond_3ad_get_active_agg_info failed\n", dev->name);
 		goto out;
 	}
 
@@ -2385,9 +2390,8 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	if (slaves_in_agg == 0) {
 		/*the aggregator is empty*/
-		printk(KERN_DEBUG DRV_NAME ": %s: Error: active "
-		       "aggregator is empty\n",
-		       dev->name);
+		pr_debug(DRV_NAME ": %s: Error: active aggregator is empty\n",
+			 dev->name);
 		goto out;
 	}
 
@@ -2405,7 +2409,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (slave_agg_no >= 0) {
-		printk(KERN_ERR DRV_NAME ": %s: Error: Couldn't find a slave to tx on "
+		pr_err(DRV_NAME ": %s: Error: Couldn't find a slave to tx on "
 		       "for aggregator ID %d\n", dev->name, agg_id);
 		goto out;
 	}
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bf45d20..2108706 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -194,7 +194,7 @@ static int tlb_initialize(struct bonding *bond)
 
 	new_hashtbl = kzalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: Failed to allocate TLB hash table\n",
 		       bond->dev->name);
 		return -1;
@@ -510,7 +510,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 				 client_info->slave->dev->dev_addr,
 				 client_info->mac_dst);
 		if (!skb) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error: failed to create an ARP packet\n",
 			       client_info->slave->dev->master->name);
 			continue;
@@ -521,7 +521,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 		if (client_info->tag) {
 			skb = vlan_put_tag(skb, client_info->vlan_id);
 			if (!skb) {
-				printk(KERN_ERR DRV_NAME
+				pr_err(DRV_NAME
 				       ": %s: Error: failed to insert VLAN tag\n",
 				       client_info->slave->dev->master->name);
 				continue;
@@ -605,7 +605,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if (!client_info->slave) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error: found a client with no channel in "
 			       "the client's hash table\n",
 			       bond->dev->name);
@@ -802,7 +802,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	new_hashtbl = kmalloc(size, GFP_KERNEL);
 	if (!new_hashtbl) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: Failed to allocate RLB hash table\n",
 		       bond->dev->name);
 		return -1;
@@ -924,7 +924,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 
 			skb = vlan_put_tag(skb, vlan->vlan_id);
 			if (!skb) {
-				printk(KERN_ERR DRV_NAME
+				pr_err(DRV_NAME
 				       ": %s: Error: failed to insert VLAN tag\n",
 				       bond->dev->name);
 				continue;
@@ -954,7 +954,7 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
 	if (dev_set_mac_address(dev, &s_addr)) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: dev_set_mac_address of dev %s failed! ALB "
 		       "mode requires that the base driver support setting "
 		       "the hw address also when the network device's "
@@ -1170,13 +1170,15 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr,
 				       bond->alb_info.rlb_enabled);
 
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Warning: the hw address of slave %s is in use by "
-		       "the bond; giving it the hw address of %s\n",
-		       bond->dev->name, slave->dev->name, free_mac_slave->dev->name);
+		pr_warning(DRV_NAME
+			   ": %s: Warning: the hw address of slave %s is "
+			   "in use by the bond; giving it the hw address "
+			   "of %s\n",
+			   bond->dev->name, slave->dev->name,
+			   free_mac_slave->dev->name);
 
 	} else if (has_bond_addr) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: the hw address of slave %s is in use by the "
 		       "bond; couldn't find a slave with a free hw address to "
 		       "give it (this should not have happened)\n",
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 0d73bf5..83921ab 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -79,14 +79,14 @@ static void bond_na_send(struct net_device *slave_dev,
 			      ND_OPT_TARGET_LL_ADDR);
 
 	if (!skb) {
-		printk(KERN_ERR DRV_NAME ": NA packet allocation failed\n");
+		pr_err(DRV_NAME ": NA packet allocation failed\n");
 		return;
 	}
 
 	if (vlan_id) {
 		skb = vlan_put_tag(skb, vlan_id);
 		if (!skb) {
-			printk(KERN_ERR DRV_NAME ": failed to insert VLAN tag\n");
+			pr_err(DRV_NAME ": failed to insert VLAN tag\n");
 			return;
 		}
 	}
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3bf0cc6..4798d30 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4837,7 +4837,7 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (bond_mode == BOND_MODE_ALB) {
-		printk(KERN_NOTICE DRV_NAME
+		pr_notice(DRV_NAME
 		       ": In ALB mode you might experience client "
 		       "disconnections upon reconnection of a link if the "
 		       "bonding module updelay parameter (%d msec) is "
@@ -4961,9 +4961,9 @@ static int bond_check_params(struct bond_params *params)
 		       arp_ip_count);
 
 		for (i = 0; i < arp_ip_count; i++)
-			printk(" %s", arp_ip_target[i]);
+			pr_info(" %s", arp_ip_target[i]);
 
-		printk("\n");
+		pr_info("\n");
 
 	} else if (max_bonds) {
 		/* miimon and arp_interval not set, we need one so things
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 55bf34f..6044e12 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -218,9 +218,8 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	/* Quick sanity check -- is the bond interface up? */
 	if (!(bond->dev->flags & IFF_UP)) {
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: doing slave updates when interface is down.\n",
-		       bond->dev->name);
+		pr_warning(DRV_NAME ": %s: doing slave updates when "
+			   "interface is down.\n", bond->dev->name);
 	}
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
@@ -778,12 +777,14 @@ static ssize_t bonding_store_downdelay(struct device *d,
 		goto out;
 	} else {
 		if ((new_value % bond->params.miimon) != 0) {
-			printk(KERN_WARNING DRV_NAME
-			       ": %s: Warning: down delay (%d) is not a multiple "
-			       "of miimon (%d), delay rounded to %d ms\n",
-			       bond->dev->name, new_value, bond->params.miimon,
-			       (new_value / bond->params.miimon) *
-			       bond->params.miimon);
+			pr_warning(DRV_NAME
+				   ": %s: Warning: down delay (%d) is not a "
+				   "multiple of miimon (%d), delay rounded "
+				   "to %d ms\n",
+				   bond->dev->name, new_value,
+				   bond->params.miimon,
+				   (new_value / bond->params.miimon) *
+				   bond->params.miimon);
 		}
 		bond->params.downdelay = new_value / bond->params.miimon;
 		pr_info(DRV_NAME ": %s: Setting down delay to %d.\n",
@@ -838,12 +839,14 @@ static ssize_t bonding_store_updelay(struct device *d,
 		goto out;
 	} else {
 		if ((new_value % bond->params.miimon) != 0) {
-			printk(KERN_WARNING DRV_NAME
-			       ": %s: Warning: up delay (%d) is not a multiple "
-			       "of miimon (%d), updelay rounded to %d ms\n",
-			       bond->dev->name, new_value, bond->params.miimon,
-			       (new_value / bond->params.miimon) *
-			       bond->params.miimon);
+			pr_warning(DRV_NAME
+				   ": %s: Warning: up delay (%d) is not a "
+				   "multiple of miimon (%d), updelay rounded "
+				   "to %d ms\n",
+				   bond->dev->name, new_value,
+				   bond->params.miimon,
+				   (new_value / bond->params.miimon) *
+				   bond->params.miimon);
 		}
 		bond->params.updelay = new_value / bond->params.miimon;
 		pr_info(DRV_NAME ": %s: Setting up delay to %d.\n",
@@ -1299,9 +1302,9 @@ static ssize_t bonding_store_active_slave(struct device *d,
         			new_active = slave;
         			if (new_active == old_active) {
 					/* do nothing */
-					printk(KERN_INFO DRV_NAME
-				       	       ": %s: %s is already the current active slave.\n",
-				               bond->dev->name, slave->dev->name);
+					pr_info(DRV_NAME
+						": %s: %s is already the current active slave.\n",
+						bond->dev->name, slave->dev->name);
 					goto out;
 				}
 				else {
@@ -1309,17 +1312,17 @@ static ssize_t bonding_store_active_slave(struct device *d,
             				    (old_active) &&
 				            (new_active->link == BOND_LINK_UP) &&
 				            IS_UP(new_active->dev)) {
-						printk(KERN_INFO DRV_NAME
-				       	              ": %s: Setting %s as active slave.\n",
-				                      bond->dev->name, slave->dev->name);
-                				bond_change_active_slave(bond, new_active);
+						pr_info(DRV_NAME
+							": %s: Setting %s as active slave.\n",
+							bond->dev->name, slave->dev->name);
+							bond_change_active_slave(bond, new_active);
         				}
 					else {
-						printk(KERN_INFO DRV_NAME
-				       	              ": %s: Could not set %s as active slave; "
-						      "either %s is down or the link is down.\n",
-				                      bond->dev->name, slave->dev->name,
-						      slave->dev->name);
+						pr_info(DRV_NAME
+							": %s: Could not set %s as active slave; "
+							"either %s is down or the link is down.\n",
+							bond->dev->name, slave->dev->name,
+							slave->dev->name);
 					}
 					goto out;
 				}
@@ -1537,8 +1540,8 @@ int bond_create_sysfs(void)
 		/* Is someone being kinky and naming a device bonding_master? */
 		if (__dev_get_by_name(&init_net,
 				      class_attr_bonding_masters.attr.name))
-			printk(KERN_ERR
-			       "network device named %s already exists in sysfs",
+			pr_err("network device named %s already "
+			       "exists in sysfs",
 			       class_attr_bonding_masters.attr.name);
 		ret = 0;
 	}
@@ -1566,7 +1569,7 @@ int bond_create_sysfs_entry(struct bonding *bond)
 
 	err = sysfs_create_group(&(dev->dev.kobj), &bonding_group);
 	if (err)
-		printk(KERN_EMERG "eek! didn't create group!\n");
+		pr_emerg("eek! didn't create group!\n");
 
 	return err;
 }
