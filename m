From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bonding: fix const in options processing
Date: Thu, 6 Mar 2014 14:20:17 -0800
Message-ID: <20140306142017.2af2b894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nikolay Aleksandrov <nikolay@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:62929 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaCFWUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:20:21 -0500
Received: by mail-pb0-f42.google.com with SMTP id rr13so3245916pbb.15
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 14:20:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a fixup patch to resolve issues with const from my earlier patch.
Make all the setter functions use const on input parameter.


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 drivers/net/bonding/bond_options.c |  104 ++++++++++++++++++-------------------
 drivers/net/bonding/bond_options.h |    5 +
 drivers/net/bonding/bond_procfs.c  |    2 
 3 files changed, 56 insertions(+), 55 deletions(-)

--- a/drivers/net/bonding/bond_options.c	2014-03-06 14:07:38.514578031 -0800
+++ b/drivers/net/bonding/bond_options.c	2014-03-06 14:19:17.510174967 -0800
@@ -21,55 +21,55 @@
 #include "bonding.h"
 
 static int bond_option_active_slave_set(struct bonding *bond,
-					struct bond_opt_value *newval);
+					const struct bond_opt_value *newval);
 static int bond_option_miimon_set(struct bonding *bond,
-				  struct bond_opt_value *newval);
+				  const struct bond_opt_value *newval);
 static int bond_option_updelay_set(struct bonding *bond,
-				   struct bond_opt_value *newval);
+				   const struct bond_opt_value *newval);
 static int bond_option_downdelay_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
+				     const struct bond_opt_value *newval);
 static int bond_option_use_carrier_set(struct bonding *bond,
-				       struct bond_opt_value *newval);
+				       const struct bond_opt_value *newval);
 static int bond_option_arp_interval_set(struct bonding *bond,
-					struct bond_opt_value *newval);
+					const struct bond_opt_value *newval);
 static int bond_option_arp_ip_target_add(struct bonding *bond, __be32 target);
 static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target);
 static int bond_option_arp_ip_targets_set(struct bonding *bond,
-					  struct bond_opt_value *newval);
+					  const struct bond_opt_value *newval);
 static int bond_option_arp_validate_set(struct bonding *bond,
-					struct bond_opt_value *newval);
+					const struct bond_opt_value *newval);
 static int bond_option_arp_all_targets_set(struct bonding *bond,
-					   struct bond_opt_value *newval);
+					   const struct bond_opt_value *newval);
 static int bond_option_primary_set(struct bonding *bond,
-				   struct bond_opt_value *newval);
+				   const struct bond_opt_value *newval);
 static int bond_option_primary_reselect_set(struct bonding *bond,
-					    struct bond_opt_value *newval);
+					    const struct bond_opt_value *newval);
 static int bond_option_fail_over_mac_set(struct bonding *bond,
-					 struct bond_opt_value *newval);
+					 const struct bond_opt_value *newval);
 static int bond_option_xmit_hash_policy_set(struct bonding *bond,
-					    struct bond_opt_value *newval);
+					    const struct bond_opt_value *newval);
 static int bond_option_resend_igmp_set(struct bonding *bond,
-				       struct bond_opt_value *newval);
+				       const struct bond_opt_value *newval);
 static int bond_option_num_peer_notif_set(struct bonding *bond,
-					  struct bond_opt_value *newval);
+					  const struct bond_opt_value *newval);
 static int bond_option_all_slaves_active_set(struct bonding *bond,
-					     struct bond_opt_value *newval);
+					     const struct bond_opt_value *newval);
 static int bond_option_min_links_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
+				     const struct bond_opt_value *newval);
 static int bond_option_lp_interval_set(struct bonding *bond,
-				       struct bond_opt_value *newval);
+				       const struct bond_opt_value *newval);
 static int bond_option_pps_set(struct bonding *bond,
-			       struct bond_opt_value *newval);
+			       const struct bond_opt_value *newval);
 static int bond_option_lacp_rate_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
