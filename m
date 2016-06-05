From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbe: replace rtnl_lock with rcu_read_lock
Date: Sun,  5 Jun 2016 17:14:51 +0800
Message-ID: <1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
References: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.70.236] ([111.193.70.236]:56867 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750911AbcFEJZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 05:25:23 -0400
In-Reply-To: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>


Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 088c47c..cb19cbc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6840,7 +6840,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	netif_tx_wake_all_queues(adapter->netdev);
 
 	/* enable any upper devices */
-	rtnl_lock();
+	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *vlan = netdev_priv(upper);
@@ -6849,7 +6849,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 				netif_tx_wake_all_queues(upper);
 		}
 	}
-	rtnl_unlock();
+	rcu_read_unlock();
 
 	/* update the default user priority for VFs */
 	ixgbe_update_default_up(adapter);
-- 
1.7.9.5
