From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 22/24] ixgbe: make device_caps() generic
Date: Wed, 13 Apr 2011 18:02:18 -0700
Message-ID: <1302742940-22141-23-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19327 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951Ab1DNBD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:03:26 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

x540 has the same device capability word in the EEPROM as 82599.
This patch renames ixgbe_get_device_caps_82599 to
ixgbe_get_device_caps_generic, moves it to ixgbe_common.h and
sets up the function pointer for x540.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c  |   17 +----------------
 drivers/net/ixgbe/ixgbe_common.c |   15 +++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h |    1 +
 drivers/net/ixgbe/ixgbe_x540.c   |    2 +-
 4 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 63b4da6..e432305 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1973,21 +1973,6 @@ static s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
 }
 
 /**
- *  ixgbe_get_device_caps_82599 - Get additional device capabilities
- *  @hw: pointer to hardware structure
- *  @device_caps: the EEPROM word with the extra device capabilities
- *
- *  This function will read the EEPROM location for the device capabilities,
- *  and return the word through device_caps.
- **/
-static s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
-{
-	hw->eeprom.ops.read(hw, IXGBE_DEVICE_CAPS, device_caps);
-
-	return 0;
-}
-
-/**
  *  ixgbe_verify_fw_version_82599 - verify fw version for 82599
  *  @hw: pointer to hardware structure
  *
@@ -2087,7 +2072,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_82599,
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
 	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_generic,
-	.get_device_caps        = &ixgbe_get_device_caps_82599,
+	.get_device_caps        = &ixgbe_get_device_caps_generic,
 	.get_wwn_prefix         = &ixgbe_get_wwn_prefix_generic,
 	.stop_adapter           = &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index fc31e02..cb2e8e1 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2968,3 +2968,18 @@ void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf)
 		pfvfspoof &= ~(1 << vf_target_shift);
 	IXGBE_WRITE_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg), pfvfspoof);
 }
+
+/**
+ *  ixgbe_get_device_caps_generic - Get additional device capabilities
+ *  @hw: pointer to hardware structure
+ *  @device_caps: the EEPROM word with the extra device capabilities
+ *
+ *  This function will read the EEPROM location for the device capabilities,
+ *  and return the word through device_caps.
+ **/
+s32 ixgbe_get_device_caps_generic(struct ixgbe_hw *hw, u16 *device_caps)
+{
+	hw->eeprom.ops.read(hw, IXGBE_DEVICE_CAPS, device_caps);
+
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index e18dc13..e850adb 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -90,6 +90,7 @@ s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
 void ixgbe_set_mac_anti_spoofing(struct ixgbe_hw *hw, bool enable, int pf);
 void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf);
+s32 ixgbe_get_device_caps_generic(struct ixgbe_hw *hw, u16 *device_caps);
 
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 5433f15..05f8e9c 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -754,7 +754,7 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
 	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_generic,
-	.get_device_caps        = NULL,
+	.get_device_caps        = &ixgbe_get_device_caps_generic,
 	.get_wwn_prefix         = &ixgbe_get_wwn_prefix_generic,
 	.stop_adapter           = &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
-- 
1.7.4.2

