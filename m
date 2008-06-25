From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 10:15:11 -0400
Message-ID: <20080625141511.GH22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758734AbYFYOh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 10:37:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Globally disable the interrupt during netpoll rather than simply
disabling it on the hardware.  This will ensure all pending operations
are complete and no more will execute.  I've seen reports of deadlocks
with the current driver and this patch resolves them.
---
 drivers/net/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae398f0..5ddd1b4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4024,7 +4024,7 @@ static void igb_netpoll(struct net_device *netdev)
 	int i;
 	int work_done = 0;
 
-	igb_irq_disable(adapter);
+	disable_irq(adapter->pdev->irq);
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		igb_clean_tx_irq(adapter, &adapter->tx_ring[i]);
 
@@ -4033,7 +4033,7 @@ static void igb_netpoll(struct net_device *netdev)
 				     &work_done,
 				     adapter->rx_ring[i].napi.weight);
 
-	igb_irq_enable(adapter);
+	enable_irq(adapter->pdev->irq);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
-- 
1.5.2.1

