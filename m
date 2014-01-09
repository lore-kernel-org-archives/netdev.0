From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: release NVM resource reservation on startup
Date: Thu,  9 Jan 2014 04:52:17 -0800
Message-ID: <1389271944-26227-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755102AbaAIMwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:34 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Call AQ to release any reservation held by this PF on the NVM resource
lock on startup, in order to clear anything that might have been left over from
a previous run.  The lock is only cleared by the requestor calling for it to be
cleared, on power-on, or firmware reset.  This should help limit the need for
rebooting a customer machine if something goes wrong on a firmware update or
some other action.

Change-ID: I8c8473e601d4ef512dda7baa77a6e75f2e5fea49
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index eb014bb..2b76aba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -583,6 +583,9 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 		goto init_adminq_free_arq;
 	}
 
+	/* pre-emptive resource lock release */
+	i40e_aq_release_resource(hw, I40E_NVM_RESOURCE_ID, 0, NULL);
+
 	ret_code = i40e_aq_set_hmc_resource_profile(hw,
 						    I40E_HMC_PROFILE_DEFAULT,
 						    0,
-- 
1.8.3.1
