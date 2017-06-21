From: Michael J Dilmore <michael.j.dilmore@gmail.com>
Subject: [PATCH] PATCH v3 Convert multiple netdev_info messages to netdev_dbg
Date: Wed, 21 Jun 2017 03:08:54 +0100
Message-ID: <1498010934-27703-1-git-send-email-michael.j.dilmore@gmail.com>
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com,
        Michael J Dilmore <michael.j.dilmore@gmail.com>
To: j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bond_options.c file contains multiple netdev_info messages that
clutter kernel output. This patches replaces these with netdev_dbg messages
and adds a netdev_dbg for packets for slave.

Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
Suggested-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_options.c | 54 +++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index e3a9af6..9110e5b 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -722,13 +722,13 @@ static int bond_option_mode_set(struct bonding *bond,
 {
 	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
 		netdev_dbg(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
-			    newval->string);
+			   newval->string);
 		/* disable arp monitoring */
 		bond->params.arp_interval = 0;
 		/* set miimon to default value */
 		bond->params.miimon = BOND_DEFAULT_MIIMON;
 		netdev_dbg(bond->dev, "Setting MII monitoring interval to %d\n",
-			    bond->params.miimon);
+			   bond->params.miimon);
 	}
 
 	/* don't cache arp_validate between modes */
@@ -783,12 +783,12 @@ static int bond_option_active_slave_set(struct bonding *bond,
 		if (new_active == old_active) {
 			/* do nothing */
 			netdev_dbg(bond->dev, "%s is already the current active slave\n",
-				    new_active->dev->name);
+				   new_active->dev->name);
 		} else {
 			if (old_active && (new_active->link == BOND_LINK_UP) &&
 			    bond_slave_is_up(new_active)) {
 				netdev_dbg(bond->dev, "Setting %s as active slave\n",
-					    new_active->dev->name);
+					   new_active->dev->name);
 				bond_change_active_slave(bond, new_active);
 			} else {
 				netdev_err(bond->dev, "Could not set %s as active slave; either %s is down or the link is down\n",
@@ -811,14 +811,14 @@ static int bond_option_miimon_set(struct bonding *bond,
 				  const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting MII monitoring interval to %llu\n",
-		    newval->value);
+		   newval->value);
 	bond->params.miimon = newval->value;
 	if (bond->params.updelay)
 		netdev_dbg(bond->dev, "Note: Updating updelay (to %d) since it is a multiple of the miimon value\n",
-			bond->params.updelay * bond->params.miimon);
+			   bond->params.updelay * bond->params.miimon);
 	if (bond->params.downdelay)
 		netdev_dbg(bond->dev, "Note: Updating downdelay (to %d) since it is a multiple of the miimon value\n",
-			    bond->params.downdelay * bond->params.miimon);
+			   bond->params.downdelay * bond->params.miimon);
 	if (newval->value && bond->params.arp_interval) {
 		netdev_dbg(bond->dev, "MII monitoring cannot be used with ARP monitoring - disabling ARP monitoring...\n");
 		bond->params.arp_interval = 0;
@@ -863,7 +863,7 @@ static int bond_option_updelay_set(struct bonding *bond,
 	}
 	bond->params.updelay = value / bond->params.miimon;
 	netdev_dbg(bond->dev, "Setting up delay to %d\n",
-		    bond->params.updelay * bond->params.miimon);
+		   bond->params.updelay * bond->params.miimon);
 
 	return 0;
 }
@@ -885,7 +885,7 @@ static int bond_option_downdelay_set(struct bonding *bond,
 	}
 	bond->params.downdelay = value / bond->params.miimon;
 	netdev_dbg(bond->dev, "Setting down delay to %d\n",
-		    bond->params.downdelay * bond->params.miimon);
+		   bond->params.downdelay * bond->params.miimon);
 
 	return 0;
 }
@@ -894,7 +894,7 @@ static int bond_option_use_carrier_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting use_carrier to %llu\n",
-		    newval->value);
+		   newval->value);
 	bond->params.use_carrier = newval->value;
 
 	return 0;
