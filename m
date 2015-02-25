From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40evf: Add more info to interrupt vector names
Date: Wed, 25 Feb 2015 00:58:39 -0800
Message-ID: <1424854720-18825-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbbBYI6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:50 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds the netdev name to the VF misc vector name.  Without
this patch, all the interrupts show the same info, so it difficult to
distinguish them.

Change-ID: I247828697e1373ecfb5f8dc1bc9618e98a7f4942
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e089e8f..de507b3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -524,7 +524,8 @@ static int i40evf_request_misc_irq(struct i40evf_adapter *adapter)
 	int err;
 
 	snprintf(adapter->misc_vector_name,
-		 sizeof(adapter->misc_vector_name) - 1, "i40evf:mbx");
+		 sizeof(adapter->misc_vector_name) - 1, "i40evf-%s:mbx",
+		 dev_name(&adapter->pdev->dev));
 	err = request_irq(adapter->msix_entries[0].vector,
 			  &i40evf_msix_aq, 0,
 			  adapter->misc_vector_name, netdev);
-- 
1.9.3
