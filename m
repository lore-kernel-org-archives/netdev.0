From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: don't complain about removing non-existent addresses
Date: Mon,  9 Jun 2014 01:49:10 -0700
Message-ID: <1402303758-1429-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27483 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290AbaFIItZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:25 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

We don't need to complain in the log about mac addresses that
can't be deleted because they don't exist.

Change-ID: I4e6370df175bf72726f06d2206c03bcbfded8387
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4ba5192..d0bc05f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1595,7 +1595,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				num_del = 0;
 				memset(del_list, 0, sizeof(*del_list));
 
-				if (aq_ret)
+				if (aq_ret &&
+				    pf->hw.aq.asq_last_status !=
+							      I40E_AQ_RC_ENOENT)
 					dev_info(&pf->pdev->dev,
 						 "ignoring delete macvlan error, err %d, aq_err %d while flushing a full buffer\n",
 						 aq_ret,
@@ -1607,7 +1609,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 						     del_list, num_del, NULL);
 			num_del = 0;
 
-			if (aq_ret)
+			if (aq_ret &&
+			    pf->hw.aq.asq_last_status != I40E_AQ_RC_ENOENT)
 				dev_info(&pf->pdev->dev,
 					 "ignoring delete macvlan error, err %d, aq_err %d\n",
 					 aq_ret, pf->hw.aq.asq_last_status);
-- 
1.9.3
