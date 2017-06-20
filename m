From: Michael J Dilmore <michael.j.dilmore@gmail.com>
Subject: [PATCH] [PATCH v2 net-next] bonding: Convert multiple netdev_info messages to netdev_dbg
Date: Tue, 20 Jun 2017 23:05:31 +0100
Message-ID: <1497996331-24500-1-git-send-email-michael.j.dilmore@gmail.com>
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com,
        Michael J Dilmore <michael.j.dilmore@gmail.com>
To: j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bond_options.c file contains several netdev_info messages that clutter kernel output. This patch changes all netdev_info messages
to netdev_dbg and adds a netdev debug for the packets per slave parameter.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
---
 drivers/net/bonding/bond_options.c | 79 +++++++++++++++++++-------------------
 1 file changed, 40 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1bcbb89..e3a9af6 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -721,13 +721,13 @@ static int bond_option_mode_set(struct bonding *bond,
 				const struct bond_opt_value *newval)
 {
 	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
-		netdev_info(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
+		netdev_dbg(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
 			    newval->string);
 		/* disable arp monitoring */
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
 		bond->params.miimon = BOND_DEFAULT_MIIMON;
-		netdev_info(bond->dev, "Setting MII monitoring interval to %d\n",
+		netdev_dbg(bond->dev, "Setting MII monitoring interval to %d\n",
 			    bond->params.miimon);
 	}
 
@@ -771,7 +771,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
 	block_netpoll_tx();
 	/* check to see if we are clearing active */
 	if (!slave_dev) {
-		netdev_info(bond->dev, "Clearing current active slave\n");
+		netdev_dbg(bond->dev, "Clearing current active slave\n");
 		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 		bond_select_active_slave(bond);
 	} else {
@@ -782,12 +782,12 @@ static int bond_option_active_slave_set(struct bonding *bond,
 
 		if (new_active == old_active) {
 			/* do nothing */
-			netdev_info(bond->dev, "%s is already the current active slave\n",
+			netdev_dbg(bond->dev, "%s is already the current active slave\n",
 				    new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
 			    bond_slave_is_up(new_active)) {
-				netdev_info(bond->dev, "Setting %s as active slave\n",
+				netdev_dbg(bond->dev, "Setting %s as active slave\n",
 					    new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
 			} else {
@@ -810,17 +810,17 @@ static int bond_option_active_slave_set(struct bonding *bond,
 static int bond_option_miimon_set(struct bonding *bond,
 				  const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting MII monitoring interval to %llu\n",
+	netdev_dbg(bond->dev, "Setting MII monitoring interval to %llu\n",
 		    newval->value);
 	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
-		netdev_info(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
+		netdev_dbg(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
 			bond->params.updelay * bond->params.miimon);
 	if (bond->params.downdelay)
-		netdev_info(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
+		netdev_dbg(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
 			    bond->params.downdelay * bond->params.miimon);
 	if (newval->value && bond->params.arp_interval) {
-		netdev_info(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
+		netdev_dbg(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
 		bond->params.arp_interval = 0;
 		if (bond->params.arp_validate)
 			bond->params.arp_validate = BOND_ARP_VALIDATE_NONE;
@@ -862,7 +862,7 @@ static int bond_option_updelay_set(struct bonding *bond,
 			    bond->params.miimon);
 	}
 	bond->params.updelay = value / bond->params.miimon;
-	netdev_info(bond->dev, "Setting up delay to %d\n",
+	netdev_dbg(bond->dev, "Setting up delay to %d\n",
 		    bond->params.updelay * bond->params.miimon);
 
 	return 0;
@@ -884,7 +884,7 @@ static int bond_option_downdelay_set(struct bonding *bond,
 			    bond->params.miimon);
 	}
 	bond->params.downdelay = value / bond->params.miimon;
-	netdev_info(bond->dev, "Setting down delay to %d\n",
+	netdev_dbg(bond->dev, "Setting down delay to %d\n",
 		    bond->params.downdelay * bond->params.miimon);
 
 	return 0;
@@ -893,7 +893,7 @@ static int bond_option_downdelay_set(struct bonding *bond,
 static int bond_option_use_carrier_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting use_carrier to %llu\n",
+	netdev_dbg(bond->dev, "Setting use_carrier to %llu\n",
 		    newval->value);
 	bond->params.use_carrier = newval->value;
 
@@ -907,16 +907,16 @@ static int bond_option_use_carrier_set(struct bonding *bond,
 static int bond_option_arp_interval_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ARP monitoring interval to %llu\n",
+	netdev_dbg(bond->dev, "Setting ARP monitoring interval to %llu\n",
 		    newval->value);
 	bond->params.arp_interval = newval->value;
 	if (newval->value) {
 		if (bond->params.miimon) {
-			netdev_info(bond->dev, "ARP monitoring cannot be used with MII monitoring. Disabling MII monitoring\n");
+			netdev_dbg(bond->dev, "ARP monitoring cannot be used with MII monitoring. Disabling MII monitoring\n");
 			bond->params.miimon = 0;
 		}
 		if (!bond->params.arp_targets[0])
-			netdev_info(bond->dev, "ARP monitoring has been set up, but no ARP targets have been specified\n");
+			netdev_dbg(bond->dev, "ARP monitoring has been set up, but no ARP targets have been specified\n");
 	}
 	if (bond->dev->flags & IFF_UP) {
 		/* If the interface is up, we may need to fire off
@@ -977,7 +977,7 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 		return -EINVAL;
 	}
 
-	netdev_info(bond->dev, "Adding ARP target %pI4\n", &target);
+	netdev_dbg(bond->dev, "Adding ARP target %pI4\n", &target);
 
 	_bond_options_arp_ip_target_set(bond, ind, target, jiffies);
 
@@ -1013,7 +1013,7 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 	if (ind == 0 && !targets[1] && bond->params.arp_interval)
 		netdev_warn(bond->dev, "Removing last arp target with arp_interval on\n");
 
-	netdev_info(bond->dev, "Removing ARP target %pI4\n", &target);
+	netdev_dbg(bond->dev, "Removing ARP target %pI4\n", &target);
 
 	bond_for_each_slave(bond, slave, iter) {
 		targets_rx = slave->target_last_arp_rx;
@@ -1065,7 +1065,7 @@ static int bond_option_arp_ip_targets_set(struct bonding *bond,
 static int bond_option_arp_validate_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting arp_validate to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting arp_validate to %s (%llu)\n",
 		    newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
@@ -1082,7 +1082,7 @@ static int bond_option_arp_validate_set(struct bonding *bond,
 static int bond_option_arp_all_targets_set(struct bonding *bond,
 					   const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.arp_all_targets = newval->value;
 
@@ -1103,7 +1103,7 @@ static int bond_option_primary_set(struct bonding *bond,
 		*p = '\0';
 	/* check to see if we are clearing primary */
 	if (!strlen(primary)) {
-		netdev_info(bond->dev, "Setting primary slave to None\n");
+		netdev_dbg(bond->dev, "Setting primary slave to None\n");
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
@@ -1112,7 +1112,7 @@ static int bond_option_primary_set(struct bonding *bond,
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
-			netdev_info(bond->dev, "Setting %s as primary slave\n",
+			netdev_dbg(bond->dev, "Setting %s as primary slave\n",
 				    slave->dev->name);
 			rcu_assign_pointer(bond->primary_slave, slave);
 			strcpy(bond->params.primary, slave->dev->name);
@@ -1122,14 +1122,14 @@ static int bond_option_primary_set(struct bonding *bond,
 	}
 
 	if (rtnl_dereference(bond->primary_slave)) {
-		netdev_info(bond->dev, "Setting primary slave to None\n");
+		netdev_dbg(bond->dev, "Setting primary slave to None\n");
 		RCU_INIT_POINTER(bond->primary_slave, NULL);
 		bond_select_active_slave(bond);
 	}
 	strncpy(bond->params.primary, primary, IFNAMSIZ);
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
-	netdev_info(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
+	netdev_dbg(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
 		    primary, bond->dev->name);
 
 out:
@@ -1141,7 +1141,7 @@ static int bond_option_primary_set(struct bonding *bond,
 static int bond_option_primary_reselect_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting primary_reselect to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting primary_reselect to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.primary_reselect = newval->value;
 
@@ -1155,7 +1155,7 @@ static int bond_option_primary_reselect_set(struct bonding *bond,
 static int bond_option_fail_over_mac_set(struct bonding *bond,
 					 const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.fail_over_mac = newval->value;
 
@@ -1165,7 +1165,7 @@ static int bond_option_fail_over_mac_set(struct bonding *bond,
 static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.xmit_policy = newval->value;
 
@@ -1175,7 +1175,7 @@ static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 static int bond_option_resend_igmp_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting resend_igmp to %llu\n",
+	netdev_dbg(bond->dev, "Setting resend_igmp to %llu\n",
 		    newval->value);
 	bond->params.resend_igmp = newval->value;
 
@@ -1214,7 +1214,7 @@ static int bond_option_all_slaves_active_set(struct bonding *bond,
 static int bond_option_min_links_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting min links value to %llu\n",
+	netdev_dbg(bond->dev, "Setting min links value to %llu\n",
 		    newval->value);
 	bond->params.min_links = newval->value;
 	bond_set_carrier(bond);
@@ -1232,7 +1232,8 @@ static int bond_option_lp_interval_set(struct bonding *bond,
 
 static int bond_option_pps_set(struct bonding *bond,
 			       const struct bond_opt_value *newval)
-{
+{	netdev_dbg(bond->dev, "Setting packets per slave value to %llu\n",
+		    	newval->value);
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
 		bond->params.reciprocal_packets_per_slave =
@@ -1251,7 +1252,7 @@ static int bond_option_pps_set(struct bonding *bond,
 static int bond_option_lacp_rate_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting LACP rate to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting LACP rate to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
@@ -1262,7 +1263,7 @@ static int bond_option_lacp_rate_set(struct bonding *bond,
 static int bond_option_ad_select_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_select to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting ad_select to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.ad_select = newval->value;
 
@@ -1324,7 +1325,7 @@ static int bond_option_queue_id_set(struct bonding *bond,
 	return ret;
 
 err_no_cmd:
-	netdev_info(bond->dev, "invalid input for queue_id set\n");
+	netdev_dbg(bond->dev, "invalid input for queue_id set\n");
 	ret = -EPERM;
 	goto out;
 
@@ -1346,7 +1347,7 @@ static int bond_option_slaves_set(struct bonding *bond,
 
 	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 	if (!dev) {
-		netdev_info(bond->dev, "interface %s does not exist!\n",
+		netdev_dbg(bond->dev, "interface %s does not exist!\n",
 			    ifname);
 		ret = -ENODEV;
 		goto out;
@@ -1354,12 +1355,12 @@ static int bond_option_slaves_set(struct bonding *bond,
 
 	switch (command[0]) {
 	case '+':
-		netdev_info(bond->dev, "Adding slave %s\n", dev->name);
+		netdev_dbg(bond->dev, "Adding slave %s\n", dev->name);
 		ret = bond_enslave(bond->dev, dev);
 		break;
 
 	case '-':
-		netdev_info(bond->dev, "Removing slave %s\n", dev->name);
+		netdev_dbg(bond->dev, "Removing slave %s\n", dev->name);
 		ret = bond_release(bond->dev, dev);
 		break;
 
@@ -1379,7 +1380,7 @@ static int bond_option_slaves_set(struct bonding *bond,
 static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 					  const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
+	netdev_dbg(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
 		    newval->string, newval->value);
 	bond->params.tlb_dynamic_lb = newval->value;
 
@@ -1389,7 +1390,7 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
+	netdev_dbg(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
 		    newval->value);
 
 	bond->params.ad_actor_sys_prio = newval->value;
@@ -1419,7 +1420,7 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 	if (!is_valid_ether_addr(mac))
 		goto err;
 
-	netdev_info(bond->dev, "Setting ad_actor_system to %pM\n", mac);
+	netdev_dbg(bond->dev, "Setting ad_actor_system to %pM\n", mac);
 	ether_addr_copy(bond->params.ad_actor_system, mac);
 	bond_3ad_update_ad_actor_settings(bond);
 
@@ -1433,7 +1434,7 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 static int bond_option_ad_user_port_key_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
-	netdev_info(bond->dev, "Setting ad_user_port_key to %llu\n",
+	netdev_dbg(bond->dev, "Setting ad_user_port_key to %llu\n",
 		    newval->value);
 
 	bond->params.ad_user_port_key = newval->value;
-- 
2.7.4
