From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] ixgbe: cleanup ixgbe_setup_gpie() for X540
Date: Wed, 28 Sep 2011 23:30:15 -0700
Message-ID: <1317277816-6024-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62728 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754810Ab1I2GaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:22 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The X540 thermal sensor interrupt isn't a General Purpose Interrupt
so doesn't need to be enabled in ixgbe_setup_gpie().  Likewise X540 doesn't
use the SDP0 for thermal sensor so it doesn't need to be enabled for any
device other than 82599.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 79636ea..3f5c5a4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3680,8 +3680,18 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 	}
 
 	/* Enable Thermal over heat sensor interrupt */
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
-		gpie |= IXGBE_SDP0_GPIEN;
+	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) {
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+			gpie |= IXGBE_SDP0_GPIEN;
+			break;
+		case ixgbe_mac_X540:
+			gpie |= IXGBE_EIMS_TS;
+			break;
+		default:
+			break;
+		}
+	}
 
 	/* Enable fan failure interrupt */
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
-- 
1.7.6.2
