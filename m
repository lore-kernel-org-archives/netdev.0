From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/9] ixgb: add copper 10gig driver id
Date: Tue, 23 May 2006 11:04:13 -0700
Message-ID: <20060523180413.17428.50571.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:44037 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932128AbWEWR7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:15 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add support for Copper 10GbE device ID 109E

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
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
index 466cbe2..0de3ed0 100644
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
@@ -565,8 +567,9 @@ ixgb_sw_init(struct ixgb_adapter *adapte
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



--
Auke Kok <auke-jan.h.kok@intel.com>
