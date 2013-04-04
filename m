From: Sascha Herrmann <sascha@ps.nvbi.de>
Subject: [PATCH 1/2] at86rf230: remove unnecessary / dead code
Date: Thu,  4 Apr 2013 23:02:00 +0200
Message-ID: <c9c5bee7116dd5847ed9e2ebb8be49fcde0cc052.1365107512.git.sascha@ps.nvbi.de>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Sascha Herrmann <sascha@ps.nvbi.de>
To: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:62495 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762612Ab3DDVCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:02:52 -0400
In-Reply-To: <cover.1365107512.git.sascha@ps.nvbi.de>
In-Reply-To: <cover.1365107512.git.sascha@ps.nvbi.de>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In at86rf230_probe() lp was first set to dev->priv and a few lines later
dev->priv was set to lp again, without changing lp in between. The call
to ieee802154_unregister_device() before err_irq: was unreachable.

Signed-off-by: Sascha Herrmann <sascha@ps.nvbi.de>
---
 drivers/net/ieee802154/at86rf230.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 6e88eab..fc315dd 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -838,7 +838,6 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	lp->spi = spi;
 
-	dev->priv = lp;
 	dev->parent = &spi->dev;
 	dev->extra_tx_headroom = 0;
 	/* We do support only 2.4 Ghz */
@@ -940,7 +939,6 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	return rc;
 
-	ieee802154_unregister_device(lp->dev);
 err_irq:
 	free_irq(spi->irq, lp);
 	flush_work(&lp->irqwork);
-- 
1.7.10.4
