From: <kime@ixxat.de>
Subject: RE: [PATCH net-next] can: plx_pci: add support for IXXAT PCI cards
Date: Mon, 12 Dec 2011 13:45:58 +0100
Message-ID: <166589D0B9DD2547A1319599B9BADA1FC62485@vsv-exchange.ixxat.intranet.priv>
References: <166589D0B9DD2547A1319599B9BADA1FC62431@vsv-exchange.ixxat.intranet.priv> <4EE5DF4A.80301@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<socketcan-core@lists.berlios.de>
To: <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4EE5DF4A.80301@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for IXXAT passive CAN controllers

Signed-off-by: James Kime <kime@ixxat.de>
---
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
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
@@ -193,6 +198,14 @@ static struct plx_pci_card_info plx_pci_card_info_esd2000 __devinitdata = {
 	/* based on PEX8311 */
 };
 
+static struct plx_pci_card_info plx_pci_card_info_ixxat __devinitdata = {
+	"IXXAT PC-I 04/PCI", 2,
+	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
+	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x200, 0x80} },
+	&plx_pci_reset_common
+	/* based on PLX9050 */
+};
+
 static struct plx_pci_card_info plx_pci_card_info_marathon __devinitdata = {
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


diff --git a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000/Kconfig
index 36e9d59..b21523d 100644
--- a/drivers/net/can/sja1000/Kconfig
+++ b/drivers/net/can/sja1000/Kconfig
@@ -71,6 +71,7 @@ config CAN_PLX_PCI
 	   - esd CAN-PCIe/2000
 	   - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
 	   - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
+	   - IXXAT Automation PC-I 04/PCI card (http://www.ixxat.com/)
 
 config CAN_TSCAN1
 	tristate "TS-CAN1 PC104 boards"


> > This patch adds support for IXXAT passive CAN controllers
> >
> > Signed-off-by: James Kime <kime@ixxat.de>
> 
> I cannot apply this patch. git am reports:
> 
>   Applying: can: plx_pci: add support for IXXAT PCI cards
>   fatal: corrupt patch at line 30
> 
I think that it should be fixed now.

> That's because lines are wrapped, I believe. And could you please update
> the Kconfig entry as well?
> 
Added above

> Thanks,
> 
> Wolfgang.
