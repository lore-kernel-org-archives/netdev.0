From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bonding: make more functions static
Date: Mon, 30 Dec 2013 10:43:41 -0800
Message-ID: <20131230104341.3e7be183@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64129 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358Ab3L3Sno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:43:44 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so11881828pab.21
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:43:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More functions in bonding that can be declared static because
they are only used in one file.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/bonding/bond_main.c	2013-12-30 10:08:06.594601098 -0800
+++ b/drivers/net/bonding/bond_main.c	2013-12-30 10:32:43.105732815 -0800
@@ -2085,7 +2085,7 @@ do_failover:
  * an acquisition of appropriate locks followed by a commit phase to
  * implement whatever link state changes are indicated.
  */
-void bond_mii_monitor(struct work_struct *work)
+static void bond_mii_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
@@ -2374,7 +2374,7 @@ static bool bond_time_in_interval(struct
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct work_struct *work)
+static void bond_loadbalance_arp_mon(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
@@ -2711,7 +2711,7 @@ static void bond_ab_arp_probe(struct bon
 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
 }
 
-void bond_activebackup_arp_mon(struct work_struct *work)
+static void bond_activebackup_arp_mon(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    arp_work.work);
@@ -3511,7 +3511,8 @@ unwind:
  * it fails, it tries to find the first available slave for transmission.
  * The skb is consumed in all cases, thus the function is void.
  */
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
+static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb,
+			       int slave_id)
 {
 	struct list_head *iter;
 	struct slave *slave;
--- a/drivers/net/bonding/bonding.h	2013-12-30 10:08:06.594601098 -0800
+++ b/drivers/net/bonding/bonding.h	2013-12-30 10:32:54.625597899 -0800
@@ -417,16 +417,12 @@ struct bond_net;
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct work_struct *);
-void bond_loadbalance_arp_mon(struct work_struct *);
-void bond_activebackup_arp_mon(struct work_struct *);
 int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
 int bond_parse_parm(const char *mode_arg, const struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
