From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] igb: random code and comments fix
Date: Thu, 18 Apr 2013 16:30:14 -0700
Message-ID: <1366327822-10741-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936683Ab3DRXat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:49 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch fixes code and comments as identified in the driver.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c  | 6 +++---
 drivers/net/ethernet/intel/igb/igb_main.c   | 3 +--
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 6a42344..7caa62b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -326,7 +326,7 @@ s32 igb_write_nvm_srwr_i210(struct e1000_hw *hw, u16 offset, u16 words,
 /**
  *  igb_read_nvm_i211 - Read NVM wrapper function for I211
  *  @hw: pointer to the HW structure
- *  @address: the word address (aka eeprom offset) to read
+ *  @words: number of words to read
  *  @data: pointer to the data read
  *
  *  Wrapper function to return data formerly found in the NVM.
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index a5c7200..5d407f4 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1007,9 +1007,9 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 * be asked to delay transmission of packets than asking
 		 * our link partner to pause transmission of frames.
 		 */
-		else if ((hw->fc.requested_mode == e1000_fc_none ||
-			  hw->fc.requested_mode == e1000_fc_tx_pause) ||
-			 hw->fc.strict_ieee) {
+		else if ((hw->fc.requested_mode == e1000_fc_none) ||
+			 (hw->fc.requested_mode == e1000_fc_tx_pause) ||
+			 (hw->fc.strict_ieee)) {
 			hw->fc.current_mode = e1000_fc_none;
 			hw_dbg("Flow Control = NONE.\r\n");
 		} else {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0a465ae..7f83bb1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3859,9 +3859,8 @@ static bool igb_thermal_sensor_event(struct e1000_hw *hw, u32 event)
 		ctrl_ext = rd32(E1000_CTRL_EXT);
 
 		if ((hw->phy.media_type == e1000_media_type_copper) &&
-		    !(ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII)) {
+		    !(ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII))
 			ret = !!(thstat & event);
-		}
 	}
 
 	return ret;
-- 
1.7.11.7
