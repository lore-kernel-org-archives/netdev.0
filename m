From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v2 5/5] ARCNET: enable eae arcnet card support
Date: Mon, 29 Sep 2014 11:55:38 +0200
Message-ID: <1411984538-953-6-git-send-email-m.grzeschik@pengutronix.de>
References: <1411984538-953-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51376 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbaI2Jzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 05:55:43 -0400
In-Reply-To: <1411984538-953-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the EAE arcnet cards
which has two Interfaces.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index fe87576..6c99ff0 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -211,6 +211,16 @@ static struct com20020_pci_card_info card_info_sohard = {
 	.flags = ARC_CAN_10MBIT,
 };
 
+static struct com20020_pci_card_info card_info_eae = {
+	.name = "EAE PLX-PCI",
+	.devcount = 2,
+	.chan_map_tbl = {
+		{ 2, 0x00, 0x08 },
+		{ 2, 0x08, 0x08 }
+	},
+	.flags = ARC_CAN_10MBIT,
+};
+
 static const struct pci_device_id com20020pci_id_table[] = {
 	{
 		0x1571, 0xa001,
@@ -345,6 +355,12 @@ static const struct pci_device_id com20020pci_id_table[] = {
 		(kernel_ulong_t)&card_info_sohard
 	},
 	{
+		0x10B5, 0x9050,
+		0x10B5, 0x3292,
+		0, 0,
+		(kernel_ulong_t)&card_info_eae
+	},
+	{
 		0x14BA, 0x6000,
 		PCI_ANY_ID, PCI_ANY_ID,
 		0, 0,
-- 
2.1.0
