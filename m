From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: sja1000: fix/add miniPCIe/cPCI PC/104Plus PCI/104e PEAK-System boards
Date: Wed, 24 Oct 2012 11:06:16 +0200
Message-ID: <1351069576-20790-3-git-send-email-mkl@pengutronix.de>
References: <1351069576-20790-1-git-send-email-mkl@pengutronix.de>
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1351069576-20790-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Grosjean <s.grosjean@peak-system.com>

This patch adds the support for 4 new PCI boards based on the SJA1000 CAN
controller, from PEAK-System Technik:

. PCAN-miniPCIe (PCI-Express Mini slots, available as single or dual-channel)
. PCAN-cPCI (CompactPCI format, available as single or dual-channel)
. PCAN-PC/104-Plus (PC/104-Plus system, av. as 1, 2 or 4 channels)
. PCAN-PCI/104-Express (PCI/104-Express system, av. as 1 or 2 channels)

This patch also fixes a typo in existing "PEAK_MPCI_DEVICE_ID" identifier
(missing "e" for Express). Finally, it also changes the author as well as it
updates the module supported devices list.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/peak_pci.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index f5b82ae..6525dbc 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -30,9 +30,10 @@
 
 #include "sja1000.h"
 
-MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
+MODULE_AUTHOR("Stephane Grosjean <s.grosjean@peak-system.com>");
 MODULE_DESCRIPTION("Socket-CAN driver for PEAK PCAN PCI family cards");
 MODULE_SUPPORTED_DEVICE("PEAK PCAN PCI/PCIe/PCIeC miniPCI CAN cards");
+MODULE_SUPPORTED_DEVICE("PEAK PCAN miniPCIe/cPCI PC/104+ PCI/104e CAN Cards");
 MODULE_LICENSE("GPL v2");
 
 #define DRV_NAME  "peak_pci"
@@ -64,7 +65,11 @@ struct peak_pci_chan {
 #define PEAK_PCI_DEVICE_ID	0x0001	/* for PCI/PCIe slot cards */
 #define PEAK_PCIEC_DEVICE_ID	0x0002	/* for ExpressCard slot cards */
 #define PEAK_PCIE_DEVICE_ID	0x0003	/* for nextgen PCIe slot cards */
-#define PEAK_MPCI_DEVICE_ID	0x0008	/* The miniPCI slot cards */
+#define PEAK_CPCI_DEVICE_ID	0x0004	/* for nextgen cPCI slot cards */
+#define PEAK_MPCI_DEVICE_ID	0x0005	/* for nextgen miniPCI slot cards */
+#define PEAK_PC_104P_DEVICE_ID	0x0006	/* PCAN-PC/104+ cards */
+#define PEAK_PCI_104E_DEVICE_ID	0x0007	/* PCAN-PCI/104 Express cards */
+#define PEAK_MPCIE_DEVICE_ID	0x0008	/* The miniPCIe slot cards */
 
 #define PEAK_PCI_CHAN_MAX	4
 
@@ -76,6 +81,10 @@ static DEFINE_PCI_DEVICE_TABLE(peak_pci_tbl) = {
 	{PEAK_PCI_VENDOR_ID, PEAK_PCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIE_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_MPCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_MPCIE_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_PC_104P_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_PCI_104E_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
+	{PEAK_PCI_VENDOR_ID, PEAK_CPCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 #ifdef CONFIG_CAN_PEAK_PCIEC
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIEC_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 #endif
-- 
1.7.10

