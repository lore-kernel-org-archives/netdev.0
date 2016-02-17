From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40evf: enable bus master after reset
Date: Tue, 16 Feb 2016 21:34:18 -0800
Message-ID: <1455687262-20453-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426AbcBQFe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:28 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the VF is reset via VFLR, the device will be knocked out of bus
master mode, and the driver will fail to recover from the reset. Fix
this by enabling bus mastering after every reset. In a non-VFLR case,
the bus master bit will not be disabled, and this call will have no effect.

Change-ID: Id515859ac7a691db478222228add6d149e96801a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 66964eb..933f1fc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1837,6 +1837,7 @@ static void i40evf_reset_task(struct work_struct *work)
 			break;
 		msleep(I40EVF_RESET_WAIT_MS);
 	}
+	pci_set_master(adapter->pdev);
 	/* extra wait to make sure minimum wait is met */
 	msleep(I40EVF_RESET_WAIT_MS);
 	if (i == I40EVF_RESET_WAIT_COUNT) {
-- 
2.5.0
