From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 3/9] ixgb: Add support for LR device ID
Date: Thu, 6 Jan 2005 17:23:08 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061548390.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h	2005-01-05 17:13:29.000000000 -0800
@@ -43,6 +43,7 @@
 #define IXGB_DEVICE_ID_82597EX_SR	0x1A48   
 #define IXGB_SUBDEVICE_ID_A11F  	0xA11F   
 #define IXGB_SUBDEVICE_ID_A01F		0xA01F   
+#define IXGB_DEVICE_ID_82597EX_LR   0x1B48
 
 #endif /* #ifndef _IXGB_IDS_H_ */
 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -51,6 +51,8 @@ static struct pci_device_id ixgb_pci_tbl
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,  
+	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
 	{0,}
@@ -548,6 +533,7 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
 	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
+	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
 	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
 			hw->mac_type = ixgb_82597;
 	else {
