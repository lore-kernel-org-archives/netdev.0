From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] igb: fix static function warnings reported by sparse
Date: Tue, 11 Oct 2011 20:38:25 -0700
Message-ID: <1318390708-12232-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34679 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503Ab1JLDiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:46 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

igb_update/validate_nvm_checksum_with_offset() should be static.
Also removes unneeded protypes for the above functions.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index c0857bd..3771bd2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -66,10 +66,6 @@ static s32  igb_set_pcie_completion_timeout(struct e1000_hw *hw);
 static s32  igb_reset_mdicnfg_82580(struct e1000_hw *hw);
 static s32  igb_validate_nvm_checksum_82580(struct e1000_hw *hw);
 static s32  igb_update_nvm_checksum_82580(struct e1000_hw *hw);
-static s32  igb_update_nvm_checksum_with_offset(struct e1000_hw *hw,
-						u16 offset);
-static s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw,
-						u16 offset);
 static s32 igb_validate_nvm_checksum_i350(struct e1000_hw *hw);
 static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw);
 static const u16 e1000_82580_rxpbs_table[] =
@@ -1820,7 +1816,8 @@ u16 igb_rxpbs_adjust_82580(u32 data)
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
  *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
  **/
-s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
+static s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw,
+						 u16 offset)
 {
 	s32 ret_val = 0;
 	u16 checksum = 0;
@@ -1855,7 +1852,7 @@ out:
  *  up to the checksum.  Then calculates the EEPROM checksum and writes the
  *  value to the EEPROM.
  **/
-s32 igb_update_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
+static s32 igb_update_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
 {
 	s32 ret_val;
 	u16 checksum = 0;
-- 
1.7.6.4
