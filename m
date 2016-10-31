From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: sja1000: plx_pci: Add support for Moxa CAN devices
Date: Mon, 31 Oct 2016 21:36:19 +0100
Message-ID: <20161031203620.14384-2-mkl@pengutronix.de>
References: <20161031203620.14384-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Lukas Resch <l.resch@incubedit.com>,
        Christoph Zehentner <c.zehentner@incubedit.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20161031203620.14384-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lukas Resch <l.resch@incubedit.com>

This patch adds support for Moxa CAN devices.

Signed-off-by: Lukas Resch <l.resch@incubedit.com>
Signed-off-by: Christoph Zehentner <c.zehentner@incubedit.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/plx_pci.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 3eb7430dffbf..f8ff25c8ee2e 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -142,6 +142,9 @@ struct plx_pci_card {
 #define CTI_PCI_VENDOR_ID		0x12c4
 #define CTI_PCI_DEVICE_ID_CRG001	0x0900
 
+#define MOXA_PCI_VENDOR_ID		0x1393
+#define MOXA_PCI_DEVICE_ID		0x0100
+
 static void plx_pci_reset_common(struct pci_dev *pdev);
 static void plx9056_pci_reset_common(struct pci_dev *pdev);
 static void plx_pci_reset_marathon_pci(struct pci_dev *pdev);
@@ -258,6 +261,14 @@ static struct plx_pci_card_info plx_pci_card_info_elcus = {
 	/* based on PLX9030 */
 };
 
+static struct plx_pci_card_info plx_pci_card_info_moxa = {
+	"MOXA", 2,
+	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
+	{0, 0x00, 0x00}, { {0, 0x00, 0x80}, {1, 0x00, 0x80} },
+	&plx_pci_reset_common
+	 /* based on PLX9052 */
+};
+
 static const struct pci_device_id plx_pci_tbl[] = {
 	{
 		/* Adlink PCI-7841/cPCI-7841 */
@@ -357,6 +368,13 @@ static const struct pci_device_id plx_pci_tbl[] = {
 		0, 0,
 		(kernel_ulong_t)&plx_pci_card_info_elcus
 	},
+	{
+		/* moxa */
+		MOXA_PCI_VENDOR_ID, MOXA_PCI_DEVICE_ID,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&plx_pci_card_info_moxa
+	},
 	{ 0,}
 };
 MODULE_DEVICE_TABLE(pci, plx_pci_tbl);
-- 
2.10.1

