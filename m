From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/18] i40e: add little endian conversion for checksum
Date: Wed,  7 Oct 2015 15:47:06 -0700
Message-ID: <1444258032-41476-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbbJGWrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:24 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The checksum is not correct on big endian machines so add code to swap it
correctly.

Change-ID: Ic92b886d172a2cbe49f5d7eee1bc78e447023c7b
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index d0288ad..2142e10 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -547,11 +547,13 @@ i40e_status i40e_update_nvm_checksum(struct i40e_hw *hw)
 {
 	i40e_status ret_code = 0;
 	u16 checksum;
+	__le16 le_sum;
 
 	ret_code = i40e_calc_nvm_checksum(hw, &checksum);
+	le_sum = cpu_to_le16(checksum);
 	if (!ret_code)
 		ret_code = i40e_write_nvm_aq(hw, 0x00, I40E_SR_SW_CHECKSUM_WORD,
-					     1, &checksum, true);
+					     1, &le_sum, true);
 
 	return ret_code;
 }
-- 
2.4.3
