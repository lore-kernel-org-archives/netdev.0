From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: Avoid some useless variables and initializers in NVM functions
Date: Mon,  9 Oct 2017 15:38:41 -0700
Message-ID: <20171009223841.2557-15-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Stefano Brivio <sbrivio@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754068AbdJIWjI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:08 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>

Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM update")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 57505b1df98d..151d9cfb6ea4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -311,13 +311,10 @@ static i40e_status i40e_read_nvm_word_aq(struct i40e_hw *hw, u16 offset,
 static i40e_status __i40e_read_nvm_word(struct i40e_hw *hw,
 					u16 offset, u16 *data)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE)
-		ret_code = i40e_read_nvm_word_aq(hw, offset, data);
-	else
-		ret_code = i40e_read_nvm_word_srctl(hw, offset, data);
-	return ret_code;
+		return i40e_read_nvm_word_aq(hw, offset, data);
+
+	return i40e_read_nvm_word_srctl(hw, offset, data);
 }
 
 /**
@@ -331,7 +328,7 @@ static i40e_status __i40e_read_nvm_word(struct i40e_hw *hw,
 i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 			       u16 *data)
 {
-	i40e_status ret_code = 0;
+	i40e_status ret_code;
 
 	ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
 	if (ret_code)
@@ -446,13 +443,10 @@ static i40e_status __i40e_read_nvm_buffer(struct i40e_hw *hw,
 					  u16 offset, u16 *words,
 					  u16 *data)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE)
-		ret_code = i40e_read_nvm_buffer_aq(hw, offset, words, data);
-	else
-		ret_code = i40e_read_nvm_buffer_srctl(hw, offset, words, data);
-	return ret_code;
+		return i40e_read_nvm_buffer_aq(hw, offset, words, data);
+
+	return i40e_read_nvm_buffer_srctl(hw, offset, words, data);
 }
 
 /**
-- 
2.14.2
