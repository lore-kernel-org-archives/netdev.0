From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 13/14] i40e: Change MSIX to MSI-X
Date: Fri, 14 Feb 2014 14:58:07 -0800
Message-ID: <1392418688-23895-14-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50864 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbaBNXB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:27 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Fix inconsistent use of MSIX and MSI-X in messages.

Change-ID: Iae9ffb42819677c34544719044ed77632e06147d
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 9 +++++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4a19073..7562af7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5946,7 +5946,7 @@ static int i40e_init_msix(struct i40e_pf *pf)
 
 	} else if (vec == I40E_MIN_MSIX) {
 		/* Adjust for minimal MSIX use */
-		dev_info(&pf->pdev->dev, "Features disabled, not enough MSIX vectors\n");
+		dev_info(&pf->pdev->dev, "Features disabled, not enough MSI-X vectors\n");
 		pf->flags &= ~I40E_FLAG_VMDQ_ENABLED;
 		pf->num_vmdq_vsis = 0;
 		pf->num_vmdq_qps = 0;
@@ -6075,7 +6075,7 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 
 	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSI_ENABLED)) {
-		dev_info(&pf->pdev->dev, "MSIX not available, trying MSI\n");
+		dev_info(&pf->pdev->dev, "MSI-X not available, trying MSI\n");
 		err = pci_enable_msi(pf->pdev);
 		if (err) {
 			dev_info(&pf->pdev->dev, "MSI init failed - %d\n", err);
@@ -6084,7 +6084,7 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	}
 
 	if (!(pf->flags & (I40E_FLAG_MSIX_ENABLED | I40E_FLAG_MSI_ENABLED)))
-		dev_info(&pf->pdev->dev, "MSIX and MSI not available, falling back to Legacy IRQ\n");
+		dev_info(&pf->pdev->dev, "MSI-X and MSI not available, falling back to Legacy IRQ\n");
 
 	/* track first vector for misc interrupts */
 	err = i40e_get_lump(pf, pf->irq_pile, 1, I40E_PILE_VALID_BIT-1);
@@ -6111,7 +6111,8 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 				  i40e_intr, 0, pf->misc_int_name, pf);
 		if (err) {
 			dev_info(&pf->pdev->dev,
-				 "request_irq for msix_misc failed: %d\n", err);
+				 "request_irq for %s failed: %d\n",
+				 pf->misc_int_name, err);
 			return -EFAULT;
 		}
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5bcbdcc..e0d2799 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -524,7 +524,8 @@ static int i40evf_request_misc_irq(struct i40evf_adapter *adapter)
 			  adapter->misc_vector_name, netdev);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
-			"request_irq for msix_aq failed: %d\n", err);
+			"request_irq for %s failed: %d\n",
+			adapter->misc_vector_name, err);
 		free_irq(adapter->msix_entries[0].vector, netdev);
 	}
 	return err;
-- 
1.8.5.GIT
