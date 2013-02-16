From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: display a warning message when SmartSpeed works
Date: Sat, 16 Feb 2013 00:33:23 -0800
Message-ID: <1361003616-3422-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab3BPIdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:41 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

Current e1000e driver doesn't tell nothing when Link Speed is downgraded due to
SmartSpeed.  As a result, users suspect that there is something wrong with
NIC.  If the cause of it is SmartSpeed, there is no means to replace NIC. This
patch make e1000e notify users that SmartSpeed worked.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3f7dbd1..a177b8b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4830,6 +4830,13 @@ static void e1000_watchdog_task(struct work_struct *work)
 						   &adapter->link_speed,
 						   &adapter->link_duplex);
 			e1000_print_link_info(adapter);
+
+			/* check if SmartSpeed worked */
+			e1000e_check_downshift(hw);
+			if (phy->speed_downgraded)
+				netdev_warn(netdev,
+					    "Link Speed was downgraded by SmartSpeed\n");
+
 			/* On supported PHYs, check for duplex mismatch only
 			 * if link has autonegotiated at 10/100 half
 			 */
-- 
1.7.11.7
