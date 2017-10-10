From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] i40e: Fix comment about locking for __i40e_read_nvm_word()
Date: Tue, 10 Oct 2017 08:14:15 -0700
Message-ID: <20171010151416.43149-2-jeffrey.t.kirsher@intel.com>
References: <20171010151416.43149-1-jeffrey.t.kirsher@intel.com>
Cc: Stefano Brivio <sbrivio@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50722 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932407AbdJJPOh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 11:14:37 -0400
In-Reply-To: <20171010151416.43149-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>

Caller needs to acquire the lock. Called functions will not.

Fixes: 09f79fd49d94 ("i40e: avoid NVM acquire deadlock during NVM update")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 57505b1df98d..d591b3e6bd7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -298,7 +298,7 @@ static i40e_status i40e_read_nvm_word_aq(struct i40e_hw *hw, u16 offset,
 }
 
 /**
- * __i40e_read_nvm_word - Reads nvm word, assumes called does the locking
+ * __i40e_read_nvm_word - Reads nvm word, assumes caller does the locking
  * @hw: pointer to the HW structure
  * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF)
  * @data: word read from the Shadow RAM
-- 
2.14.2
