From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: cleanup ixgbe_setup_gpie() for X540
Date: Sat, 24 Sep 2011 02:17:42 -0700
Message-ID: <1316855863-6091-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33105 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1IXJRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Sep 2011 05:17:51 -0400
In-Reply-To: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 45f5ab5..6c97aa4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3685,8 +3685,18 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
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
