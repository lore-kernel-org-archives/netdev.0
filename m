From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Clean up dev ids
	totally
Date: Tue, 27 Jul 2004 20:10:25 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407272010.25762.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_RqpBB9ZxgVIyDE5"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_RqpBB9ZxgVIyDE5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-27 Margit Schubert-While <margitsw@t-online.de>

* As Jeff previously stated, we do not need all this bloat.
  An updated pci.ids, both kernel and user space, gives us all
  the required info :-)
  Just leave the stuff we are interested in.
  Proposed in prism54 devel with no objections.

Margit







--Boundary-00=_RqpBB9ZxgVIyDE5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="devidtab.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="devidtab.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.8-02/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-02/drivers/net/wireless/prism54/islpci_dev.c	2004-07-27 19:46:45.000000000 +0200
@@ -39,6 +39,7 @@
 #include "oid_mgt.h"
 
 #define ISL3877_IMAGE_FILE	"isl3877"
+#define ISL3886_IMAGE_FILE	"isl3886"
 #define ISL3890_IMAGE_FILE	"isl3890"
 
 static int prism54_bring_down(islpci_private *);
@@ -856,14 +857,14 @@
 
 	/* select the firmware file depending on the device id */
 	switch (pdev->device) {
-	case PCIDEVICE_ISL3890:
-	case PCIDEVICE_3COM6001:
-		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
-		break;
-	case PCIDEVICE_ISL3877:
+	case 0x3877:
 		strcpy(priv->firmware, ISL3877_IMAGE_FILE);
 		break;
 
+	case 0x3886:
+		strcpy(priv->firmware, ISL3886_IMAGE_FILE);
+		break;
+
 	default:
 		strcpy(priv->firmware, ISL3890_IMAGE_FILE);
 		break;
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.8-02/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-02/drivers/net/wireless/prism54/islpci_hotplug.c	2004-07-27 19:46:45.000000000 +0200
@@ -44,102 +44,30 @@
  * If you have an update for this please contact prism54-devel@prism54.org 
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
-	/* 3COM 3CRWE154G72 Wireless LAN adapter */
-	{
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 0, 0, 0
-	},
-
-	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_DLINK, 0x3202UL, 
-	 0, 0, 0
-	},
-
-	/* I-O Data WN-G54/CB - WN-G54/CB */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_IODATA, 0xd019UL, 
-	 0, 0, 0
-	},
-
-	/* Netgear WG511 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_NETGEAR, 0x4800UL,
-	 0, 0, 0
-	},
-
-	/* Tekram Technology clones, Allnet, Netcomm, Zyxel */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_TTL, 0x1605UL,
-	 0, 0, 0
-	},
-
-	/* SMC2802W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2802UL,
-	 0, 0, 0
-	},
-
-	/* SMC2835W */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0x2835UL,
-	 0, 0, 0
-	},
-
-	/* Corega CG-WLCB54GT */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ATI, 0xc104UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-600 */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0014UL,
-	 0, 0, 0
-	},
-
-	/* I4 Z-Com XG-900  and clones Macer, Ovislink, Planex, Peabird, */
-	/* Sitecom, Xterasys */
-	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0020UL,
-	 0, 0, 0
-	},
-
-	/* SMC 2802W V2 */
+	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_ACCTON, 0xee03UL,
+	 0x1260, 0x3890,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* SMC 2835W V2 */
+	/* 3COM 3CRWE154G72 Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_SMC, 0xa835UL,
+	 0x10b7, 0x6001,
+	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
 	/* Intersil PRISM Indigo Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
+	 0x1260, 0x3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
 
-	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
-	/* Default */
+	/* Intersil PRISM Javelin/Xbow Wireless LAN adapter */
 	{
-	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 0x1260, 0x3886,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0, 0
 	},
@@ -166,85 +94,6 @@
 	/* .enable_wake ; we don't support this yet */
 };
 
