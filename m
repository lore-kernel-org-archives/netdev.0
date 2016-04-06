From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: Disable link polling
Date: Tue,  5 Apr 2016 20:36:03 -0700
Message-ID: <1459913769-56510-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61852 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760048AbcDFDg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:27 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Periodic link polling was added when the link events were found not to be
trustworthy.  This was the case early on, but was likely because the link
event mask was being used incorrectly.  As this has been fixed in recent
code, we can disable the link polling to lessen the AQ traffic.

Change-ID: Id890b5ee3c2d04381fc76ffa434777644f5d8eb0
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 73d4bea..184f3f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8448,7 +8448,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
-		    I40E_FLAG_LINK_POLLING_ENABLED |
 		    I40E_FLAG_MSIX_ENABLED;
 
 	if (iommu_present(&pci_bus_type))
-- 
2.5.5
