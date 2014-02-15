From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/4] bonding: Convert pr_warning to pr_warn, neatening
Date: Sat, 15 Feb 2014 15:57:04 -0800
Message-ID: <72d03048d12d39654ca316f01f62ca795e9d275d.1392508410.git.joe@perches.com>
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

Use more current logging style.

Coalesce formats, realign arguments, drop unnecessary periods.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_alb.c     |   6 +-
 drivers/net/bonding/bond_debugfs.c |  10 ++--
 drivers/net/bonding/bond_main.c    | 116 ++++++++++++++++++-------------------
 drivers/net/bonding/bond_procfs.c  |   8 +--
 4 files changed, 67 insertions(+), 73 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a212860..e9f0a98 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1243,9 +1243,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	if (free_mac_slave) {
 		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr);
 
-		pr_warning("%s: Warning: the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
-			   bond->dev->name, slave->dev->name,
-			   free_mac_slave->dev->name);
+		pr_warn("%s: Warning: the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
+			bond->dev->name, slave->dev->name,
+			free_mac_slave->dev->name);
 
 	} else if (has_bond_addr) {
 		pr_err("%s: Error: the hw address of slave %s is in use by the bond; couldn't find a slave with a free hw address to give it (this should not have happened)\n",
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 5fc4c23..2d3f7fa 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -69,7 +69,7 @@ void bond_debug_register(struct bonding *bond)
 		debugfs_create_dir(bond->dev->name, bonding_debug_root);
 
 	if (!bond->debug_dir) {
-		pr_warning("%s: Warning: failed to register to debugfs\n",
+		pr_warn("%s: Warning: failed to register to debugfs\n",
 			bond->dev->name);
 		return;
 	}
@@ -98,9 +98,8 @@ void bond_debug_reregister(struct bonding *bond)
 	if (d) {
 		bond->debug_dir = d;
 	} else {
-		pr_warning("%s: Warning: failed to reregister, "
-				"so just unregister old one\n",
-				bond->dev->name);
+		pr_warn("%s: Warning: failed to reregister, so just unregister old one\n",
+			bond->dev->name);
 		bond_debug_unregister(bond);
 	}
 }
@@ -110,8 +109,7 @@ void bond_create_debugfs(void)
 	bonding_debug_root = debugfs_create_dir("bonding", NULL);
 
 	if (!bonding_debug_root) {
-		pr_warning("Warning: Cannot create bonding directory"
-				" in debugfs\n");
+		pr_warn("Warning: Cannot create bonding directory in debugfs\n");
 	}
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 58aa531..1d4dfc9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1183,8 +1183,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	if (!bond->params.use_carrier &&
 	    slave_dev->ethtool_ops->get_link == NULL &&
 	    slave_ops->ndo_do_ioctl == NULL) {
-		pr_warning("%s: Warning: no link monitoring support for %s\n",
-			   bond_dev->name, slave_dev->name);
+		pr_warn("%s: Warning: no link monitoring support for %s\n",
+			bond_dev->name, slave_dev->name);
 	}
 
 	/* already enslaved */
@@ -1202,9 +1202,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
 		} else {
-			pr_warning("%s: Warning: enslaved VLAN challenged slave %s. Adding VLANs will be blocked as long as %s is part of bond %s\n",
-				   bond_dev->name, slave_dev->name,
-				   slave_dev->name, bond_dev->name);
+			pr_warn("%s: Warning: enslaved VLAN challenged slave %s. Adding VLANs will be blocked as long as %s is part of bond %s\n",
+				bond_dev->name, slave_dev->name,
+				slave_dev->name, bond_dev->name);
 		}
 	} else {
 		pr_debug("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
@@ -1419,12 +1419,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			 * supported); thus, we don't need to change
 			 * the messages for netif_carrier.
 			 */
-			pr_warning("%s: Warning: MII and ETHTOOL support not available for interface %s, and arp_interval/arp_ip_target module parameters not specified, thus bonding will not detect link failures! see bonding.txt for details.\n",
-			       bond_dev->name, slave_dev->name);
+			pr_warn("%s: Warning: MII and ETHTOOL support not available for interface %s, and arp_interval/arp_ip_target module parameters not specified, thus bonding will not detect link failures! see bonding.txt for details\n",
+				bond_dev->name, slave_dev->name);
 		} else if (link_reporting == -1) {
 			/* unable get link status using mii/ethtool */
-			pr_warning("%s: Warning: can't get link status from interface %s; the network driver associated with this interface does not support MII or ETHTOOL link status reporting, thus miimon has no effect on this interface.\n",
-				   bond_dev->name, slave_dev->name);
+			pr_warn("%s: Warning: can't get link status from interface %s; the network driver associated with this interface does not support MII or ETHTOOL link status reporting, thus miimon has no effect on this interface\n",
+				bond_dev->name, slave_dev->name);
 		}
 	}
 
