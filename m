From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Tue, 24 Nov 2015 16:04:36 -0800
Message-ID: <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbbKYAEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:51 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

Pointer of type void * shouldn't be used in arithmetic, which may
result in compilation error. Casting of (u8 *) can be added to fix
that.

Change-ID: I273aa57cdef7cacac5c552c348d585cd09d7e06b
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 6100cdd..29d6785 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -1246,7 +1246,7 @@ static i40e_status i40e_nvmupd_get_aq_result(struct i40e_hw *hw,
 		remainder -= len;
 		buff = hw->nvm_buff.va;
 	} else {
-		buff = hw->nvm_buff.va + (cmd->offset - aq_desc_len);
+		buff = (u8 *)hw->nvm_buff.va + (cmd->offset - aq_desc_len);
 	}
 
 	if (remainder > 0) {
-- 
2.5.0
