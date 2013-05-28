From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: trivial: remove unused parameter from alb_swap_mac_addr()
Date: Tue, 28 May 2013 11:14:51 +0200
Message-ID: <1369732491-16847-1-git-send-email-vfalico@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933708Ab3E1JO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 05:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After b924551 ("bonding: fix enslaving in alb mode when link down") we
don't need the bond parameter in alb_swap_mac_addr(), so remove it.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e02cc26..a236234 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1056,7 +1056,7 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
  *
  */
 
-static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct slave *slave2)
+static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
 {
 	u8 tmp_mac_addr[ETH_ALEN];
 
@@ -1149,7 +1149,7 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 
 		if (found) {
 			/* locking: needs RTNL and nothing else */
-			alb_swap_mac_addr(bond, slave, tmp_slave);
+			alb_swap_mac_addr(slave, tmp_slave);
 			alb_fasten_mac_swap(bond, slave, tmp_slave);
 		}
 	}
@@ -1750,7 +1750,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
-		alb_swap_mac_addr(bond, swap_slave, new_slave);
+		alb_swap_mac_addr(swap_slave, new_slave);
 	} else {
 		/* set the new_slave to the bond mac address */
 		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr);
@@ -1810,7 +1810,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	}
 
 	if (swap_slave) {
-		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
+		alb_swap_mac_addr(swap_slave, bond->curr_active_slave);
 		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
 	} else {
 		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr);
-- 
1.7.1
