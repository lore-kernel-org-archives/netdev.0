From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/11] i40e: hush little warnings
Date: Sat, 12 Dec 2015 21:17:33 -0800
Message-ID: <1449983857-74434-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59603 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbbLMFRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 00:17:43 -0500
In-Reply-To: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

These messages seem big and scary, but they're really not. The driver
can fully recover from any of these. The overflow error in particular
can happen when enabling a bunch of VFs and the VF driver is not
blacklisted.

Since these messages are really for debugging purposes, reclassify
them as such.

Change-ID: I628d0f5e135e7063450ba05393a50b7af23aa6d7
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index aff401f..35d787e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6219,15 +6219,18 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	val = rd32(&pf->hw, pf->hw.aq.arq.len);
 	oldval = val;
 	if (val & I40E_PF_ARQLEN_ARQVFE_MASK) {
-		dev_info(&pf->pdev->dev, "ARQ VF Error detected\n");
+		if (hw->debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ARQ VF Error detected\n");
 		val &= ~I40E_PF_ARQLEN_ARQVFE_MASK;
 	}
 	if (val & I40E_PF_ARQLEN_ARQOVFL_MASK) {
-		dev_info(&pf->pdev->dev, "ARQ Overflow Error detected\n");
+		if (hw->debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ARQ Overflow Error detected\n");
 		val &= ~I40E_PF_ARQLEN_ARQOVFL_MASK;
 	}
 	if (val & I40E_PF_ARQLEN_ARQCRIT_MASK) {
-		dev_info(&pf->pdev->dev, "ARQ Critical Error detected\n");
+		if (hw->debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ARQ Critical Error detected\n");
 		val &= ~I40E_PF_ARQLEN_ARQCRIT_MASK;
 	}
 	if (oldval != val)
@@ -6236,15 +6239,18 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	val = rd32(&pf->hw, pf->hw.aq.asq.len);
 	oldval = val;
 	if (val & I40E_PF_ATQLEN_ATQVFE_MASK) {
-		dev_info(&pf->pdev->dev, "ASQ VF Error detected\n");
+		if (pf->hw.debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ASQ VF Error detected\n");
 		val &= ~I40E_PF_ATQLEN_ATQVFE_MASK;
 	}
 	if (val & I40E_PF_ATQLEN_ATQOVFL_MASK) {
-		dev_info(&pf->pdev->dev, "ASQ Overflow Error detected\n");
+		if (pf->hw.debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ASQ Overflow Error detected\n");
 		val &= ~I40E_PF_ATQLEN_ATQOVFL_MASK;
 	}
 	if (val & I40E_PF_ATQLEN_ATQCRIT_MASK) {
-		dev_info(&pf->pdev->dev, "ASQ Critical Error detected\n");
+		if (pf->hw.debug_mask & I40E_DEBUG_AQ)
+			dev_info(&pf->pdev->dev, "ASQ Critical Error detected\n");
 		val &= ~I40E_PF_ATQLEN_ATQCRIT_MASK;
 	}
 	if (oldval != val)
-- 
2.5.0
