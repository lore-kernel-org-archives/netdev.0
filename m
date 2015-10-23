From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: fix unconditional execution of cpu_to_le16()
Date: Fri, 23 Oct 2015 06:17:56 -0700
Message-ID: <1445606279-19345-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbbJWNSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:05 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit 3092e5e4cc79 ("i40e: add little endian conversion for
checksum") fixed the checksum bug on big-endian architecture.

But we should not execute cpu_to_le16() unconditionally. Thus, put
cpu_to_le16() under certain condition.

Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 1715358..6100cdd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -569,10 +569,11 @@ i40e_status i40e_update_nvm_checksum(struct i40e_hw *hw)
 	__le16 le_sum;
 
 	ret_code = i40e_calc_nvm_checksum(hw, &checksum);
-	le_sum = cpu_to_le16(checksum);
-	if (!ret_code)
+	if (!ret_code) {
+		le_sum = cpu_to_le16(checksum);
 		ret_code = i40e_write_nvm_aq(hw, 0x00, I40E_SR_SW_CHECKSUM_WORD,
 					     1, &le_sum, true);
+	}
 
 	return ret_code;
 }
-- 
2.4.3
