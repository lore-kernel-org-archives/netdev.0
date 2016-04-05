From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/18] i40evf: remove dead code
Date: Tue,  5 Apr 2016 13:17:20 -0700
Message-ID: <1459887455-146634-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Cox <alan@linux.intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759953AbcDEURi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:38 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

The only error case is when the malloc fails, in which case the clean up
loop does nothing at all, so remove it

Signed-off-by: Alan Cox <alan@linux.intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4b70aae..820ad94 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1507,7 +1507,7 @@ static int i40evf_alloc_q_vectors(struct i40evf_adapter *adapter)
 	adapter->q_vectors = kcalloc(num_q_vectors, sizeof(*q_vector),
 				     GFP_KERNEL);
 	if (!adapter->q_vectors)
-		goto err_out;
+		return -ENOMEM;
 
 	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
 		q_vector = &adapter->q_vectors[q_idx];
@@ -1519,15 +1519,6 @@ static int i40evf_alloc_q_vectors(struct i40evf_adapter *adapter)
 	}
 
 	return 0;
-
-err_out:
-	while (q_idx) {
-		q_idx--;
-		q_vector = &adapter->q_vectors[q_idx];
-		netif_napi_del(&q_vector->napi);
-	}
-	kfree(adapter->q_vectors);
-	return -ENOMEM;
 }
 
 /**
-- 
2.5.5
