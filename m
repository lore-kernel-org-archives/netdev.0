From: mjr@cs.wisc.edu
Subject: [PATCH] ks8851: Cancel any pending IRQ work
Date: Thu, 12 Apr 2012 11:44:51 -0500
Message-ID: <1334249091-7605-1-git-send-email-mjr@cs.wisc.edu>
Cc: sboyd@codeaurora.org, ben@simtec.co.uk, netdev@vger.kernel.org,
	Matt Renzelmann <mjr@cs.wisc.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:47202 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667Ab2DLQt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:49:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Renzelmann <mjr@cs.wisc.edu>

An unexpected/spurious interrupt may cause the irq_work queue to
execute during or after module unload, which can cause a crash.  It
should be canceled.

Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
---
 drivers/net/ethernet/micrel/ks8851.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..ab46953 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1540,6 +1540,7 @@ static int __devexit ks8851_remove(struct spi_device *spi)
 		dev_info(&spi->dev, "remove\n");
 
 	unregister_netdev(priv->netdev);
+	cancel_work_sync(&priv->irq_work);
 	free_irq(spi->irq, priv);
 	free_netdev(priv->netdev);
 
-- 
1.7.5.4
