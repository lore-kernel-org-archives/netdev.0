From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] e1000: Omit private ndo_get_stats function
Date: Thu, 20 Apr 2017 16:33:29 -0700
Message-ID: <20170420233335.34900-2-jeffrey.t.kirsher@intel.com>
References: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Cc: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8369 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947266AbdDTXds (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 19:33:48 -0400
In-Reply-To: <20170420233335.34900-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

e1000_get_stats() just returns dev->stats so we can leave it
out altogether and let dev_get_stats() do the job.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 93fc6c67306b..bd8b05fe8258 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -131,7 +131,6 @@ static void e1000_watchdog(struct work_struct *work);
 static void e1000_82547_tx_fifo_stall_task(struct work_struct *work);
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev);
-static struct net_device_stats *e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
@@ -846,7 +845,6 @@ static const struct net_device_ops e1000_netdev_ops = {
 	.ndo_open		= e1000_open,
 	.ndo_stop		= e1000_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
-	.ndo_get_stats		= e1000_get_stats,
 	.ndo_set_rx_mode	= e1000_set_rx_mode,
 	.ndo_set_mac_address	= e1000_set_mac,
 	.ndo_tx_timeout		= e1000_tx_timeout,
@@ -3530,19 +3528,6 @@ static void e1000_reset_task(struct work_struct *work)
 }
 
 /**
- * e1000_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the watchdog.
- **/
-static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
-{
-	/* only return the current stats */
-	return &netdev->stats;
-}
-
-/**
  * e1000_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
-- 
2.12.2
