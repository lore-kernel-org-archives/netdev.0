From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: Add generic XAUI support to 82599
Date: Sun, 17 May 2009 23:58:04 -0700
Message-ID: <20090518065803.14864.3929.stgit@localhost.localdomain>
References: <20090518065745.14864.86660.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:39526
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755577AbZERG6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 02:58:18 -0400
In-Reply-To: <20090518065745.14864.86660.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch adds the generic XAUI device support for 82599 controllers.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    3 +++
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    2 ++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index eaecf5e..39d7b64 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -347,6 +347,7 @@ enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82599:
 	case IXGBE_DEV_ID_82599_KX4:
+	case IXGBE_DEV_ID_82599_XAUI_LOM:
 		/* Default device ID is mezzanine card KX/KX4 */
 		media_type = ixgbe_media_type_backplane;
 		break;
@@ -1199,6 +1200,8 @@ u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
 		else if (pma_pmd_10g_parallel == IXGBE_AUTOC_10G_KX4)
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_KX4;
+		else if (pma_pmd_10g_parallel == IXGBE_AUTOC_10G_XAUI)
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_XAUI;
 		goto out;
 		break;
 	case IXGBE_AUTOC_LMS_10G_SERIAL:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4ab17ab..f9f8831 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -90,6 +90,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_KX4),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_XAUI_LOM),
+	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP),
 	 board_82599 },
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index cb73b30..ba3ed0f 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -49,6 +49,7 @@
 #define IXGBE_DEV_ID_82599               0x10D8
 #define IXGBE_DEV_ID_82599_KX4           0x10F7
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
+#define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000
@@ -1954,6 +1955,7 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_1000BASE_KX  0x0200
 #define IXGBE_PHYSICAL_LAYER_1000BASE_BX  0x0400
 #define IXGBE_PHYSICAL_LAYER_10GBASE_KR   0x0800
+#define IXGBE_PHYSICAL_LAYER_10GBASE_XAUI 0x1000
 
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,

