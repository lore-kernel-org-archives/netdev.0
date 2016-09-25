From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: removing unreachable code
Date: Sat, 24 Sep 2016 23:42:40 -0700
Message-ID: <1474785769-54665-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Henry Tieman <henry.w.tieman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965568AbcIYGmy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:54 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Tieman <henry.w.tieman@intel.com>

The return value from i40e_shutdown_adminq() is always 0
(I40E_SUCCESS). So, the test for non-0 will never be true. Cleanup
by removing the test and debug print statement.

Change-ID: Ie51e8e37515c3e3a6a9ff26fa951d0e5e24343c1
Signed-off-by: Henry Tieman <henry.w.tieman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 89b0418..e626761b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11333,11 +11333,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	}
 
 	/* shutdown the adminq */
-	ret_code = i40e_shutdown_adminq(hw);
-	if (ret_code)
-		dev_warn(&pdev->dev,
-			 "Failed to destroy the Admin Queue resources: %d\n",
-			 ret_code);
+	i40e_shutdown_adminq(hw);
 
 	/* destroy the locks only once, here */
 	mutex_destroy(&hw->aq.arq_mutex);
-- 
2.7.4
