From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/18] i40e: make i40e_init_pf_fcoe to void
Date: Wed,  7 Oct 2015 15:47:01 -0700
Message-ID: <1444258032-41476-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778AbbJGWr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:26 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

i40e_init_pf_fcoe() didn't return anything except 0, it prints enough
error info already, and no driver logic depends on the return value,
so this can be void.

Change-ID: Ie6afad849857d87a7064c42c3cce14c74c2f29d8
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 10 ++++------
 drivers/net/ethernet/intel/i40e/i40e_main.c |  8 ++------
 3 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f6d97ad..44837ec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -740,7 +740,7 @@ int i40e_fcoe_vsi_init(struct i40e_vsi *vsi, struct i40e_vsi_context *ctxt);
 u8 i40e_get_fcoe_tc_map(struct i40e_pf *pf);
 void i40e_fcoe_config_netdev(struct net_device *netdev, struct i40e_vsi *vsi);
 void i40e_fcoe_vsi_setup(struct i40e_pf *pf);
-int i40e_init_pf_fcoe(struct i40e_pf *pf);
+void i40e_init_pf_fcoe(struct i40e_pf *pf);
 int i40e_fcoe_setup_ddp_resources(struct i40e_vsi *vsi);
 void i40e_fcoe_free_ddp_resources(struct i40e_vsi *vsi);
 int i40e_fcoe_handle_offload(struct i40e_ring *rx_ring,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 5ea75dd..2398d9b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -272,10 +272,8 @@ out:
 /**
  * i40e_fcoe_sw_init - sets up the HW for FCoE
  * @pf: pointer to PF
- *
- * Returns 0 if FCoE is supported otherwise the error code
  **/
-int i40e_init_pf_fcoe(struct i40e_pf *pf)
+void i40e_init_pf_fcoe(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	u32 val;
@@ -287,13 +285,13 @@ int i40e_init_pf_fcoe(struct i40e_pf *pf)
 
 	if (!pf->hw.func_caps.fcoe) {
 		dev_info(&pf->pdev->dev, "FCoE capability is disabled\n");
-		return 0;
+		return;
 	}
 
 	if (!pf->hw.func_caps.dcb) {
 		dev_warn(&pf->pdev->dev,
 			 "Hardware is not DCB capable not enabling FCoE.\n");
-		return 0;
+		return;
 	}
 
 	/* enable FCoE hash filter */
@@ -326,7 +324,7 @@ int i40e_init_pf_fcoe(struct i40e_pf *pf)
 	wr32(hw, I40E_GLFCOE_RCTL, val);
 
 	dev_info(&pf->pdev->dev, "FCoE is supported.\n");
-	return 0;
+	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 19eb14d..0ef6a15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6573,9 +6573,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 #endif /* CONFIG_I40E_DCB */
 #ifdef I40E_FCOE
-	ret = i40e_init_pf_fcoe(pf);
-	if (ret)
-		dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", ret);
+	i40e_init_pf_fcoe(pf);
 
 #endif
 	/* do basic switch setup */
@@ -7976,9 +7974,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	}
 
 #ifdef I40E_FCOE
-	err = i40e_init_pf_fcoe(pf);
-	if (err)
-		dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", err);
+	i40e_init_pf_fcoe(pf);
 
 #endif /* I40E_FCOE */
 #ifdef CONFIG_PCI_IOV
-- 
2.4.3
