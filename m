From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/13] i40e: init NVM update state on adminq init
Date: Tue,  9 Dec 2014 13:26:13 -0800
Message-ID: <1418160380-29847-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60967 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbaLIV01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:27 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The adminq init is run after the EMPR that is triggered by the
NVM update.  The final write command will cause the reset and
will want to wait for the ARQ event that signals the end of the
update, but the reset precludes the event being sent.  The state
is probably already at INIT, but we set it so here anyway, and
clear the release_on_done flag as well.

Change-ID: Ie9d724a39e71f988741abc3d51b4cb198c7e0272
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Acked-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index ebff11b..77f6254 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -617,6 +617,8 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 
 	/* pre-emptive resource lock release */
 	i40e_aq_release_resource(hw, I40E_NVM_RESOURCE_ID, 0, NULL);
+	hw->aq.nvm_release_on_done = false;
+	hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 
 	ret_code = i40e_aq_set_hmc_resource_profile(hw,
 						    I40E_HMC_PROFILE_DEFAULT,
-- 
1.9.3
