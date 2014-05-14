From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 1/5] bonding: use macro instead of bond_is_lb()
Date: Wed, 14 May 2014 14:54:20 +0200
Message-ID: <1400072064-26095-2-git-send-email-vfalico@gmail.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbaENM7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 08:59:00 -0400
In-Reply-To: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 18 +++++++++---------
 drivers/net/bonding/bonding.h   | 13 ++++---------
 2 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a1741cb..e6f1d02 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -320,7 +320,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 	bond_for_each_slave(bond, slave, iter)
 		vlan_vid_del(slave->dev, proto, vid);
 
-	if (bond_is_lb(bond))
+	if (BOND_IS_LB(bond))
 		bond_alb_clear_vlan(bond, vid);
 
 	return 0;
@@ -813,7 +813,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			if (bond->params.mode == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
 
-			if (bond_is_lb(bond))
+			if (BOND_IS_LB(bond))
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
 			if (USES_PRIMARY(bond->params.mode)) {
@@ -826,7 +826,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	if (USES_PRIMARY(bond->params.mode))
 		bond_hw_addr_swap(bond, new_active, old_active);
 
-	if (bond_is_lb(bond)) {
+	if (BOND_IS_LB(bond)) {
 		bond_alb_handle_active_change(bond, new_active);
 		if (old_active)
 			bond_set_slave_inactive_flags(old_active,
@@ -1342,7 +1342,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	new_slave->dev = slave_dev;
 	slave_dev->priv_flags |= IFF_BONDING;
 
-	if (bond_is_lb(bond)) {
+	if (BOND_IS_LB(bond)) {
 		/* bond_alb_init_slave() must be called before all other stages since
 		 * it might fail and we do not want to have to undo everything
 		 */
@@ -1694,7 +1694,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
-	if (bond_is_lb(bond)) {
+	if (BOND_IS_LB(bond)) {
 		/* Must be called only after the slave has been
 		 * detached from the list and the curr_active_slave
 		 * has been cleared (if our_slave == old_current),
@@ -1988,7 +1988,7 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (bond->params.mode == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 
-			if (bond_is_lb(bond))
+			if (BOND_IS_LB(bond))
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_UP);
 
@@ -2016,7 +2016,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_3ad_handle_link_change(slave,
 							    BOND_LINK_DOWN);
 
-			if (bond_is_lb(bond))
+			if (BOND_IS_LB(bond))
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
@@ -3090,7 +3090,7 @@ static int bond_open(struct net_device *bond_dev)
 
 	bond_work_init_all(bond);
 
-	if (bond_is_lb(bond)) {
+	if (BOND_IS_LB(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
@@ -3124,7 +3124,7 @@ static int bond_close(struct net_device *bond_dev)
 
 	bond_work_cancel_all(bond);
 	bond->send_peer_notif = 0;
-	if (bond_is_lb(bond))
+	if (BOND_IS_LB(bond))
 		bond_alb_deinitialize(bond);
 	bond->recv_probe = NULL;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1621226..29ddce5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -69,9 +69,9 @@
 			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
 			 ((mode) == BOND_MODE_ROUNDROBIN))
 
-#define BOND_MODE_IS_LB(mode)			\
-		(((mode) == BOND_MODE_TLB) ||	\
-		 ((mode) == BOND_MODE_ALB))
+#define BOND_IS_LB(bond)			\
+		(((bond->params.mode) == BOND_MODE_TLB) ||	\
+		 ((bond->params.mode) == BOND_MODE_ALB))
 
 #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
 	((htonl(INADDR_BROADCAST) == a) ||	\
@@ -288,11 +288,6 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 	return slave->bond;
 }
 
-static inline bool bond_is_lb(const struct bonding *bond)
-{
-	return BOND_MODE_IS_LB(bond->params.mode);
-}
-
 static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
@@ -443,7 +438,7 @@ static inline void bond_netpoll_send_skb(const struct slave *slave,
 static inline void bond_set_slave_inactive_flags(struct slave *slave,
 						 bool notify)
 {
-	if (!bond_is_lb(slave->bond))
+	if (!BOND_IS_LB(slave->bond))
 		bond_set_slave_state(slave, BOND_STATE_BACKUP, notify);
 	if (!slave->bond->params.all_slaves_active)
 		slave->inactive = 1;
-- 
1.8.4
