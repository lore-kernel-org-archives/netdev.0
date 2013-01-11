From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] e1000e: resolve checkpatch PREFER_PR_LEVEL warning
Date: Fri, 11 Jan 2013 02:23:45 -0800
Message-ID: <1357899831-4168-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479Ab3AKKYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:24:05 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING: Prefer netdev_info(netdev, ... then dev_info(dev, ...
then pr_info(...  to printk(KERN_INFO ...

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7ad8ef6..e922bba 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4300,9 +4300,8 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
 	u32 ctrl = er32(CTRL);
 
 	/* Link status message must follow this format for user tools */
-	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
-		adapter->netdev->name,
-		adapter->link_speed,
+	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
+		adapter->netdev->name, adapter->link_speed,
 		adapter->link_duplex == FULL_DUPLEX ? "Full" : "Half",
 		(ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE) ? "Rx/Tx" :
 		(ctrl & E1000_CTRL_RFCE) ? "Rx" :
@@ -4521,8 +4520,8 @@ static void e1000_watchdog_task(struct work_struct *work)
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
 			/* Link status message must follow this format */
-			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
-			       adapter->netdev->name);
+			pr_info("e1000e: %s NIC Link is Down\n",
+				adapter->netdev->name);
 			netif_carrier_off(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
-- 
1.7.11.7
