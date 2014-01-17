From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 12/12] bonding: rename last_arp_rx to last_rx
Date: Fri, 17 Jan 2014 17:59:00 +0100
Message-ID: <1389977940-17084-13-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965AbaAQREi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:38 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To reflect the new meaning.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 12 ++++++------
 drivers/net/bonding/bonding.h   |  4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 13a3ff8..41f3109 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1444,10 +1444,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	bond_update_speed_duplex(new_slave);
 
-	new_slave->last_arp_rx = jiffies -
+	new_slave->last_rx = jiffies -
 		(msecs_to_jiffies(bond->params.arp_interval) + 1);
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
-		new_slave->target_last_arp_rx[i] = new_slave->last_arp_rx;
+		new_slave->target_last_arp_rx[i] = new_slave->last_rx;
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
 		link_reporting = bond_check_dev_link(bond, slave_dev, 1);
@@ -2277,7 +2277,7 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 		pr_debug("bva: sip %pI4 not found in targets\n", &sip);
 		return;
 	}
-	slave->last_arp_rx = jiffies;
+	slave->last_rx = jiffies;
 	slave->target_last_arp_rx[i] = jiffies;
 }
 
@@ -2292,7 +2292,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	if (!slave_do_arp_validate(bond, slave)) {
 		if ((slave_do_arp_validate_only(bond, slave) && is_arp) ||
 		    !slave_do_arp_validate_only(bond, slave))
-			slave->last_arp_rx = jiffies;
+			slave->last_rx = jiffies;
 		return RX_HANDLER_ANOTHER;
 	} else if (!is_arp) {
 		return RX_HANDLER_ANOTHER;
@@ -2404,7 +2404,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 		if (slave->link != BOND_LINK_UP) {
 			if (bond_time_in_interval(bond, trans_start, 1) &&
-			    bond_time_in_interval(bond, slave->last_arp_rx, 1)) {
+			    bond_time_in_interval(bond, slave->last_rx, 1)) {
 
 				slave->link  = BOND_LINK_UP;
 				bond_set_active_slave(slave);
@@ -2433,7 +2433,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * if we don't know our ip yet
 			 */
 			if (!bond_time_in_interval(bond, trans_start, 2) ||
-			    !bond_time_in_interval(bond, slave->last_arp_rx, 2)) {
+			    !bond_time_in_interval(bond, slave->last_rx, 2)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				bond_set_backup_slave(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 15cf6b7..3087f78 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -186,7 +186,7 @@ struct slave {
 	int    delay;
 	/* all three in jiffies */
 	unsigned long last_link_up;
-	unsigned long last_arp_rx;
+	unsigned long last_rx;
 	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     new_link;
@@ -359,7 +359,7 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
 		return slave_oldest_target_arp_rx(bond, slave);
 
-	return slave->last_arp_rx;
+	return slave->last_rx;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.8.4