+				     const struct bond_opt_value *newval);
 static int bond_option_ad_select_set(struct bonding *bond,
-				     struct bond_opt_value *newval);
+				     const struct bond_opt_value *newval);
 static int bond_option_queue_id_set(struct bonding *bond,
-				    struct bond_opt_value *newval);
+				    const struct bond_opt_value *newval);
 static int bond_option_mode_set(struct bonding *bond,
-				struct bond_opt_value *newval);
+				const struct bond_opt_value *newval);
 static int bond_option_slaves_set(struct bonding *bond,
-				  struct bond_opt_value *newval);
+				  const struct bond_opt_value *newval);
 
 
 static const struct bond_opt_value bond_mode_tbl[] = {
@@ -504,7 +504,7 @@ static int bond_opt_check_deps(struct bo
 static void bond_opt_dep_print(struct bonding *bond,
 			       const struct bond_option *opt)
 {
-	struct bond_opt_value *modeval;
+	const struct bond_opt_value *modeval;
 	struct bond_params *params;
 
 	params = &bond->params;
@@ -517,9 +517,9 @@ static void bond_opt_dep_print(struct bo
 
 static void bond_opt_error_interpret(struct bonding *bond,
 				     const struct bond_option *opt,
-				     int error, struct bond_opt_value *val)
+				     int error, const struct bond_opt_value *val)
 {
-	struct bond_opt_value *minval, *maxval;
+	const struct bond_opt_value *minval, *maxval;
 	char *p;
 
 	switch (error) {
@@ -574,7 +574,7 @@ static void bond_opt_error_interpret(str
 int __bond_opt_set(struct bonding *bond,
 		   unsigned int option, struct bond_opt_value *val)
 {
-	struct bond_opt_value *retval = NULL;
+	const struct bond_opt_value *retval = NULL;
 	const struct bond_option *opt;
 	int ret = -ENOENT;
 
@@ -637,7 +637,7 @@ const struct bond_option *bond_opt_get(u
 	return &bond_opts[option];
 }
 
-int bond_option_mode_set(struct bonding *bond, struct bond_opt_value *newval)
+int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
 {
 	if (BOND_NO_USES_ARP(newval->value) && bond->params.arp_interval) {
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
@@ -676,7 +676,7 @@ struct net_device *bond_option_active_sl
 }
 
 static int bond_option_active_slave_set(struct bonding *bond,
-					struct bond_opt_value *newval)
+					const struct bond_opt_value *newval)
 {
 	char ifname[IFNAMSIZ] = { 0, };
 	struct net_device *slave_dev;
@@ -745,7 +745,7 @@ static int bond_option_active_slave_set(
 }
 
 static int bond_option_miimon_set(struct bonding *bond,
-				  struct bond_opt_value *newval)
+				  const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting MII monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
@@ -783,7 +783,7 @@ static int bond_option_miimon_set(struct
 }
 
 static int bond_option_updelay_set(struct bonding *bond,
-				   struct bond_opt_value *newval)
+				   const struct bond_opt_value *newval)
 {
 	int value = newval->value;
 
@@ -807,7 +807,7 @@ static int bond_option_updelay_set(struc
 }
 
 static int bond_option_downdelay_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+				     const struct bond_opt_value *newval)
 {
 	int value = newval->value;
 
@@ -831,7 +831,7 @@ static int bond_option_downdelay_set(str
 }
 
 static int bond_option_use_carrier_set(struct bonding *bond,
-				       struct bond_opt_value *newval)
+				       const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting use_carrier to %llu\n",
 		bond->dev->name, newval->value);
@@ -841,7 +841,7 @@ static int bond_option_use_carrier_set(s
 }
 
 static int bond_option_arp_interval_set(struct bonding *bond,
-					struct bond_opt_value *newval)
+					const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting ARP monitoring interval to %llu\n",
 		bond->dev->name, newval->value);
@@ -991,7 +991,7 @@ void bond_option_arp_ip_targets_clear(st
 }
 
 static int bond_option_arp_ip_targets_set(struct bonding *bond,
-					  struct bond_opt_value *newval)
+					  const struct bond_opt_value *newval)
 {
 	int ret = -EPERM;
 	__be32 target;
@@ -1018,7 +1018,7 @@ static int bond_option_arp_ip_targets_se
 }
 
 static int bond_option_arp_validate_set(struct bonding *bond,
-					struct bond_opt_value *newval)
+					const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting arp_validate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1035,7 +1035,7 @@ static int bond_option_arp_validate_set(
 }
 
 static int bond_option_arp_all_targets_set(struct bonding *bond,
-					   struct bond_opt_value *newval)
+					   const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting arp_all_targets to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1045,7 +1045,7 @@ static int bond_option_arp_all_targets_s
 }
 
 static int bond_option_primary_set(struct bonding *bond,
-				   struct bond_opt_value *newval)
+				   const struct bond_opt_value *newval)
 {
 	char *p, *primary = newval->string;
 	struct list_head *iter;
@@ -1098,7 +1098,7 @@ out:
 }
 
 static int bond_option_primary_reselect_set(struct bonding *bond,
-					    struct bond_opt_value *newval)
+					    const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting primary_reselect to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1114,7 +1114,7 @@ static int bond_option_primary_reselect_
 }
 
 static int bond_option_fail_over_mac_set(struct bonding *bond,
-					 struct bond_opt_value *newval)
+					 const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting fail_over_mac to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1124,7 +1124,7 @@ static int bond_option_fail_over_mac_set
 }
 
 static int bond_option_xmit_hash_policy_set(struct bonding *bond,
-					    struct bond_opt_value *newval)
+					    const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting xmit hash policy to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1134,7 +1134,7 @@ static int bond_option_xmit_hash_policy_
 }
 
 static int bond_option_resend_igmp_set(struct bonding *bond,
-				       struct bond_opt_value *newval)
+				       const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting resend_igmp to %llu\n",
 		bond->dev->name, newval->value);
