From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] igb: Realign bad indentation
Date: Fri,  6 Jan 2017 02:48:43 -0800
Message-ID: <20170106104852.10363-2-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:57006 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939870AbdAFKtS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:18 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Statements should start on tabstops.

Use a single statement and test instead of multiple tests.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 5010e22..5eff826 100644
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
2.9.3
