From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 4/8] arcnet: com20020-pci: add missing pdev setup in netdev structure
Date: Thu, 22 Jun 2017 17:31:06 +0200
Message-ID: <20170622153110.4079-5-m.grzeschik@pengutronix.de>
References: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50387 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752366AbdFVPbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:31:19 -0400
In-Reply-To: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add the pdev data to the pci devices netdev structure. This way
the interface get consistent device names in the userspace (udev).

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 239de38fbd6a5..bfbde568e7dc6 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -166,6 +166,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		arcnet_outb(0x00, ioaddr, COM20020_REG_W_COMMAND);
 		arcnet_inb(ioaddr, COM20020_REG_R_DIAGSTAT);
 
+		SET_NETDEV_DEV(dev, &pdev->dev);
 		dev->base_addr = ioaddr;
 		dev->dev_addr[0] = node;
 		dev->irq = pdev->irq;
-- 
2.11.0
