From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH] com20020-pci: add support for eae single card
Date: Fri, 13 Feb 2015 13:03:50 +0100
Message-ID: <1423829030-20682-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45426 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbbBMMD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 07:03:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 945f532..96edc13 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -214,8 +214,17 @@ static struct com20020_pci_card_info card_info_sohard = {
 	.flags = ARC_CAN_10MBIT,
 };
 
-static struct com20020_pci_card_info card_info_eae = {
-	.name = "EAE PLX-PCI",
+static struct com20020_pci_card_info card_info_eae_arc1 = {
+	.name = "EAE PLX-PCI ARC1",
+	.devcount = 1,
+	.chan_map_tbl = {
+		{ 2, 0x00, 0x08 },
+	},
+	.flags = ARC_CAN_10MBIT,
+};
+
+static struct com20020_pci_card_info card_info_eae_ma1 = {
+	.name = "EAE PLX-PCI MA1",
 	.devcount = 2,
 	.chan_map_tbl = {
 		{ 2, 0x00, 0x08 },
@@ -359,9 +368,15 @@ static const struct pci_device_id com20020pci_id_table[] = {
 	},
 	{
 		0x10B5, 0x9050,
+		0x10B5, 0x3263,
+		0, 0,
+		(kernel_ulong_t)&card_info_eae_arc1
+	},
+	{
+		0x10B5, 0x9050,
 		0x10B5, 0x3292,
 		0, 0,
-		(kernel_ulong_t)&card_info_eae
+		(kernel_ulong_t)&card_info_eae_ma1
 	},
 	{
 		0x14BA, 0x6000,
-- 
2.1.4
