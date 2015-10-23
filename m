From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] i40e: fix annoying message
Date: Thu, 22 Oct 2015 18:15:53 -0700
Message-ID: <1445562953-47496-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15283 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965724AbbJWBP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 21:15:57 -0400
In-Reply-To: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was printing a message about not being able
to assign VMDq because of a lack of MSI-X vectors.

This was because a line was missing that initialized a variable,
simply a merge error.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index dd44faf..3dd26cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7911,6 +7911,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	if (pf->hw.func_caps.vmdq) {
 		pf->num_vmdq_vsis = I40E_DEFAULT_NUM_VMDQ_VSI;
 		pf->flags |= I40E_FLAG_VMDQ_ENABLED;
+		pf->num_vmdq_qps = i40e_default_queues_per_vmdq(pf);
 	}
 
 #ifdef I40E_FCOE
-- 
2.4.3
