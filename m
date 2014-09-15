From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/3] bonding: consolidate ASSERT_RTNL()s and remove the unnecessary
Date: Mon, 15 Sep 2014 17:19:35 +0200
Message-ID: <1410794375-7386-4-git-send-email-nikolay@redhat.com>
References: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132AbaIOPUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 11:20:07 -0400
In-Reply-To: <1410794375-7386-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate the calls to ASSERT_RTNL() before bond_select_active_slave()
inside bond_select_active_slave() itself and remove the ASSERT_RTNL()
from bond_hw_addr_swap() as it's not exported and its only caller -
bond_change_active_slave() already has an ASSERT_RTNL().

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 943a899fbfde..5e7987bba583 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -577,8 +577,6 @@ static void bond_hw_addr_flush(struct net_device *bond_dev,
 static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
 			      struct slave *old_active)
 {
-	ASSERT_RTNL();
-
 	if (old_active) {
 		if (bond->dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(old_active->dev, -1);
@@ -876,6 +874,8 @@ void bond_select_active_slave(struct bonding *bond)
 	struct slave *best_slave;
 	int rv;
 
+	ASSERT_RTNL();
+
 	best_slave = bond_find_best_slave(bond);
 	if (best_slave != rtnl_dereference(bond->curr_active_slave)) {
 		bond_change_active_slave(bond, best_slave);
@@ -2004,7 +2004,6 @@ static void bond_miimon_commit(struct bonding *bond)
 		}
 
 do_failover:
-		ASSERT_RTNL();
 		block_netpoll_tx();
 		bond_select_active_slave(bond);
 		unblock_netpoll_tx();
@@ -2598,7 +2597,6 @@ static void bond_ab_arp_commit(struct bonding *bond)
 		}
 
 do_failover:
-		ASSERT_RTNL();
 		block_netpoll_tx();
 		bond_select_active_slave(bond);
 		unblock_netpoll_tx();
-- 
1.9.3
