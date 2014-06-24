From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: no pf reset at pci remove
Date: Mon, 23 Jun 2014 17:47:36 -0700
Message-ID: <1403570858-13548-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58409 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754390AbaFXArv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:51 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The PF reset to clean up at the end of the remove is a nice thing
to do, but it also removes any LAA setting that Wake On LAN wants
for future wake up.

Change-ID: Ic090ec714df2d722281d11735cf75f2aa4432e2c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f7496a0..6522a51 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8899,7 +8899,6 @@ static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	i40e_status ret_code;
-	u32 reg;
 	int i;
 
 	i40e_dbg_pf_exit(pf);
@@ -8977,11 +8976,6 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->irq_pile);
 	kfree(pf->vsi);
 
-	/* force a PF reset to clean anything leftover */
-	reg = rd32(&pf->hw, I40E_PFGEN_CTRL);
-	wr32(&pf->hw, I40E_PFGEN_CTRL, (reg | I40E_PFGEN_CTRL_PFSWR_MASK));
-	i40e_flush(&pf->hw);
-
 	iounmap(pf->hw.hw_addr);
 	kfree(pf);
 	pci_release_selected_regions(pdev,
-- 
1.9.3
