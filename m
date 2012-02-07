From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] e1000e: cleanup - check return values consistently
Date: Tue,  7 Feb 2012 04:33:51 -0800
Message-ID: <1328618038-5008-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30741 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755736Ab2BGMeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:14 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The majority of the e1000e code checks most function return values using a
test like 'if (ret_val)' or 'if (!ret_val)' but there are a few instances
of 'if (ret_val == 0)'.  This patch converts the latter to the former for
consistency.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 92d5b62..f43af46 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -537,7 +537,7 @@ static int e1000_set_eeprom(struct net_device *netdev,
 		ret_val = e1000_read_nvm(hw, first_word, 1, &eeprom_buff[0]);
 		ptr++;
 	}
-	if (((eeprom->offset + eeprom->len) & 1) && (ret_val == 0))
+	if (((eeprom->offset + eeprom->len) & 1) && (!ret_val))
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
 		ret_val = e1000_read_nvm(hw, last_word, 1,
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 907b17b..0e64cc4 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2286,7 +2286,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			}
 			udelay(1);
 		}
-		if (ret_val == 0) {
+		if (!ret_val) {
 			/*
 			 * Successful in waiting for previous cycle to timeout,
 			 * now set the Flash Cycle Done.
@@ -2404,7 +2404,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		udelay(1);
 		/* Steps */
 		ret_val = e1000_flash_cycle_init_ich8lan(hw);
-		if (ret_val != 0)
+		if (ret_val)
 			break;
 
 		hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
@@ -2424,7 +2424,7 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * read in (shift in) the Flash Data0, the order is
 		 * least significant byte first msb to lsb
 		 */
-		if (ret_val == 0) {
+		if (!ret_val) {
 			flash_data = er32flash(ICH_FLASH_FDATA0);
 			if (size == 1)
 				*data = (u8)(flash_data & 0x000000FF);
@@ -2936,7 +2936,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 
 			ret_val = e1000_flash_cycle_ich8lan(hw,
 					       ICH_FLASH_ERASE_COMMAND_TIMEOUT);
-			if (ret_val == 0)
+			if (!ret_val)
 				break;
 
 			/*
-- 
1.7.7.6
