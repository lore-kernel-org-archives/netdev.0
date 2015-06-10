From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] ixgbe: add support for WoL and autoneg FC for some X550 devices
Date: Tue,  9 Jun 2015 18:10:13 -0700
Message-ID: <1433898629-76729-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914AbbFJBKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:32 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

These Device ID could support both WoL and autoneg flow control. In
the case of WoL this is indicated by the eeprom.  This patch enables
these devices this support.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 13a6fe05..21e5ae3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -96,6 +96,8 @@ bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 		case IXGBE_DEV_ID_82599_T3_LOM:
 		case IXGBE_DEV_ID_X540T:
 		case IXGBE_DEV_ID_X540T1:
+		case IXGBE_DEV_ID_X550T:
+		case IXGBE_DEV_ID_X550EM_X_10G_T:
 			supported = true;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fb2ccc3..58998d5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8295,6 +8295,10 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 		break;
 	case IXGBE_DEV_ID_X540T:
 	case IXGBE_DEV_ID_X540T1:
+	case IXGBE_DEV_ID_X550T:
+	case IXGBE_DEV_ID_X550EM_X_KX4:
+	case IXGBE_DEV_ID_X550EM_X_KR:
+	case IXGBE_DEV_ID_X550EM_X_10G_T:
 		/* check eeprom to see if enabled wol */
 		if ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0_1) ||
 		    ((wol_cap == IXGBE_DEVICE_CAPS_WOL_PORT0) &&
-- 
2.4.2
