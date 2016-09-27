From: Joe Perches <joe@perches.com>
Subject: [PATCH] igb: Realign bad indentation
Date: Mon, 26 Sep 2016 20:46:25 -0700
Message-ID: <ef9cc22163546101c34fbade622455422549f43c.1474947967.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0102.hostedemail.com ([216.40.44.102]:48328 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754520AbcI0Dq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 23:46:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statements should start on tabstops.

Use a single statement and test instead of multiple tests.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 5010e2232c50..5eff82678f0b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -792,15 +792,13 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 	 * control setting, then the variable hw->fc will
 	 * be initialized based on a value in the EEPROM.
 	 */
-	if (hw->mac.type == e1000_i350) {
+	if (hw->mac.type == e1000_i350)
 		lan_offset = NVM_82580_LAN_FUNC_OFFSET(hw->bus.func);
-		ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG
-					   + lan_offset, 1, &nvm_data);
-	 } else {
-		ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG,
-					   1, &nvm_data);
-	 }
+	else
+		lan_offset = 0;
 
+	ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG + lan_offset,
+				   1, &nvm_data);
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
 		goto out;
@@ -808,8 +806,7 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 
 	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
 		hw->fc.requested_mode = e1000_fc_none;
-	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) ==
-		 NVM_WORD0F_ASM_DIR)
+	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == NVM_WORD0F_ASM_DIR)
 		hw->fc.requested_mode = e1000_fc_tx_pause;
 	else
 		hw->fc.requested_mode = e1000_fc_full;
-- 
2.10.0.rc2.1.g053435c
