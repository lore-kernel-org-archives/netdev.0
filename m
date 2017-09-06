From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] i40e: point wb_desc at the nvm_wb_desc during i40e_read_nvm_aq
Date: Tue,  5 Sep 2017 18:04:18 -0700
Message-ID: <20170906010418.39007-3-jeffrey.t.kirsher@intel.com>
References: <20170906010418.39007-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63879 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753809AbdIFBE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 21:04:26 -0400
In-Reply-To: <20170906010418.39007-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When introducing the functions to read the NVM through the AdminQ, we
did not correctly mark the wb_desc.

Fixes: 7073f46e443e ("i40e: Add AQ commands for NVM Update for X722", 2015-06-05)
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 154ba49c2c6f..26d7e9fe6220 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -230,6 +230,7 @@ static i40e_status i40e_read_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
 	struct i40e_asq_cmd_details cmd_details;
 
 	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
 
 	/* Here we are checking the SR limit only for the flat memory model.
 	 * We cannot do it for the module-based model, as we did not acquire
-- 
2.14.1
