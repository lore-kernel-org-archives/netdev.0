From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 3/6] net/macb: use dev_*() when netdev is not yet registered
Date: Fri, 24 Jul 2015 21:24:01 +0300
Message-ID: <1437762244-2678-4-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22333 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536AbbGXSYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:10 -0400
In-Reply-To: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid messages like

macb macb.0 (unnamed net_device) (uninitialized): Cadence caps 0x00000000
macb macb.0 (unnamed net_device) (uninitialized): invalid hw address, using random

let's use dev_*() macros.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7986778..367fc9d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -211,7 +211,7 @@ static void macb_get_hwaddr(struct macb *bp)
 		}
 	}
 
-	netdev_info(bp->dev, "invalid hw address, using random\n");
+	dev_info(&bp->pdev->dev, "invalid hw address, using random\n");
 	eth_hw_addr_random(bp->dev);
 }
 
@@ -2240,7 +2240,7 @@ static void macb_configure_caps(struct macb *bp, const struct macb_config *dt_co
 			bp->caps |= MACB_CAPS_FIFO_MODE;
 	}
 
-	netdev_dbg(bp->dev, "Cadence caps 0x%08x\n", bp->caps);
+	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);
 }
 
 static void macb_probe_queues(void __iomem *mem,
-- 
2.4.6
