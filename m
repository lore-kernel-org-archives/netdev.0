From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] ixgbe: add WoL support for some 82599 subdevice IDs
Date: Wed,  4 May 2016 09:26:40 -0700
Message-ID: <1462379208-3997-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64255 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbcEDQ0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:26:53 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

We had some 82599 subdevice IDs missing from the list of parts that
support WoL.

Reported-by: Neil Horman <nhorman@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 6 +++++-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3d895b6..77c798f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9204,8 +9204,10 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 	case IXGBE_DEV_ID_82599_SFP:
 		/* Only these subdevices could supports WOL */
 		switch (subdevice_id) {
-		case IXGBE_SUBDEV_ID_82599_SFP_WOL0:
 		case IXGBE_SUBDEV_ID_82599_560FLR:
+		case IXGBE_SUBDEV_ID_82599_LOM_SNAP6:
+		case IXGBE_SUBDEV_ID_82599_SFP_WOL0:
+		case IXGBE_SUBDEV_ID_82599_SFP_2OCP:
 			/* only support first port */
 			if (hw->bus.func != 0)
 				break;
@@ -9213,7 +9215,9 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 		case IXGBE_SUBDEV_ID_82599_SFP:
 		case IXGBE_SUBDEV_ID_82599_RNDC:
 		case IXGBE_SUBDEV_ID_82599_ECNA_DP:
-		case IXGBE_SUBDEV_ID_82599_LOM_SFP:
+		case IXGBE_SUBDEV_ID_82599_SFP_1OCP:
+		case IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM1:
+		case IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM2:
 			is_wol_supported = 1;
 			break;
 		}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7af4514..71082be 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -59,8 +59,12 @@
 #define IXGBE_SUBDEV_ID_82599_RNDC       0x1F72
 #define IXGBE_SUBDEV_ID_82599_560FLR     0x17D0
 #define IXGBE_SUBDEV_ID_82599_SP_560FLR  0x211B
+#define IXGBE_SUBDEV_ID_82599_LOM_SNAP6		0x2159
+#define IXGBE_SUBDEV_ID_82599_SFP_1OCP		0x000D
+#define IXGBE_SUBDEV_ID_82599_SFP_2OCP		0x0008
+#define IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM1	0x8976
+#define IXGBE_SUBDEV_ID_82599_SFP_LOM_OEM2	0x06EE
 #define IXGBE_SUBDEV_ID_82599_ECNA_DP    0x0470
-#define IXGBE_SUBDEV_ID_82599_LOM_SFP    0x8976
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
 #define IXGBE_DEV_ID_82599EN_SFP         0x1557
-- 
2.5.5
