From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Add 82598 support for BX mezzanine devices
Date: Fri, 30 Jan 2009 17:05:33 -0800
Message-ID: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:55452
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbZAaBF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 20:05:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Add the device ID for BX devices using the 82598 MAC.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c   |    4 +++-
 drivers/net/ixgbe/ixgbe_ethtool.c |    8 ++++++++
 drivers/net/ixgbe/ixgbe_main.c    |    2 ++
 drivers/net/ixgbe/ixgbe_type.h    |    1 +
 4 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 6c7ddb9..dffe7f0 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -214,7 +214,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	/* Media type for I82598 is based on device ID */
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82598:
-		/* Default device ID is mezzanine card KX/KX4 */
+	case IXGBE_DEV_ID_82598_BX:
 		media_type = ixgbe_media_type_backplane;
 		break;
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
@@ -1011,6 +1011,8 @@ static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_KX4 |
 				  IXGBE_PHYSICAL_LAYER_1000BASE_KX);
 		break;
+	case IXGBE_DEV_ID_82598_BX:
+		physical_layer = IXGBE_PHYSICAL_LAYER_1000BASE_BX;
 	case IXGBE_DEV_ID_82598EB_CX4:
 	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
 		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 444200f..69eda89 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -141,6 +141,14 @@ static int ixgbe_get_settings(struct net_device *netdev,
 				ADVERTISED_FIBRE);
 			ecmd->port = PORT_FIBRE;
 			break;
+		case IXGBE_DEV_ID_82598_BX:
+			ecmd->supported = (SUPPORTED_1000baseT_Full |
+					   SUPPORTED_FIBRE);
+			ecmd->advertising = (ADVERTISED_1000baseT_Full |
+					     ADVERTISED_FIBRE);
+			ecmd->port = PORT_FIBRE;
+			ecmd->autoneg = AUTONEG_DISABLE;
+			break;
 		}
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fe4a4d1..f348176 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -84,6 +84,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_SFP_LOM),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_BX),
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index e43f0c7..883ff82 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -35,6 +35,7 @@
 
 /* Device IDs */
 #define IXGBE_DEV_ID_82598               0x10B6
+#define IXGBE_DEV_ID_82598_BX            0x1508
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
 #define IXGBE_DEV_ID_82598EB_SFP_LOM     0x10DB

