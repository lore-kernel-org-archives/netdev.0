From: <kime-Z4QKGCRq86k@public.gmane.org>
Subject: [PATCH net-next] can: plx_pci: add support for IXXAT PCI cards
Date: Mon, 12 Dec 2011 11:44:49 +0100
Message-ID: <166589D0B9DD2547A1319599B9BADA1FC62431@vsv-exchange.ixxat.intranet.priv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for IXXAT passive CAN controllers

Signed-off-by: James Kime <kime-Z4QKGCRq86k@public.gmane.org>
---
diff --git a/drivers/net/can/sja1000/plx_pci.c
b/drivers/net/can/sja1000/plx_pci.c
index 231385b..a0c693a 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -43,7 +43,8 @@ MODULE_SUPPORTED_DEVICE("Adlink PCI-7841/cPCI-7841, "
 			"TEWS TECHNOLOGIES TPMC810, "
 			"esd CAN-PCI/CPCI/PCI104/200, "
 			"esd CAN-PCI/PMC/266, "
-			"esd CAN-PCIe/2000")
+			"esd CAN-PCIe/2000, "
+			"IXXAT PC-I 04/PCI")
 MODULE_LICENSE("GPL v2");
 
 #define PLX_PCI_MAX_CHAN 2
@@ -121,6 +122,10 @@ struct plx_pci_card {
 #define ESD_PCI_SUB_SYS_ID_PCIE2000	0x0200
 #define ESD_PCI_SUB_SYS_ID_PCI104200	0x0501
 
+#define IXXAT_PCI_VENDOR_ID		0x10b5
+#define IXXAT_PCI_DEVICE_ID		0x9050
+#define IXXAT_PCI_SUB_SYS_ID		0x2540
+
 #define MARATHON_PCI_DEVICE_ID		0x2715
 
 #define TEWS_PCI_VENDOR_ID		0x1498
@@ -193,6 +198,14 @@ static struct plx_pci_card_info
plx_pci_card_info_esd2000 __devinitdata = {
 	/* based on PEX8311 */
 };
 
+static struct plx_pci_card_info plx_pci_card_info_ixxat __devinitdata =
{
+	"IXXAT PC-I 04/PCI", 2,
+	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
+	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x200, 0x80} },
+	&plx_pci_reset_common
+	/* based on PLX9050 */
+};
+
 static struct plx_pci_card_info plx_pci_card_info_marathon
__devinitdata = {
 	"Marathon CAN-bus-PCI", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
@@ -267,6 +280,13 @@ static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl) = {
 		(kernel_ulong_t)&plx_pci_card_info_esd2000
 	},
 	{
+		/* IXXAT PC-I 04/PCI card */
+		IXXAT_PCI_VENDOR_ID, IXXAT_PCI_DEVICE_ID,
+		PCI_ANY_ID, IXXAT_PCI_SUB_SYS_ID,
+		0, 0,
+		(kernel_ulong_t)&plx_pci_card_info_ixxat
+	},
+	{
 		/* Marathon CAN-bus-PCI card */
 		PCI_VENDOR_ID_PLX, MARATHON_PCI_DEVICE_ID,
 		PCI_ANY_ID, PCI_ANY_ID,
