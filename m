From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 5/5] arcnet: com20020-pci: add missing pdev setup in netdev structure
Date: Wed, 28 Jun 2017 18:28:37 +0200
Message-ID: <20170628162837.21856-6-m.grzeschik@pengutronix.de>
References: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39815 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751518AbdF1Q2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:28:51 -0400
In-Reply-To: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add the pdev data to the pci devices netdev structure. This way
the interface get consistent device names in the userspace (udev).

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index fec2df2c869fe..47f80b83dcf42 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -167,6 +167,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		arcnet_outb(0x00, ioaddr, COM20020_REG_W_COMMAND);
 		arcnet_inb(ioaddr, COM20020_REG_R_DIAGSTAT);
 
+		SET_NETDEV_DEV(dev, &pdev->dev);
 		dev->base_addr = ioaddr;
 		dev->dev_addr[0] = node;
 		dev->irq = pdev->irq;
-- 
2.11.0
