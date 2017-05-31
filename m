From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] i40e: Check for memory allocation failure
Date: Wed, 31 May 2017 03:48:56 -0700
Message-ID: <20170531104856.47929-10-jeffrey.t.kirsher@intel.com>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Christophe Jaillet <christophe.jaillet@wanadoo.fr>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdEaKtE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:04 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Jaillet <christophe.jaillet@wanadoo.fr>

If 'kzalloc' fails, a NULL pointer will be dereferenced. Return -ENOMEM
instead.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index c3b81a97558e..088b4a43bd2a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -595,6 +595,8 @@ static int i40e_client_setup_qvlist(struct i40e_info *ldev,
 	size = sizeof(struct i40e_qvlist_info) +
 	       (sizeof(struct i40e_qv_info) * (qvlist_info->num_vectors - 1));
 	ldev->qvlist_info = kzalloc(size, GFP_KERNEL);
+	if (!ldev->qvlist_info)
+		return -ENOMEM;
 	ldev->qvlist_info->num_vectors = qvlist_info->num_vectors;
 
 	for (i = 0; i < qvlist_info->num_vectors; i++) {
-- 
2.12.2
