From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/16] i40e: Add description to misc and fd interrupts
Date: Sat,  6 Dec 2014 05:02:01 -0800
Message-ID: <1417870933-17248-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657AbaLFNC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:57 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds additional text description for base pf0 and flow director
generated interrupts.  Without this patch, these interrupts are difficult
to distinguish per port on a multi-function device.

Change-ID: I4662e1b38840757765a3fe63d90219d28e76bfab
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 74f378d..2f4be25 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4870,9 +4870,11 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 			goto err_set_queues;
 
 	} else if (vsi->type == I40E_VSI_FDIR) {
-		snprintf(int_name, sizeof(int_name) - 1, "%s-fdir",
-			 dev_driver_string(&pf->pdev->dev));
+		snprintf(int_name, sizeof(int_name) - 1, "%s-%s-fdir",
+			 dev_driver_string(&pf->pdev->dev),
+			 dev_name(&pf->pdev->dev));
 		err = i40e_vsi_request_irq(vsi, int_name);
+
 	} else {
 		err = -EINVAL;
 		goto err_setup_rx;
@@ -9141,9 +9143,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->aq.arq_buf_size = I40E_MAX_AQ_BUF_SIZE;
 	hw->aq.asq_buf_size = I40E_MAX_AQ_BUF_SIZE;
 	pf->adminq_work_limit = I40E_AQ_WORK_LIMIT;
+
 	snprintf(pf->misc_int_name, sizeof(pf->misc_int_name) - 1,
-		 "%s-pf%d:misc",
-		 dev_driver_string(&pf->pdev->dev), pf->hw.pf_id);
+		 "%s-%s:misc",
+		 dev_driver_string(&pf->pdev->dev), dev_name(&pdev->dev));
 
 	err = i40e_init_shared_code(hw);
 	if (err) {
-- 
1.9.3
