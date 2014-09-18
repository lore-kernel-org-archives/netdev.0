From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/8] can: peak_pci: add PCI ID definition pcie card variant
Date: Thu, 18 Sep 2014 12:40:56 +0200
Message-ID: <1411036862-13255-3-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

Add PCI ID definition for the single channel PCAN ExpressCard 34 adapter. Due
to the subsystem id evaluation the correct number of channels (here 1) is
created at initialization time. Tested including the LED functionality.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/peak_pci.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 7a85590..e5fac36 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -70,6 +70,8 @@ struct peak_pci_chan {
 #define PEAK_PC_104P_DEVICE_ID	0x0006	/* PCAN-PC/104+ cards */
 #define PEAK_PCI_104E_DEVICE_ID	0x0007	/* PCAN-PCI/104 Express cards */
 #define PEAK_MPCIE_DEVICE_ID	0x0008	/* The miniPCIe slot cards */
+#define PEAK_PCIE_OEM_ID	0x0009	/* PCAN-PCI Express OEM */
+#define PEAK_PCIEC34_DEVICE_ID	0x000A	/* PCAN-PCI Express 34 (one channel) */
 
 #define PEAK_PCI_CHAN_MAX	4
 
@@ -87,6 +89,7 @@ static const struct pci_device_id peak_pci_tbl[] = {
 	{PEAK_PCI_VENDOR_ID, PEAK_CPCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 #ifdef CONFIG_CAN_PEAK_PCIEC
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIEC_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_PCIEC34_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 #endif
 	{0,}
 };
@@ -653,7 +656,8 @@ static int peak_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		 * This must be done *before* register_sja1000dev() but
 		 * *after* devices linkage
 		 */
-		if (pdev->device == PEAK_PCIEC_DEVICE_ID) {
+		if (pdev->device == PEAK_PCIEC_DEVICE_ID ||
+		    pdev->device == PEAK_PCIEC34_DEVICE_ID) {
 			err = peak_pciec_probe(pdev, dev);
 			if (err) {
 				dev_err(&pdev->dev,
-- 
2.1.0

