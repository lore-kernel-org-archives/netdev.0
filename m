From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: do not take NVM ownership for SR read
Date: Thu, 26 Jun 2014 05:13:40 -0700
Message-ID: <1403784834-23301-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10401 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757547AbaFZMO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:28 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

We do not need to acquire NVM for Shadow RAM XSUM calculation, as we only
read from SR through SRCTL register for which having the ownership is not
required.

Change-ID: Ie238a8f09917d1d25f24cc7cec271951ac7b98f2
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 8129918..66bcb15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -324,13 +324,9 @@ i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
 	u16 checksum_sr = 0;
 	u16 checksum_local = 0;
 
-	ret_code = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
-	if (ret_code)
-		goto i40e_validate_nvm_checksum_exit;
-
 	ret_code = i40e_calc_nvm_checksum(hw, &checksum_local);
 	if (ret_code)
-		goto i40e_validate_nvm_checksum_free;
+		goto i40e_validate_nvm_checksum_exit;
 
 	/* Do not use i40e_read_nvm_word() because we do not want to take
 	 * the synchronization semaphores twice here.
@@ -347,9 +343,6 @@ i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
 	if (checksum)
 		*checksum = checksum_local;
 
-i40e_validate_nvm_checksum_free:
-	i40e_release_nvm(hw);
-
 i40e_validate_nvm_checksum_exit:
 	return ret_code;
 }
-- 
1.9.3
