From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: notify VF of all types of resets
Date: Thu,  5 Jun 2014 00:49:22 -0700
Message-ID: <1401954567-13557-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51486 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbaFEHtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:49:36 -0400
In-Reply-To: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Currently, the PF driver only notifies the VFs for PF reset events.
Instead, notify the VFs for all types of resets, so they can attempt a
graceful reinit.

Change-ID: I03eb7afde25727198ef620f8b4e78bb667a11370
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b5a8a61..78666b3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4412,6 +4412,9 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 
 	WARN_ON(in_interrupt());
 
+	if (i40e_check_asq_alive(&pf->hw))
+		i40e_vc_notify_reset(pf);
+
 	/* do the biggest reset indicated */
 	if (reset_flags & (1 << __I40E_GLOBAL_RESET_REQUESTED)) {
 
@@ -5328,9 +5331,6 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
 
 	dev_dbg(&pf->pdev->dev, "Tearing down internal switch for reset\n");
 
-	if (i40e_check_asq_alive(hw))
-		i40e_vc_notify_reset(pf);
-
 	/* quiesce the VSIs and their queues that are not already DOWN */
 	i40e_pf_quiesce_all_vsi(pf);
 
-- 
1.9.3