-static void
-prism54_get_card_model(struct net_device *ndev)
-{
-	islpci_private	*priv;
-	char		*modelp;
-	int		notwork = 0;
-
-	priv = netdev_priv(ndev);
-	switch (priv->pdev->subsystem_device) {
-	case PCIDEVICE_ISL3877:
-		modelp = "PRISM Indigo";
-		break;
-	case PCIDEVICE_ISL3886:
-		modelp = "PRISM Javelin / Xbow";
-		break;
-	case PCIDEVICE_3COM6001:
-		modelp = "3COM 3CRWE154G72";
-		break;
-	case 0x3202UL:
-		modelp = "D-Link DWL-g650 A1";
-		break;
-	case 0xd019UL:
-		modelp = "WN-G54/CB";
-		break;
-	case 0x4800UL:
-		modelp = "Netgear WG511";
-		break;
-	case 0x2802UL:
-		modelp = "SMC2802W";
-		break;
-	case 0xee03UL:
-		modelp = "SMC2802W V2";
-		notwork = 1;
-		break;
-	case 0x2835UL:
-		modelp = "SMC2835W";
-		break;
-	case 0xa835UL:
-		modelp = "SMC2835W V2";
-		notwork = 1;
-		break;
-	case 0xc104UL:
-		modelp = "CG-WLCB54GT";
-		break;
-	case 0x1605UL:
-		modelp = "Tekram Technology clone";
-		break;
-	/* Let's leave this one out for now since it seems bogus/wrong 
-	 * Even if the manufacturer did use 0x0000UL it may not be correct
-	 * by their part, therefore deserving no name ;) */
-	/*      case 0x0000UL: 
-	 *              modelp = "SparkLAN WL-850F";
-	 *              break;*/
-
-	/* We have two reported for the one below :( */
-	case 0x0014UL:
-		modelp = "I4 Z-Com XG-600 and clones";
-		break;
-	case 0x0020UL:
-		modelp = "I4 Z-Com XG-900 and clones";
-		break;
-/* Default it */
-/*
-	case PCIDEVICE_ISL3890:
-		modelp = "PRISM Duette/GT";
-		break;
-*/
-	default:
-		modelp = "PRISM Duette/GT";
-	}
-	printk(KERN_DEBUG "%s: %s driver detected card model: %s\n",
-			ndev->name, DRV_NAME, modelp);
-	if ( notwork ) {
-		printk(KERN_DEBUG "%s: %s Warning - This may not work\n",
-			ndev->name, DRV_NAME);
-	}
-	return;
-}
-
 /******************************************************************************
     Module initialization functions
 ******************************************************************************/
@@ -354,9 +203,6 @@
 
 	/* firmware upload is triggered in islpci_open */
 
-	/* Pretty card model discovery output */
-	prism54_get_card_model(ndev);
-
 	return 0;
 
       do_unregister_netdev:
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_mgt.h linux-2.6.8-02/drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_mgt.h	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-02/drivers/net/wireless/prism54/islpci_mgt.h	2004-07-15 08:52:10.000000000 +0200
@@ -38,21 +38,6 @@
 
 
 /* General driver definitions */
-#define PCIVENDOR_INTERSIL                      0x1260UL
-#define PCIVENDOR_3COM				0x10b7UL
-#define PCIVENDOR_DLINK				0x1186UL
-#define PCIVENDOR_I4				0x17cfUL
-#define PCIVENDOR_IODATA			0x10fcUL
-#define PCIVENDOR_NETGEAR			0x1385UL
-#define PCIVENDOR_SMC				0x10b8UL
-#define PCIVENDOR_ACCTON			0x1113UL
-#define PCIVENDOR_ATI				0x1259UL
-#define PCIVENDOR_TTL				0x16a5UL
-
-#define PCIDEVICE_ISL3877                       0x3877UL
-#define PCIDEVICE_ISL3886                       0x3886UL
-#define PCIDEVICE_ISL3890                       0x3890UL
-#define	PCIDEVICE_3COM6001			0x6001UL
 #define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
 #define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
 

--Boundary-00=_RqpBB9ZxgVIyDE5
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_RqpBB9ZxgVIyDE5--
