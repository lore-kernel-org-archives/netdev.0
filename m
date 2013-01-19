From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbevf: Fix link up messages
Date: Sat, 19 Jan 2013 05:14:56 -0800
Message-ID: <1358601299-10404-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157Ab3ASNPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:09 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Use dev_info to log link up/down messages.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 580dfd8..3fbf0d2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2240,9 +2240,10 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			hw_dbg(&adapter->hw, "NIC Link is Up, %u Gbps\n",
-			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-			       10 : 1);
+			dev_info(&adapter->pdev->dev,
+				"NIC Link is Up, %u Gbps\n",
+				(link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+				10 : 1);
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 		}
@@ -2250,7 +2251,7 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 		adapter->link_up = false;
 		adapter->link_speed = 0;
 		if (netif_carrier_ok(netdev)) {
-			hw_dbg(&adapter->hw, "NIC Link is Down\n");
+			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 		}
-- 
1.7.11.7