@@ -1144,7 +1144,7 @@ static int bond_option_resend_igmp_set(s
 }
 
 static int bond_option_num_peer_notif_set(struct bonding *bond,
-				   struct bond_opt_value *newval)
+				   const struct bond_opt_value *newval)
 {
 	bond->params.num_peer_notif = newval->value;
 
@@ -1152,7 +1152,7 @@ static int bond_option_num_peer_notif_se
 }
 
 static int bond_option_all_slaves_active_set(struct bonding *bond,
-					     struct bond_opt_value *newval)
+					     const struct bond_opt_value *newval)
 {
 	struct list_head *iter;
 	struct slave *slave;
@@ -1173,7 +1173,7 @@ static int bond_option_all_slaves_active
 }
 
 static int bond_option_min_links_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+				     const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting min links value to %llu\n",
 		bond->dev->name, newval->value);
@@ -1183,7 +1183,7 @@ static int bond_option_min_links_set(str
 }
 
 static int bond_option_lp_interval_set(struct bonding *bond,
-				       struct bond_opt_value *newval)
+				       const struct bond_opt_value *newval)
 {
 	bond->params.lp_interval = newval->value;
 
@@ -1191,7 +1191,7 @@ static int bond_option_lp_interval_set(s
 }
 
 static int bond_option_pps_set(struct bonding *bond,
-			       struct bond_opt_value *newval)
+			       const struct bond_opt_value *newval)
 {
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
@@ -1209,7 +1209,7 @@ static int bond_option_pps_set(struct bo
 }
 
 static int bond_option_lacp_rate_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+				     const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting LACP rate to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1220,7 +1220,7 @@ static int bond_option_lacp_rate_set(str
 }
 
 static int bond_option_ad_select_set(struct bonding *bond,
-				     struct bond_opt_value *newval)
+				     const struct bond_opt_value *newval)
 {
 	pr_info("%s: Setting ad_select to %s (%llu)\n",
 		bond->dev->name, newval->string, newval->value);
@@ -1230,7 +1230,7 @@ static int bond_option_ad_select_set(str
 }
 
 static int bond_option_queue_id_set(struct bonding *bond,
-				    struct bond_opt_value *newval)
+				    const struct bond_opt_value *newval)
 {
 	struct slave *slave, *update_slave;
 	struct net_device *sdev;
@@ -1291,7 +1291,7 @@ err_no_cmd:
 }
 
 static int bond_option_slaves_set(struct bonding *bond,
-				  struct bond_opt_value *newval)
+				  const struct bond_opt_value *newval)
 {
 	char command[IFNAMSIZ + 1] = { 0, };
 	struct net_device *dev;
--- a/drivers/net/bonding/bond_procfs.c	2014-03-03 10:37:53.188148575 -0800
+++ b/drivers/net/bonding/bond_procfs.c	2014-03-06 14:10:12.366480266 -0800
@@ -65,7 +65,7 @@ static void bond_info_seq_stop(struct se
 static void bond_info_show_master(struct seq_file *seq)
 {
 	struct bonding *bond = seq->private;
-	struct bond_opt_value *optval;
+	const struct bond_opt_value *optval;
 	struct slave *curr;
 	int i;
 
--- a/drivers/net/bonding/bond_options.h	2014-03-06 14:07:38.514578031 -0800
+++ b/drivers/net/bonding/bond_options.h	2014-03-06 14:14:45.773742588 -0800
@@ -94,14 +94,15 @@ struct bond_option {
 	 */
 	const struct bond_opt_value *values;
 
-	int (*set)(struct bonding *bond, struct bond_opt_value *val);
+	int (*set)(struct bonding *bond, const struct bond_opt_value *val);
 };
 
 int __bond_opt_set(struct bonding *bond, unsigned int option,
 		   struct bond_opt_value *val);
 int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
+
 const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
-				      struct bond_opt_value *val);
+					    struct bond_opt_value *val);
 const struct bond_option *bond_opt_get(unsigned int option);
 const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
 
