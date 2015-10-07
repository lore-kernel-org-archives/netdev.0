From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/18] i40evf: propagate interrupt allocation failure
Date: Wed,  7 Oct 2015 15:47:11 -0700
Message-ID: <1444258032-41476-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbbJGWr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:27 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Lower level functions are properly reporting errors, and higher-level
functions are correctly responding to errors, but the errors aren't
actually getting through. Typically, the middle-manager function seems
to want to shield its boss from any bad news.

This change fixes a panic if the driver is unable to enable MSI-X or is
unable to acquire enough vectors.

Change-ID: Ifd5787ce92519a5d97e4b465902db930d97b71a1
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index cc78fdf..0d18446 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1163,7 +1163,7 @@ static int i40evf_set_interrupt_capability(struct i40evf_adapter *adapter)
 	for (vector = 0; vector < v_budget; vector++)
 		adapter->msix_entries[vector].entry = vector;
 
-	i40evf_acquire_msix_vectors(adapter, v_budget);
+	err = i40evf_acquire_msix_vectors(adapter, v_budget);
 
 out:
 	adapter->netdev->real_num_tx_queues = pairs;
-- 
2.4.3
