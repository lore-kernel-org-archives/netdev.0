From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 4/4] arcnet: com20020-pci: add support for PCIFB2 card
Date: Wed, 28 Jun 2017 18:32:21 +0200
Message-ID: <20170628163221.32301-5-m.grzeschik@pengutronix.de>
References: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46293 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752145AbdF1Qcj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:32:39 -0400
In-Reply-To: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add support for the PCIFB2 card from EAE.

Beside other cards, this card has the backplane mode enabled by default.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index f5854ab7dc326..24deb88a37f06 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -201,6 +201,9 @@ static int com20020pci_probe(struct pci_dev *pdev,
 
 		lp->backplane = (inb(priv->misc) >> (2 + i)) & 0x1;
 
+		if (!strncmp(ci->name, "EAE PLX-PCI FB2", 15))
+			lp->backplane = 1;
+
 		/* Get the dev_id from the PLX rotary coder */
 		if (!strncmp(ci->name, "EAE PLX-PCI MA1", 15))
 			dev->dev_id = 0xc;
@@ -385,6 +388,31 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
 	.flags = ARC_CAN_10MBIT,
 };
 
+static struct com20020_pci_card_info card_info_eae_fb2 = {
+	.name = "EAE PLX-PCI FB2",
+	.devcount = 1,
+	.chan_map_tbl = {
+		{
+			.bar = 2,
+			.offset = 0x00,
+			.size = 0x08,
+		},
+	},
+	.misc_map = {
+		.bar = 2,
+		.offset = 0x10,
+		.size = 0x04,
+	},
+	.leds = {
+		{
+			.green = 0x0,
+			.red = 0x1,
+		},
+	},
+	.rotary = 0x0,
+	.flags = ARC_CAN_10MBIT,
+};
+
 static const struct pci_device_id com20020pci_id_table[] = {
 	{
 		0x1571, 0xa001,
@@ -531,6 +559,12 @@ static const struct pci_device_id com20020pci_id_table[] = {
 		(kernel_ulong_t)&card_info_eae_ma1
 	},
 	{
+		0x10B5, 0x9050,
+		0x10B5, 0x3294,
+		0, 0,
+		(kernel_ulong_t)&card_info_eae_fb2
+	},
+	{
 		0x14BA, 0x6000,
 		PCI_ANY_ID, PCI_ANY_ID,
 		0, 0,
-- 
2.11.0
