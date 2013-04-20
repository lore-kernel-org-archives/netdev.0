From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] igb: display a warning message when SmartSpeed works
Date: Sat, 20 Apr 2013 02:49:09 -0700
Message-ID: <1366451353-24714-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49450 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754770Ab3DTJtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:22 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

Current igb driver doesn't tell nothing when Link Speed is downgraded due to
SmartSpeed.  As a result, users suspect that there is something wrong with
NIC.  If the cause of it is SmartSpeed, there is no means to replace NIC. This
patch make igb notify users that SmartSpeed worked.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 388d36f..b90a062 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3918,6 +3918,7 @@ static void igb_watchdog_task(struct work_struct *work)
 						   struct igb_adapter,
 						   watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_phy_info *phy = &hw->phy;
 	struct net_device *netdev = adapter->netdev;
 	u32 link;
 	int i;
@@ -3946,6 +3947,11 @@ static void igb_watchdog_task(struct work_struct *work)
 			       (ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       (ctrl & E1000_CTRL_TFCE) ?  "TX" : "None");
 
+			/* check if SmartSpeed worked */
+			igb_check_downshift(hw);
+			if (phy->speed_downgraded)
+				netdev_warn(netdev, "Link Speed was downgraded by SmartSpeed\n");
+
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
 			    E1000_THSTAT_LINK_THROTTLE)) {
-- 
1.7.11.7
