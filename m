From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] i40e/i40evf: assure clean asq status report
Date: Wed,  7 Oct 2015 15:47:02 -0700
Message-ID: <1444258032-41476-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Christopher Pau <christopher.pau@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbbJGWrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:24 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There was a possibility where the asq_last_status could get through without
update and thus report a previous error.  I don't think we've actually seen
this happen, but this patch will help make sure it doesn't.

Change-ID: I9e33927052a5ee6ea21f80b66d4c4b76c2760b17
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Christopher Pau <christopher.pau@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 34a64e0..287cb8d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -756,6 +756,8 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 		goto asq_send_command_error;
 	}
 
+	hw->aq.asq_last_status = I40E_AQ_RC_OK;
+
 	val = rd32(hw, hw->aq.asq.head);
 	if (val >= hw->aq.num_asq_entries) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index c7f59e0..c5cf886 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -696,6 +696,8 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 		goto asq_send_command_error;
 	}
 
+	hw->aq.asq_last_status = I40E_AQ_RC_OK;
+
 	val = rd32(hw, hw->aq.asq.head);
 	if (val >= hw->aq.num_asq_entries) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-- 
2.4.3
