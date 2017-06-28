From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 3/4] arcnet: com20020-pci: handle backplane mode depending on card type
Date: Wed, 28 Jun 2017 18:32:20 +0200
Message-ID: <20170628163221.32301-4-m.grzeschik@pengutronix.de>
References: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52519 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752056AbdF1Qce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:32:34 -0400
In-Reply-To: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We read the backplane mode of each subcard from bits 2 and 3 of the misc
register.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index dec300cac55f9..f5854ab7dc326 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -199,6 +199,8 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		lp->timeout = timeout;
 		lp->hw.owner = THIS_MODULE;
 
+		lp->backplane = (inb(priv->misc) >> (2 + i)) & 0x1;
+
 		/* Get the dev_id from the PLX rotary coder */
 		if (!strncmp(ci->name, "EAE PLX-PCI MA1", 15))
 			dev->dev_id = 0xc;
-- 
2.11.0
