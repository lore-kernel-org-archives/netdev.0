From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] cs89x0: Always report failure to request interrupt
Date: Tue,  5 Jan 2010 11:16:50 +0000
Message-ID: <1262690210-20763-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:43918 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751234Ab0AELQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 06:16:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A failure on request_irq() is always fatal but unlike other fatal
errors it's only reported to the user if net_debug is set. Make the
diagnostic unconditional and raise the priority so that errors are
more obvious to the user.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/cs89x0.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 5598677..9b5bbc6 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1325,8 +1325,7 @@ net_open(struct net_device *dev)
 		write_irq(dev, lp->chip_type, dev->irq);
 		ret = request_irq(dev->irq, net_interrupt, 0, dev->name, dev);
 		if (ret) {
-			if (net_debug)
-				printk(KERN_DEBUG "cs89x0: request_irq(%d) failed\n", dev->irq);
+			printk(KERN_ERR "cs89x0: request_irq(%d) failed\n", dev->irq);
 			goto bad_out;
 		}
 	}
-- 
1.6.5.7

