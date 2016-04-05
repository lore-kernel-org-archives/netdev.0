From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/18] i40e: Notify VFs of all resets
Date: Tue,  5 Apr 2016 13:17:30 -0700
Message-ID: <1459887455-146634-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43343 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759984AbcDEURl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:41 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Notify VFs in the reset interrupt handler, instead of the actual
reset initiation code. This allows the VFs to get properly notified for
all resets, including resets initiated by different PFs on the same
physical device.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e615f66..98bc749 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5534,8 +5534,6 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 
 	WARN_ON(in_interrupt());
 
-	if (i40e_check_asq_alive(&pf->hw))
-		i40e_vc_notify_reset(pf);
 
 	/* do the biggest reset indicated */
 	if (reset_flags & BIT_ULL(__I40E_GLOBAL_RESET_REQUESTED)) {
@@ -6738,6 +6736,8 @@ static void i40e_prep_for_reset(struct i40e_pf *pf)
 	clear_bit(__I40E_RESET_INTR_RECEIVED, &pf->state);
 	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
 		return;
+	if (i40e_check_asq_alive(&pf->hw))
+		i40e_vc_notify_reset(pf);
 
 	dev_dbg(&pf->pdev->dev, "Tearing down internal switch for reset\n");
 
-- 
2.5.5
