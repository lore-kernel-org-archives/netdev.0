From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: expand comment
Date: Thu, 18 Feb 2016 01:04:07 -0800
Message-ID: <1455786252-71881-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60482 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425570AbcBRJES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:18 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Explain why we cannot remove this code, even though it works differently
than any of our other interrupt cause handling code.

Change-ID: Ie66203bd037a466066036611c31d44f759ec5176
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 597f209..5dcd198 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2037,7 +2037,11 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 	if (!test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
 		return 0;
 
-	/* re-enable vflr interrupt cause */
+	/* Re-enable the VFLR interrupt cause here, before looking for which
+	 * VF got reset. Otherwise, if another VF gets a reset while the
+	 * first one is being processed, that interrupt will be lost, and
+	 * that VF will be stuck in reset forever.
+	 */
 	reg = rd32(hw, I40E_PFINT_ICR0_ENA);
 	reg |= I40E_PFINT_ICR0_ENA_VFLR_MASK;
 	wr32(hw, I40E_PFINT_ICR0_ENA, reg);
-- 
2.5.0
