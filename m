From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] ixgbevf: Fix link speed message to support 100Mbps
Date: Wed, 23 Jan 2013 14:44:50 -0800
Message-ID: <1358981090-5794-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62169 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593Ab3AWWpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:23 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The X540 can link at 100Mbps - fix the link speed indicator message to
show that value.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 551e31d..c3db6cd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2245,10 +2245,23 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
+			char *link_speed_string;
+			switch (link_speed) {
+			case IXGBE_LINK_SPEED_10GB_FULL:
+				link_speed_string = "10 Gbps";
+				break;
+			case IXGBE_LINK_SPEED_1GB_FULL:
+				link_speed_string = "1 Gbps";
+				break;
+			case IXGBE_LINK_SPEED_100_FULL:
+				link_speed_string = "100 Mbps";
+				break;
+			default:
+				link_speed_string = "unknown speed";
+				break;
+			}
 			dev_info(&adapter->pdev->dev,
-				"NIC Link is Up, %u Gbps\n",
-				(link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-				10 : 1);
+				"NIC Link is Up, %s\n", link_speed_string);
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 		}
-- 
1.7.11.7
