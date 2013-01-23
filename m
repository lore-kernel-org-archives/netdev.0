From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] ixgbe: add warning when scheduling reset
Date: Wed, 23 Jan 2013 14:44:42 -0800
Message-ID: <1358981090-5794-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3888 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab3AWWpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:18 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds warnings when a reset of the adapter is scheduled so that the
user can see log of why the reset occurred.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4c2e9d6..7e0bb95 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -803,6 +803,7 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
 	/* Do the reset outside of interrupt context */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
 		adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+		e_warn(drv, "initiating reset due to tx timeout\n");
 		ixgbe_service_event_schedule(adapter);
 	}
 }
@@ -5613,6 +5614,7 @@ static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context).
 			 */
+			e_warn(drv, "initiating reset to clear Tx work after link loss\n");
 			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
 		}
 	}
-- 
1.7.11.7
