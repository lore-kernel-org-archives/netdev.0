From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 13/15] i40evf: don't store unnecessary array of strings
Date: Thu, 13 Feb 2014 03:48:51 -0800
Message-ID: <1392292133-32120-14-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347AbaBMLvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:14 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Since we store the traffic vector names in the queue vector struct, we
don't need to maintain an array of strings for these names in the
adapter structure. Replace this array with a single string and use it
when allocating the misc irq vector.

Also update copyrights.

Change-ID: I664f096c3c008210d6a04a487163e8aa934fee5b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h      | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 37f5877..696c9d1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -190,7 +190,7 @@ struct i40evf_adapter {
 	struct delayed_work init_task;
 	struct i40e_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 	struct list_head vlan_filter_list;
-	char name[MAX_MSIX_COUNT][IFNAMSIZ + 9];
+	char misc_vector_name[IFNAMSIZ + 9];
 
 	/* TX */
 	struct i40e_ring *tx_rings[I40E_MAX_VSI_QP];
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f5caf44..d271d3a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 Intel Corporation.
+ * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -511,9 +511,10 @@ static int i40evf_request_misc_irq(struct i40evf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int err;
 
-	sprintf(adapter->name[0], "i40evf:mbx");
+	sprintf(adapter->misc_vector_name, "i40evf:mbx");
 	err = request_irq(adapter->msix_entries[0].vector,
-			  &i40evf_msix_aq, 0, adapter->name[0], netdev);
+			  &i40evf_msix_aq, 0,
+			  adapter->misc_vector_name, netdev);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"request_irq for msix_aq failed: %d\n", err);
-- 
1.8.5.GIT
