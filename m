From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] e1000: Omit private ndo_get_stats function
Date: Wed, 15 Feb 2017 12:08:11 +0100
Message-ID: <20170215110811.29976-1-tklauser@distanz.ch>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:49556 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751655AbdBOLIY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 06:08:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000_get_stats() just returns dev->stats so we can leave it
out altogether and let dev_get_stats() do the job.

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
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
2.11.0
