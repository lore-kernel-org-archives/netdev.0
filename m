From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 5/5] ARCNET: enable eae arcnet card support
Date: Wed, 24 Sep 2014 13:02:03 +0200
Message-ID: <1411556523-28100-6-git-send-email-m.grzeschik@pengutronix.de>
References: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the EAE arcnet cards
which has two Interfaces.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 7437174c..d17e1c7 100644
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
 static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
 	{
 		0x1571, 0xa001,
@@ -345,6 +355,12 @@ static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
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