@@ -1725,10 +1725,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 		eth_hw_addr_random(bond_dev);
 
 		if (vlan_uses_dev(bond_dev)) {
-			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
-				   bond_dev->name, bond_dev->name);
-			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
-				   bond_dev->name);
+			pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
+				bond_dev->name, bond_dev->name);
+			pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
+				bond_dev->name);
 		}
 	}
 
@@ -4046,74 +4046,71 @@ static int bond_check_params(struct bond_params *params)
 		}
 		params->ad_select = valptr->value;
 		if (bond_mode != BOND_MODE_8023AD)
-			pr_warning("ad_select param only affects 802.3ad mode\n");
+			pr_warn("ad_select param only affects 802.3ad mode\n");
 	} else {
 		params->ad_select = BOND_AD_STABLE;
 	}
 
 	if (max_bonds < 0) {
-		pr_warning("Warning: max_bonds (%d) not in range %d-%d, so it was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
-			   max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
+		pr_warn("Warning: max_bonds (%d) not in range %d-%d, so it was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
+			max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
 
 	if (miimon < 0) {
-		pr_warning("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to 0\n",
-			   miimon, INT_MAX);
+		pr_warn("Warning: miimon module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			miimon, INT_MAX);
 		miimon = 0;
 	}
 
 	if (updelay < 0) {
-		pr_warning("Warning: updelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
-			   updelay, INT_MAX);
+		pr_warn("Warning: updelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			updelay, INT_MAX);
 		updelay = 0;
 	}
 
 	if (downdelay < 0) {
-		pr_warning("Warning: downdelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
-			   downdelay, INT_MAX);
+		pr_warn("Warning: downdelay module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			downdelay, INT_MAX);
 		downdelay = 0;
 	}
 
 	if ((use_carrier != 0) && (use_carrier != 1)) {
-		pr_warning("Warning: use_carrier module parameter (%d), not of valid value (0/1), so it was set to 1\n",
-			   use_carrier);
+		pr_warn("Warning: use_carrier module parameter (%d), not of valid value (0/1), so it was set to 1\n",
+			use_carrier);
 		use_carrier = 1;
 	}
 
 	if (num_peer_notif < 0 || num_peer_notif > 255) {
-		pr_warning("Warning: num_grat_arp/num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
-			   num_peer_notif);
+		pr_warn("Warning: num_grat_arp/num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
+			num_peer_notif);
 		num_peer_notif = 1;
 	}
 
 	/* reset values for 802.3ad/TLB/ALB */
 	if (BOND_NO_USES_ARP(bond_mode)) {
 		if (!miimon) {
-			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
-			pr_warning("Forcing miimon to 100msec\n");
+			pr_warn("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
+			pr_warn("Forcing miimon to 100msec\n");
 			miimon = BOND_DEFAULT_MIIMON;
 		}
 	}
 
 	if (tx_queues < 1 || tx_queues > 255) {
-		pr_warning("Warning: tx_queues (%d) should be between "
-			   "1 and 255, resetting to %d\n",
-			   tx_queues, BOND_DEFAULT_TX_QUEUES);
+		pr_warn("Warning: tx_queues (%d) should be between 1 and 255, resetting to %d\n",
+			tx_queues, BOND_DEFAULT_TX_QUEUES);
 		tx_queues = BOND_DEFAULT_TX_QUEUES;
 	}
 
 	if ((all_slaves_active != 0) && (all_slaves_active != 1)) {
-		pr_warning("Warning: all_slaves_active module parameter (%d), "
-			   "not of valid value (0/1), so it was set to "
-			   "0\n", all_slaves_active);
+		pr_warn("Warning: all_slaves_active module parameter (%d), not of valid value (0/1), so it was set to 0\n",
+			all_slaves_active);
 		all_slaves_active = 0;
 	}
 
 	if (resend_igmp < 0 || resend_igmp > 255) {
-		pr_warning("Warning: resend_igmp (%d) should be between "
-			   "0 and 255, resetting to %d\n",
-			   resend_igmp, BOND_DEFAULT_RESEND_IGMP);
+		pr_warn("Warning: resend_igmp (%d) should be between 0 and 255, resetting to %d\n",
+			resend_igmp, BOND_DEFAULT_RESEND_IGMP);
 		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 	}
 
@@ -4134,37 +4131,36 @@ static int bond_check_params(struct bond_params *params)
 			/* just warn the user the up/down delay will have
 			 * no effect since miimon is zero...
 			 */
-			pr_warning("Warning: miimon module parameter not set and updelay (%d) or downdelay (%d) module parameter is set; updelay and downdelay have no effect unless miimon is set\n",
-				   updelay, downdelay);
+			pr_warn("Warning: miimon module parameter not set and updelay (%d) or downdelay (%d) module parameter is set; updelay and downdelay have no effect unless miimon is set\n",
+				updelay, downdelay);
 		}
 	} else {
 		/* don't allow arp monitoring */
 		if (arp_interval) {
-			pr_warning("Warning: miimon (%d) and arp_interval (%d) can't be used simultaneously, disabling ARP monitoring\n",
-				   miimon, arp_interval);
+			pr_warn("Warning: miimon (%d) and arp_interval (%d) can't be used simultaneously, disabling ARP monitoring\n",
+				miimon, arp_interval);
 			arp_interval = 0;
 		}
 
 		if ((updelay % miimon) != 0) {
-			pr_warning("Warning: updelay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
-				   updelay, miimon,
-				   (updelay / miimon) * miimon);
+			pr_warn("Warning: updelay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
+				updelay, miimon, (updelay / miimon) * miimon);
 		}
 
 		updelay /= miimon;
 
 		if ((downdelay % miimon) != 0) {
-			pr_warning("Warning: downdelay (%d) is not a multiple of miimon (%d), downdelay rounded to %d ms\n",
-				   downdelay, miimon,
-				   (downdelay / miimon) * miimon);
+			pr_warn("Warning: downdelay (%d) is not a multiple of miimon (%d), downdelay rounded to %d ms\n",
+				downdelay, miimon,
+				(downdelay / miimon) * miimon);
 		}
 
 		downdelay /= miimon;
 	}
 
 	if (arp_interval < 0) {
-		pr_warning("Warning: arp_interval module parameter (%d) , not in range 0-%d, so it was reset to 0\n",
-			   arp_interval, INT_MAX);
+		pr_warn("Warning: arp_interval module parameter (%d), not in range 0-%d, so it was reset to 0\n",
+			arp_interval, INT_MAX);
 		arp_interval = 0;
 	}
 
@@ -4175,22 +4171,22 @@ static int bond_check_params(struct bond_params *params)
 		__be32 ip;
 		if (!in4_pton(arp_ip_target[i], -1, (u8 *)&ip, -1, NULL) ||
 		    IS_IP_TARGET_UNUSABLE_ADDRESS(ip)) {
-			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
-				   arp_ip_target[i]);
+			pr_warn("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
+				arp_ip_target[i]);
 			arp_interval = 0;
 		} else {
 			if (bond_get_targets_ip(arp_target, ip) == -1)
 				arp_target[arp_ip_count++] = ip;
 			else
-				pr_warning("Warning: duplicate address %pI4 in arp_ip_target, skipping\n",
-					   &ip);
+				pr_warn("Warning: duplicate address %pI4 in arp_ip_target, skipping\n",
+					&ip);
 		}
 	}
 
 	if (arp_interval && !arp_ip_count) {
 		/* don't allow arping if no arp_ip_target given... */
-		pr_warning("Warning: arp_interval module parameter (%d) specified without providing an arp_ip_target parameter, arp_interval was reset to 0\n",
-			   arp_interval);
+		pr_warn("Warning: arp_interval module parameter (%d) specified without providing an arp_ip_target parameter, arp_interval was reset to 0\n",
+			arp_interval);
 		arp_interval = 0;
 	}
 
@@ -4255,8 +4251,8 @@ static int bond_check_params(struct bond_params *params)
 		/* currently, using a primary only makes sense
 		 * in active backup, TLB or ALB modes
 		 */
-		pr_warning("Warning: %s primary device specified but has no effect in %s mode\n",
-			   primary, bond_mode_name(bond_mode));
+		pr_warn("Warning: %s primary device specified but has no effect in %s mode\n",
+			primary, bond_mode_name(bond_mode));
 		primary = NULL;
 	}
 
@@ -4285,14 +4281,14 @@ static int bond_check_params(struct bond_params *params)
 		}
 		fail_over_mac_value = valptr->value;
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
-			pr_warning("Warning: fail_over_mac only affects active-backup mode.\n");
+			pr_warn("Warning: fail_over_mac only affects active-backup mode\n");
 	} else {
 		fail_over_mac_value = BOND_FOM_NONE;
 	}
 
 	if (lp_interval == 0) {
-		pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
-			   INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
+		pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
+			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
 		lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
 	}
 
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 3ac20e7..f86fcc7 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -254,8 +254,8 @@ void bond_create_proc_entry(struct bonding *bond)
 						    S_IRUGO, bn->proc_dir,
 						    &bond_info_fops, bond);
 		if (bond->proc_entry == NULL)
-			pr_warning("Warning: Cannot create /proc/net/%s/%s\n",
-				   DRV_NAME, bond_dev->name);
+			pr_warn("Warning: Cannot create /proc/net/%s/%s\n",
+				DRV_NAME, bond_dev->name);
 		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
 	}
@@ -281,8 +281,8 @@ void __net_init bond_create_proc_dir(struct bond_net *bn)
 	if (!bn->proc_dir) {
 		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
 		if (!bn->proc_dir)
-			pr_warning("Warning: cannot create /proc/net/%s\n",
-				   DRV_NAME);
+			pr_warn("Warning: cannot create /proc/net/%s\n",
+				DRV_NAME);
 	}
 }
 
-- 
1.8.1.2.459.gbcd45b4.dirty