@@ -908,7 +908,7 @@ static int bond_option_arp_interval_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting ARP monitoring interval to %llu\n",
-		    newval->value);
+		   newval->value);
 	bond->params.arp_interval = newval->value;
 	if (newval->value) {
 		if (bond->params.miimon) {
@@ -1066,7 +1066,7 @@ static int bond_option_arp_validate_set(struct bonding *bond,
 					const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting arp_validate to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 
 	if (bond->dev->flags & IFF_UP) {
 		if (!newval->value)
@@ -1083,7 +1083,7 @@ static int bond_option_arp_all_targets_set(struct bonding *bond,
 					   const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting arp_all_targets to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.arp_all_targets = newval->value;
 
 	return 0;
@@ -1113,7 +1113,7 @@ static int bond_option_primary_set(struct bonding *bond,
 	bond_for_each_slave(bond, slave, iter) {
 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
 			netdev_dbg(bond->dev, "Setting %s as primary slave\n",
-				    slave->dev->name);
+				   slave->dev->name);
 			rcu_assign_pointer(bond->primary_slave, slave);
 			strcpy(bond->params.primary, slave->dev->name);
 			bond_select_active_slave(bond);
@@ -1130,7 +1130,7 @@ static int bond_option_primary_set(struct bonding *bond,
 	bond->params.primary[IFNAMSIZ - 1] = 0;
 
 	netdev_dbg(bond->dev, "Recording %s as primary, but it has not been enslaved to %s yet\n",
-		    primary, bond->dev->name);
+		   primary, bond->dev->name);
 
 out:
 	unblock_netpoll_tx();
@@ -1142,7 +1142,7 @@ static int bond_option_primary_reselect_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting primary_reselect to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.primary_reselect = newval->value;
 
 	block_netpoll_tx();
@@ -1156,7 +1156,7 @@ static int bond_option_fail_over_mac_set(struct bonding *bond,
 					 const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting fail_over_mac to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.fail_over_mac = newval->value;
 
 	return 0;
@@ -1166,7 +1166,7 @@ static int bond_option_xmit_hash_policy_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting xmit hash policy to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.xmit_policy = newval->value;
 
 	return 0;
@@ -1176,7 +1176,7 @@ static int bond_option_resend_igmp_set(struct bonding *bond,
 				       const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting resend_igmp to %llu\n",
-		    newval->value);
+		   newval->value);
 	bond->params.resend_igmp = newval->value;
 
 	return 0;
@@ -1215,7 +1215,7 @@ static int bond_option_min_links_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting min links value to %llu\n",
-		    newval->value);
+		   newval->value);
 	bond->params.min_links = newval->value;
 	bond_set_carrier(bond);
 
@@ -1233,7 +1233,7 @@ static int bond_option_lp_interval_set(struct bonding *bond,
 static int bond_option_pps_set(struct bonding *bond,
 			       const struct bond_opt_value *newval)
 {	netdev_dbg(bond->dev, "Setting packets per slave value to %llu\n",
-		    	newval->value);
+		   newval->value);
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
 		bond->params.reciprocal_packets_per_slave =
@@ -1253,7 +1253,7 @@ static int bond_option_lacp_rate_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting LACP rate to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.lacp_fast = newval->value;
 	bond_3ad_update_lacp_rate(bond);
 
@@ -1264,7 +1264,7 @@ static int bond_option_ad_select_set(struct bonding *bond,
 				     const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting ad_select to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.ad_select = newval->value;
 
 	return 0;
@@ -1348,7 +1348,7 @@ static int bond_option_slaves_set(struct bonding *bond,
 	dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 	if (!dev) {
 		netdev_dbg(bond->dev, "interface %s does not exist!\n",
-			    ifname);
+			   ifname);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -1381,7 +1381,7 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
 					  const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting dynamic-lb to %s (%llu)\n",
-		    newval->string, newval->value);
+		   newval->string, newval->value);
 	bond->params.tlb_dynamic_lb = newval->value;
 
 	return 0;
@@ -1391,7 +1391,7 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 					     const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting ad_actor_sys_prio to %llu\n",
-		    newval->value);
+		   newval->value);
 
 	bond->params.ad_actor_sys_prio = newval->value;
 	bond_3ad_update_ad_actor_settings(bond);
@@ -1435,7 +1435,7 @@ static int bond_option_ad_user_port_key_set(struct bonding *bond,
 					    const struct bond_opt_value *newval)
 {
 	netdev_dbg(bond->dev, "Setting ad_user_port_key to %llu\n",
-		    newval->value);
+		   newval->value);
 
 	bond->params.ad_user_port_key = newval->value;
 	return 0;
-- 
2.7.4
