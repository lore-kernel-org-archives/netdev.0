From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/20] fm10k: only warn when stop_hw fails with FM10K_ERR_REQUESTS_PENDING
Date: Wed, 20 Jul 2016 15:23:46 -0700
Message-ID: <1469053438-85381-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbcGTWYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:03 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When stop_hw() routine fails with FM10K_ERR_REQUESTS_PENDING, this
indicates that the Tx or Rx queues did not shutdown within the time
limit. Print a more suitable message at the dev_info level instead of
dev_err.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4439376..4dfd128 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1644,7 +1644,10 @@ void fm10k_down(struct fm10k_intfc *interface)
 
 	/* Disable DMA engine for Tx/Rx */
 	err = hw->mac.ops.stop_hw(hw);
-	if (err)
+	if (err == FM10K_ERR_REQUESTS_PENDING)
+		dev_info(&interface->pdev->dev,
+			 "due to pending requests hw was not shut down gracefully\n");
+	else if (err)
 		dev_err(&interface->pdev->dev, "stop_hw failed: %d\n", err);
 
 	/* free any buffers still on the rings */
-- 
2.5.5
