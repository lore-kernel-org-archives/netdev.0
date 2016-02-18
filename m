From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: trivial: cleanup use of pf->hw
Date: Thu, 18 Feb 2016 01:04:01 -0800
Message-ID: <1455786252-71881-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14291 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425669AbcBRJEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:21 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch makes use of a pointer called hw consistent
in the i40e_remove function.

Change-ID: Idacc7ff0a09a68289c57457a78618bf5497de077
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8d41c6c..161603b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11219,8 +11219,8 @@ static void i40e_remove(struct pci_dev *pdev)
 		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
 
 	/* shutdown and destroy the HMC */
-	if (pf->hw.hmc.hmc_obj) {
-		ret_code = i40e_shutdown_lan_hmc(&pf->hw);
+	if (hw->hmc.hmc_obj) {
+		ret_code = i40e_shutdown_lan_hmc(hw);
 		if (ret_code)
 			dev_warn(&pdev->dev,
 				 "Failed to destroy the HMC resources: %d\n",
@@ -11228,7 +11228,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	}
 
 	/* shutdown the adminq */
-	ret_code = i40e_shutdown_adminq(&pf->hw);
+	ret_code = i40e_shutdown_adminq(hw);
 	if (ret_code)
 		dev_warn(&pdev->dev,
 			 "Failed to destroy the Admin Queue resources: %d\n",
@@ -11256,7 +11256,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->qp_pile);
 	kfree(pf->vsi);
 
-	iounmap(pf->hw.hw_addr);
+	iounmap(hw->hw_addr);
 	kfree(pf);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
-- 
2.5.0
