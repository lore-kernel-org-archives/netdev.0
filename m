From: akpm@osdl.org
Subject: [patch 1/1] ixgb LR card support
Date: Tue, 04 Jan 2005 22:01:34 -0800
Message-ID: <200501050601.j0561h615068@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org, aafes@psu.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Phil Sorber <aafes@psu.edu>

This enables the ixgb driver to be used for LR cards as well.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/ixgb/ixgb_hw.c   |    1 +
 25-akpm/drivers/net/ixgb/ixgb_ids.h  |    1 +
 25-akpm/drivers/net/ixgb/ixgb_main.c |    5 ++++-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff -puN drivers/net/ixgb/ixgb_hw.c~ixgb-lr-card-support drivers/net/ixgb/ixgb_hw.c
--- 25/drivers/net/ixgb/ixgb_hw.c~ixgb-lr-card-support	2004-11-22 20:33:33.912389136 -0800
+++ 25-akpm/drivers/net/ixgb/ixgb_hw.c	2004-11-22 20:33:33.920387920 -0800
@@ -198,6 +198,7 @@ static ixgb_phy_type ixgb_identify_phy(s
 		break;
 
 	case IXGB_DEVICE_ID_82597EX_SR:
+	case IXGB_DEVICE_ID_82597EX_LR:
 		/* The SR adapters carry two different types of XPAK optics
 		 * modules; read the vendor identifier to determine the exact
 		 * type of optics. */
diff -puN drivers/net/ixgb/ixgb_ids.h~ixgb-lr-card-support drivers/net/ixgb/ixgb_ids.h
--- 25/drivers/net/ixgb/ixgb_ids.h~ixgb-lr-card-support	2004-11-22 20:33:33.914388832 -0800
+++ 25-akpm/drivers/net/ixgb/ixgb_ids.h	2004-11-22 20:33:33.920387920 -0800
@@ -38,6 +38,7 @@
 
 #define IXGB_DEVICE_ID_82597EX      0x1048
 #define IXGB_DEVICE_ID_82597EX_SR   0x1A48
+#define IXGB_DEVICE_ID_82597EX_LR   0x1B48
 
 #define IXGB_SUBDEVICE_ID_A11F  0xA11F
 #define IXGB_SUBDEVICE_ID_A01F  0xA01F
diff -puN drivers/net/ixgb/ixgb_main.c~ixgb-lr-card-support drivers/net/ixgb/ixgb_main.c
--- 25/drivers/net/ixgb/ixgb_main.c~ixgb-lr-card-support	2004-11-22 20:33:33.916388528 -0800
+++ 25-akpm/drivers/net/ixgb/ixgb_main.c	2004-11-22 20:33:33.922387616 -0800
@@ -46,6 +46,8 @@ static struct pci_device_id ixgb_pci_tbl
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
+	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
 	{0,}
@@ -511,7 +513,8 @@ static int __devinit ixgb_sw_init(struct
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
 	if ((hw->device_id == IXGB_DEVICE_ID_82597EX)
-	    || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
+	    || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR)
+	    || (hw->device_id == IXGB_DEVICE_ID_82597EX_LR))
 		hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
_
