From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] ixgb: Omit private ndo_get_stats function
Date: Thu, 20 Apr 2017 16:33:30 -0700
Message-ID: <20170420233335.34900-3-jeffrey.t.kirsher@intel.com>
References: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:35690 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947775AbdDTXds (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:33:48 -0400
In-Reply-To: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

ixgb_get_stats() just returns dev->stats so we can leave it
out altogether and let dev_get_stats() do the job.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index fbd220d137b3..5a713199653c 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -86,7 +86,6 @@ static void ixgb_set_multi(struct net_device *netdev);
 static void ixgb_watchdog(unsigned long data);
 static netdev_tx_t ixgb_xmit_frame(struct sk_buff *skb,
 				   struct net_device *netdev);
-static struct net_device_stats *ixgb_get_stats(struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
 static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data);
@@ -367,7 +366,6 @@ static const struct net_device_ops ixgb_netdev_ops = {
 	.ndo_open 		= ixgb_open,
 	.ndo_stop		= ixgb_close,
 	.ndo_start_xmit		= ixgb_xmit_frame,
-	.ndo_get_stats		= ixgb_get_stats,
 	.ndo_set_rx_mode	= ixgb_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgb_set_mac,
@@ -1597,20 +1595,6 @@ ixgb_tx_timeout_task(struct work_struct *work)
 }
 
 /**
- * ixgb_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-
-static struct net_device_stats *
-ixgb_get_stats(struct net_device *netdev)
-{
-	return &netdev->stats;
-}
-
-/**
  * ixgb_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
-- 
2.12.2
