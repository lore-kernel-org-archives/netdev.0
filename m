From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: use dev_dbg instead of dev_info when warning about missing routine
Date: Tue, 20 Jun 2017 18:17:52 -0700
Message-ID: <20170621011802.81768-6-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7623 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753117AbdFUBSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:16 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When searching for the vf_capability client routine, dev_info() was
used, instead of the normal dev_dbg(). This causes the message to be
displayed at standard log levels which can cause administrators to
worry. Avoid this by using dev_dbg instead.

Copyright updated to 2017.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 36f694ccdc09..1b1e2acbd07f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2017 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -273,8 +273,8 @@ int i40e_vf_client_capable(struct i40e_pf *pf, u32 vf_id)
 	if (!cdev || !cdev->client)
 		goto out;
 	if (!cdev->client->ops || !cdev->client->ops->vf_capable) {
-		dev_info(&pf->pdev->dev,
-			 "Cannot locate client instance VF capability routine\n");
+		dev_dbg(&pf->pdev->dev,
+			"Cannot locate client instance VF capability routine\n");
 		goto out;
 	}
 	if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state))
-- 
2.12.2
