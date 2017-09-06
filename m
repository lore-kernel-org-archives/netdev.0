From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net 2/2] i40e: Avoid some useless variables and initializers in nvm functions
Date: Wed,  6 Sep 2017 10:11:39 +0200
Message-ID: <d0881adf53a3f0a546b3e7940b92b4ce938e7e50.1504684488.git.sbrivio@redhat.com>
References: <cover.1504684488.git.sbrivio@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Anjali Singhai Jain <anjali.singhai@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751938AbdIFIML (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 04:12:11 -0400
In-Reply-To: <cover.1504684488.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM update")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 200779d5c124..4a8a81cd3e32 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -294,13 +294,10 @@ static i40e_status i40e_read_nvm_word_aq(struct i40e_hw *hw, u16 offset,
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
@@ -314,7 +311,7 @@ static i40e_status __i40e_read_nvm_word(struct i40e_hw *hw,
 i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 			       u16 *data)
 {
-	i40e_status ret_code = 0;
+	i40e_status ret_code;
 
 	ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
 	if (ret_code)
@@ -429,13 +426,10 @@ static i40e_status __i40e_read_nvm_buffer(struct i40e_hw *hw,
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
2.9.4
