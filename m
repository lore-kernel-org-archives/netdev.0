From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (19/25) sk98: update pci id table
Date: Mon, 15 Nov 2004 15:48:25 -0800
Message-ID: <20041115154825.2d5c975d@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update pci device id table to values from newer SysKonnect version
of the driver and use PCI id define's if available. Add module pci
alias.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 14:07:37 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 14:07:37 -08:00
@@ -4974,23 +4974,45 @@
 	pci_set_drvdata(pdev, NULL);
 }
 
-static struct pci_device_id skge_pci_tbl[] = {
-	{ PCI_VENDOR_ID_3COM, 0x1700, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_3COM, 0x80eb, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SYSKONNECT, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SYSKONNECT, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_DLINK, 0x4c00, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_MARVELL, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+static struct pci_device_id skge_pci_tbl[] __devinitdata = {
+	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940, 
+	  PCI_ANY_ID, PCI_ANY_ID }, 
+	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940B, 
+	  PCI_ANY_ID, PCI_ANY_ID }, 
+	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_SYSKONNECT, 0x9E00, /* SK-9Exx 10/100/1000Base-T Adapter */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_MARVELL, 0x4320, /* Gigabit Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
 #if 0	/* don't handle Yukon2 cards at the moment -- mlindner@syskonnect.de */
-	{ PCI_VENDOR_ID_MARVELL, 0x4360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_MARVELL, 0x4361, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_MARVELL, 0x4350, /* Fast Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_MARVELL, 0x4351, /* Fast Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_MARVELL, 0x4360, /* Gigabit Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_MARVELL, 0x4361, /* Gigabit Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_MARVELL, 0x4362, /* Gigabit Ethernet Controller */
+	  PCI_ANY_ID, PCI_ANY_ID },
 #endif
-	{ PCI_VENDOR_ID_MARVELL, 0x5005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_CNET, 0x434e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1064, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0, }
+	{ PCI_VENDOR_ID_MARVELL, 0x5005, /* Marvell (11ab), Belkin */
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1032,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1064,
+	  PCI_ANY_ID, PCI_ANY_ID },
+	{ 0 }
 };
+
+MODULE_DEVICE_TABLE(pci, skge_pci_tbl);
 
 static struct pci_driver skge_driver = {
 	.name		= "skge",
