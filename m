From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] bonding: bond_create always called with default parameters
Date: Wed, 10 Jun 2009 09:39:56 -0700
Message-ID: <20090610164258.072753193@vyatta.com>
References: <20090610163955.266850193@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34297 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014AbZFJRdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 13:33:54 -0400
Content-Disposition: inline; filename=bond-default-params.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_create() is always called with same parameters so move the argument
down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2009-06-10 09:21:10.778039138 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-10 09:23:14.691057890 -0700
@@ -101,7 +101,7 @@ static int arp_interval = BOND_LINK_ARP_
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
 static char *fail_over_mac = NULL;
-struct bond_params bonding_defaults;
+static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -5099,7 +5099,7 @@ static void bond_set_lockdep_class(struc
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(char *name, struct bond_params *params)
+int bond_create(const char *name)
 {
 	struct net_device *bond_dev;
 	struct bonding *bond;
@@ -5141,7 +5141,7 @@ int bond_create(char *name, struct bond_
 	 * need to set function pointers.
 	 */
 
-	res = bond_init(bond_dev, params);
+	res = bond_init(bond_dev, &bonding_defaults);
 	if (res < 0) {
 		goto out_netdev;
 	}
@@ -5196,7 +5196,7 @@ static int __init bonding_init(void)
 	init_rwsem(&bonding_rwsem);
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults);
+		res = bond_create(NULL);
 		if (res)
 			goto err;
 	}
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-10 09:22:13.030517018 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-10 09:22:20.236043038 -0700
@@ -112,7 +112,7 @@ static ssize_t bonding_store_bonds(struc
 	if (command[0] == '+') {
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname, &bonding_defaults);
+		rv = bond_create(ifname);
 		if (rv) {
 			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
 			res = rv;
--- a/drivers/net/bonding/bonding.h	2009-06-10 09:20:42.934041678 -0700
+++ b/drivers/net/bonding/bonding.h	2009-06-10 09:21:04.103501875 -0700
@@ -322,7 +322,7 @@ static inline void bond_unset_master_alb
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(char *name, struct bond_params *params);
+int bond_create(const char *name);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
@@ -350,7 +350,6 @@ extern const struct bond_parm_tbl bond_m
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
-extern struct bond_params bonding_defaults;
 extern struct bond_parm_tbl ad_select_tbl[];
 
 /* exported from bond_sysfs.c */

-- 

