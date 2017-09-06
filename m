From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net 1/2] i40e: Fix comment about locking for __i40e_read_nvm_word()
Date: Wed,  6 Sep 2017 10:11:38 +0200
Message-ID: <4d27bbb33031ac1489fe6d969edd74d44155136c.1504684488.git.sbrivio@redhat.com>
References: <cover.1504684488.git.sbrivio@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Anjali Singhai Jain <anjali.singhai@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55794 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751737AbdIFIMF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 04:12:05 -0400
In-Reply-To: <cover.1504684488.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caller needs to acquire the lock. Called functions will not.

Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM update")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 26d7e9fe6220..200779d5c124 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -281,7 +281,7 @@ static i40e_status i40e_read_nvm_word_aq(struct i40e_hw *hw, u16 offset,
 }
 
 /**
- * __i40e_read_nvm_word - Reads nvm word, assumes called does the locking
+ * __i40e_read_nvm_word - Reads nvm word, assumes caller does the locking
  * @hw: pointer to the HW structure
  * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF)
  * @data: word read from the Shadow RAM
-- 
2.9.4
