From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 4/5] arcnet: com20020-pci: fix dev_id calculation
Date: Wed, 28 Jun 2017 18:28:36 +0200
Message-ID: <20170628162837.21856-5-m.grzeschik@pengutronix.de>
References: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39371 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751528AbdF1Q2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:28:51 -0400
In-Reply-To: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev_id was miscalculated. Only the two bits 4-5 are relevant for the
MA1 card. PCIARC1 and PCIFB2 use the four bits 4-7 for id selection.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 239de38fbd6a5..fec2df2c869fe 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -135,6 +135,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 	for (i = 0; i < ci->devcount; i++) {
 		struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
 		struct com20020_dev *card;
+		int dev_id_mask = 0xf;
 
 		dev = alloc_arcdev(device);
 		if (!dev) {
@@ -179,8 +180,8 @@ static int com20020pci_probe(struct pci_dev *pdev,
 
 		/* Get the dev_id from the PLX rotary coder */
 		if (!strncmp(ci->name, "EAE PLX-PCI MA1", 15))
-			dev->dev_id = 0xc;
-		dev->dev_id ^= inb(priv->misc + ci->rotary) >> 4;
+			dev_id_mask = 0x3;
+		dev->dev_id = (inb(priv->misc + ci->rotary) >> 4) & dev_id_mask;
 
 		snprintf(dev->name, sizeof(dev->name), "arc%d-%d", dev->dev_id, i);
 
-- 
2.11.0
