From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 08/11] ixgb: Add support for copper 10GbE
Date: Fri, 21 Apr 2006 18:00:48 -0700
Message-ID: <20060422010048.24255.65982.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:50305 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750819AbWDVA5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:42 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- Add support for Copper 10GbE device ID 109E

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_hw.h   |    1 +
 drivers/net/ixgb/ixgb_ids.h  |    4 +++-
 drivers/net/ixgb/ixgb_main.c |    7 +++++--
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index 382c630..19513c6 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -57,6 +57,7 @@ typedef enum {
 typedef enum {
 	ixgb_media_type_unknown = 0,
 	ixgb_media_type_fiber = 1,
+	ixgb_media_type_copper = 2,
 	ixgb_num_media_types
 } ixgb_media_type;
 
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index aee207e..e119c05 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -43,6 +43,8 @@
 #define IXGB_SUBDEVICE_ID_A11F      0xA11F   
 #define IXGB_SUBDEVICE_ID_A01F      0xA01F   
 
-#endif /* #ifndef _IXGB_IDS_H_ */
+#define IXGB_DEVICE_ID_82597EX_CX4   0x109E
+#define IXGB_SUBDEVICE_ID_A00C  0xA00C
 
+#endif /* #ifndef _IXGB_IDS_H_ */
 /* End of File */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 9d262c8..be7b43b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -67,6 +67,8 @@ static char ixgb_copyright[] = "Copyrigh
 static struct pci_device_id ixgb_pci_tbl[] = {
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_CX4,
+	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,  
@@ -570,8 +572,9 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
 	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
-	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
-	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
+	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
+	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
+	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
 			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */

