From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40e: Change some messages from info to debug only
Date: Thu, 15 Oct 2015 02:39:52 -0700
Message-ID: <1444902004-14433-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbbJOJm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:29 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

There are several error messages that have been printing when there is
no functional issue. These messages should be available at debug message
level only.

Change-ID: Id91e47bf942c483563995f30d8705fa53acd5aa3
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c |  7 +++----
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c   |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 21 +++++++++++++--------
 3 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index 7c42d13..886e667 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -240,10 +240,9 @@ static void i40e_dcbnl_del_app(struct i40e_pf *pf,
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (pf->vsi[v] && pf->vsi[v]->netdev) {
 			err = i40e_dcbnl_vsi_del_app(pf->vsi[v], app);
-			if (err)
-				dev_info(&pf->pdev->dev, "Failed deleting app for VSI seid=%d err=%d sel=%d proto=0x%x prio=%d\n",
-					 pf->vsi[v]->seid, err, app->selector,
-					 app->protocolid, app->priority);
+			dev_dbg(&pf->pdev->dev, "Deleting app for VSI seid=%d err=%d sel=%d proto=0x%x prio=%d\n",
+				pf->vsi[v]->seid, err, app->selector,
+				app->protocolid, app->priority);
 		}
 	}
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index eaedc1f..2ec2411 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -284,7 +284,7 @@ void i40e_init_pf_fcoe(struct i40e_pf *pf)
 	pf->fcoe_hmc_filt_num = 0;
 
 	if (!pf->hw.func_caps.fcoe) {
-		dev_info(&pf->pdev->dev, "FCoE capability is disabled\n");
+		dev_dbg(&pf->pdev->dev, "FCoE capability is disabled\n");
 		return;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 10662f6..7c4add8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6593,9 +6593,9 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	/* make sure our flow control settings are restored */
 	ret = i40e_set_fc(&pf->hw, &set_fc_aq_fail, true);
 	if (ret)
-		dev_info(&pf->pdev->dev, "set fc fail, err %s aq_err %s\n",
-			 i40e_stat_str(&pf->hw, ret),
-			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
+		dev_dbg(&pf->pdev->dev, "setting flow control: ret = %s last_status = %s\n",
+			i40e_stat_str(&pf->hw, ret),
+			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 
 	/* Rebuild the VSIs and VEBs that existed before reset.
 	 * They are still in our local switch element arrays, so only
@@ -9847,8 +9847,14 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 	}
 
 	pf->queues_left = queues_left;
+	dev_dbg(&pf->pdev->dev,
+		"qs_avail=%d FD SB=%d lan_qs=%d lan_tc0=%d vf=%d*%d vmdq=%d*%d, remaining=%d\n",
+		pf->hw.func_caps.num_tx_qp,
+		!!(pf->flags & I40E_FLAG_FD_SB_ENABLED),
+		pf->num_lan_qps, pf->rss_size, pf->num_req_vfs, pf->num_vf_qps,
+		pf->num_vmdq_vsis, pf->num_vmdq_qps, queues_left);
 #ifdef I40E_FCOE
-	dev_info(&pf->pdev->dev, "fcoe queues = %d\n", pf->num_fcoe_qps);
+	dev_dbg(&pf->pdev->dev, "fcoe queues = %d\n", pf->num_fcoe_qps);
 #endif
 }
 
@@ -10333,10 +10339,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* get the requested speeds from the fw */
 	err = i40e_aq_get_phy_capabilities(hw, false, false, &abilities, NULL);
 	if (err)
-		dev_info(&pf->pdev->dev,
-			 "get phy capabilities failed, err %s aq_err %s, advertised speed settings may not be correct\n",
-			 i40e_stat_str(&pf->hw, err),
-			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
+		dev_dbg(&pf->pdev->dev, "get requested speeds ret =  %s last_status =  %s\n",
+			i40e_stat_str(&pf->hw, err),
+			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 	pf->hw.phy.link_info.requested_speeds = abilities.link_speed;
 
 	/* get the supported phy types from the fw */
-- 
2.4.3
