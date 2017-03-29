From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: remove a useless goto statement
Date: Wed, 29 Mar 2017 03:12:07 -0700
Message-ID: <20170329101215.24513-6-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3161 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755154AbdC2KM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:29 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The goto found here for when in MFP mode is pointless. It jumps to the
end of a series of if blocks. However, right after this statement is
a closing '}' for this if block, which will result in the program flow
going to the exact same location as the goto statement indicates. Thus,
regardless of whether we are in MFP mode, the program flow will resume
from the same location.

This arose due to various refactoring which did not notice that this
goto became essentially a no-op.

To properly understand this diff you will need to view a larger context
than is given by default.

Change-ID: I088f73c3831aa5c4e2281380c7a3ce605594300c
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cdf36713f4d1..1dc02c5eee1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5167,10 +5167,6 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 		    (hw->dcbx_status == I40E_DCBX_STATUS_DISABLED)) {
 			dev_info(&pf->pdev->dev,
 				 "DCBX offload is not supported or is disabled for this PF.\n");
-
-			if (pf->flags & I40E_FLAG_MFP_ENABLED)
-				goto out;
-
 		} else {
 			/* When status is not DISABLED then DCBX in FW */
 			pf->dcbx_cap = DCB_CAP_DCBX_LLD_MANAGED |
-- 
2.12.0
