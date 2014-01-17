From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/9] i40e: Change firmware workaround
Date: Fri, 17 Jan 2014 15:36:32 -0800
Message-ID: <1390001799-19425-3-git-send-email-aaron.f.brown@intel.com>
References: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55439 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbaAQXhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:37:03 -0500
In-Reply-To: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Remove a workaround that is no longer necessary and implement
a better understanding of what firmware is returning in the MSI-X
vector count.  This makes it so that the driver ends up with the 
right amount of queues when using all available MSI-X vectors.

Change-ID: I34e60cc71dcfb1b5412f37df956fedcc49ade187
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++------
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index dff4447..6d0a702 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -63,7 +63,6 @@
 #define I40E_BASE_VSI_SEID    512
 #define I40E_BASE_VEB_SEID    288
 #define I40E_MAX_VEB          16
-#define I40E_MAX_NPAR_QPS     32
 
 #define I40E_MAX_NUM_DESCRIPTORS      4096
 #define I40E_MAX_REGISTER     0x800000
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7bfa789..ff4aa74 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4704,12 +4704,8 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 		}
 	} while (err);
 
-	if (pf->hw.revision_id == 0 && (pf->flags & I40E_FLAG_MFP_ENABLED)) {
-		pf->hw.func_caps.num_msix_vectors += 1;
-		pf->hw.func_caps.num_tx_qp =
-			min_t(int, pf->hw.func_caps.num_tx_qp,
-			      I40E_MAX_NPAR_QPS);
-	}
+	/* increment MSI-X count because current FW skips one */
+	pf->hw.func_caps.num_msix_vectors++;
 
 	if (pf->hw.debug_mask & I40E_DEBUG_USER)
 		dev_info(&pf->pdev->dev,
-- 
1.8.5.GIT
