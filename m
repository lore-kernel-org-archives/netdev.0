From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 13/13] ixgbe: Add support for new 82599 adapter
Date: Sat, 14 May 2011 18:23:47 -0700
Message-ID: <1305422627-9583-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20874 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759589Ab1EOBXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:55 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support for a new adapter in the 82599 family.  Included
in that support is a new media_type ixgbe_media_type_fiber_lco.

Signed-of-by: Don Skidmore <donald.c.skidmore@intel.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |    3 +++
 drivers/net/ixgbe/ixgbe_main.c  |    2 ++
 drivers/net/ixgbe/ixgbe_type.h  |    2 ++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index dba5ca6..8ee6612 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -368,6 +368,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_T3_LOM:
 		media_type = ixgbe_media_type_copper;
 		break;
+	case IXGBE_DEV_ID_82599_LS:
+		media_type = ixgbe_media_type_fiber_lco;
+		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4be2af2..2dce3d0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -126,6 +126,8 @@ static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	 board_X540 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_SFP_SF2),
 	 board_82599 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_LS),
+	 board_82599 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 70e6870..fa43f25 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -62,6 +62,7 @@
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
 #define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
+#define IXGBE_DEV_ID_82599_LS            0x154F
 #define IXGBE_DEV_ID_X540T               0x1528
 
 /* General Registers */
@@ -2395,6 +2396,7 @@ enum ixgbe_sfp_type {
 enum ixgbe_media_type {
 	ixgbe_media_type_unknown = 0,
 	ixgbe_media_type_fiber,
+	ixgbe_media_type_fiber_lco,
 	ixgbe_media_type_copper,
 	ixgbe_media_type_backplane,
 	ixgbe_media_type_cx4,
-- 
1.7.4.4

