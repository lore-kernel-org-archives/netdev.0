From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e: add more verbose error messages
Date: Thu,  8 Oct 2015 18:32:41 -0700
Message-ID: <1444354374-24351-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415AbbJIBc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:57 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Under certain circumstances, the device may not have enough resources to
enable all of the VFs that it advertises in config space. Although the
number of supported VFs is reported upon driver init, it is not obvious
when this is different from the number reported in config space. To
eliminate this confusion, add an error message explaining the problem.
Additionally, move the 'Allocating VFs' message down below the error
checks so as to prevent further confusion.

Change-ID: I45b7efca53a7aebf7777be33a8bc9d615ae48ea1
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0545e3f..fac8a02 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -998,17 +998,19 @@ static int i40e_pci_sriov_enable(struct pci_dev *pdev, int num_vfs)
 		goto err_out;
 	}
 
-	dev_info(&pdev->dev, "Allocating %d VFs.\n", num_vfs);
 	if (pre_existing_vfs && pre_existing_vfs != num_vfs)
 		i40e_free_vfs(pf);
 	else if (pre_existing_vfs && pre_existing_vfs == num_vfs)
 		goto out;
 
 	if (num_vfs > pf->num_req_vfs) {
+		dev_warn(&pdev->dev, "Unable to enable %d VFs. Limited to %d VFs due to device resource constraints.\n",
+			 num_vfs, pf->num_req_vfs);
 		err = -EPERM;
 		goto err_out;
 	}
 
+	dev_info(&pdev->dev, "Allocating %d VFs.\n", num_vfs);
 	err = i40e_alloc_vfs(pf, num_vfs);
 	if (err) {
 		dev_warn(&pdev->dev, "Failed to enable SR-IOV: %d\n", err);
-- 
2.4.3
