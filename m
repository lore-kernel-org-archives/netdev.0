From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: Turn flow director off in MFP mode
Date: Thu,  9 Jan 2014 04:52:24 -0800
Message-ID: <1389271944-26227-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55960 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886AbaAIMwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:43 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

The driver needs to set the MFP flag earlier in i40e_sw_init
and then can use that flag to decide if other hardware
work-arouds are required.

Change-ID: Ib17ad1e3485f57b28845ab4722294a99f203bd48
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 63ea703..1b792ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4658,7 +4658,7 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 		}
 	} while (err);
 
-	if (pf->hw.revision_id == 0 && pf->hw.func_caps.npar_enable) {
+	if (pf->hw.revision_id == 0 && (pf->flags & I40E_FLAG_MFP_ENABLED)) {
 		pf->hw.func_caps.num_msix_vectors += 1;
 		pf->hw.func_caps.num_tx_qp =
 			min_t(int, pf->hw.func_caps.num_tx_qp,
@@ -5827,6 +5827,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		pf->rss_size = 1;
 	}
 
+	/* MFP mode enabled */
+	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.mfp_mode_1) {
+		pf->flags |= I40E_FLAG_MFP_ENABLED;
+		dev_info(&pf->pdev->dev, "MFP mode Enabled\n");
+	}
+
 	if (pf->hw.func_caps.dcb)
 		pf->num_tc_qps = I40E_DEFAULT_QUEUES_PER_TC;
 	else
@@ -5855,12 +5861,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		pf->num_vmdq_qps = I40E_DEFAULT_QUEUES_PER_VMDQ;
 	}
 
-	/* MFP mode enabled */
-	if (pf->hw.func_caps.npar_enable || pf->hw.func_caps.mfp_mode_1) {
-		pf->flags |= I40E_FLAG_MFP_ENABLED;
-		dev_info(&pf->pdev->dev, "MFP mode Enabled\n");
-	}
-
 #ifdef CONFIG_PCI_IOV
 	if (pf->hw.func_caps.num_vfs) {
 		pf->num_vf_qps = I40E_DEFAULT_QUEUES_PER_VF;
-- 
1.8.3.1
