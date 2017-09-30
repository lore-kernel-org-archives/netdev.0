From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: relax warning message in case of version mismatch
Date: Fri, 29 Sep 2017 17:44:57 -0700
Message-ID: <20170930004507.20072-6-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Mariusz Stachura <mariusz.stachura@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34215 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752645AbdI3Apw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:52 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Stachura <mariusz.stachura@intel.com>

Fortville and Fort Park devices are often on different firmware release
schedules. This change relaxes the minor version warning message,
so it is only displayed for older FW warning version for old
firmware Fortville 3 or earlier.

Signed-off-by: Mariusz Stachura <mariusz.stachura@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3c650917b54f..a887087d08cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11374,8 +11374,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
 		dev_info(&pdev->dev,
 			 "The driver for the device detected a newer version of the NVM image than expected. Please install the most recent version of the network driver.\n");
-	else if (hw->aq.api_maj_ver < I40E_FW_API_VERSION_MAJOR ||
-		 hw->aq.api_min_ver < (I40E_FW_API_VERSION_MINOR - 1))
+	else if (hw->aq.api_maj_ver == 1 && hw->aq.api_min_ver < 4)
 		dev_info(&pdev->dev,
 			 "The driver for the device detected an older version of the NVM image than expected. Please update the NVM image.\n");
 
-- 
2.14.1
