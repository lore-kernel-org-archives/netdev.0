From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: add support for 82599 FCoE SKU
Date: Fri, 03 Dec 2010 05:32:34 -0800
Message-ID: <20101203133234.21637.21713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:41068
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751669Ab0LCNc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:32:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Add both NIC and backplane support for FCoE enabled devices IDs.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    2 ++
 drivers/net/ixgbe/ixgbe_main.c  |    4 ++++
 drivers/net/ixgbe/ixgbe_type.h  |    2 ++
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 743bdec..6827ddd 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -341,11 +341,13 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_KX4_MEZZ:
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 	case IXGBE_DEV_ID_82599_KR:
+	case IXGBE_DEV_ID_82599_BACKPLANE_FCOE:
 	case IXGBE_DEV_ID_82599_XAUI_LOM:
 		/* Default device ID is mezzanine card KX/KX4 */
 		media_type = ixgbe_media_type_backplane;
 		break;
 	case IXGBE_DEV_ID_82599_SFP:
+	case IXGBE_DEV_ID_82599_SFP_FCOE:
 	case IXGBE_DEV_ID_82599_SFP_EM:
 		media_type = ixgbe_media_type_fiber;
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c876a69..c3338b5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -109,6 +109,10 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_CX4),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_BACKPLANE_FCOE),
+	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_FCOE),
+	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_T3_LOM),
 	 board_82599 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_COMBO_BACKPLANE),
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index bbcfafc..44bcabb 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -54,6 +54,8 @@
 #define IXGBE_DEV_ID_82599_T3_LOM        0x151C
 #define IXGBE_DEV_ID_82599_CX4           0x10F9
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
+#define IXGBE_DEV_ID_82599_BACKPLANE_FCOE       0x152a
+#define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
 #define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC

