From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 19/20] fm10k: return proper error code when pci_enable_msix_range fails
Date: Wed, 20 Jul 2016 15:23:57 -0700
Message-ID: <1469053438-85381-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465AbcGTWYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:09 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The pci_enable_msix_range() function returns a positive value of the
number of allocated vectors if it succeeds. On failure it returns
a negative error code. Return this code properly so that the error
message printed by the driver will show the actual error code instead of
being masked by -ENOMEM.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c85fc9894..f72d1ca 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1858,7 +1858,7 @@ static int fm10k_init_msix_capability(struct fm10k_intfc *interface)
 	if (v_budget < 0) {
 		kfree(interface->msix_entries);
 		interface->msix_entries = NULL;
-		return -ENOMEM;
+		return v_budget;
 	}
 
 	/* record the number of queues available for q_vectors */
-- 
2.5.5
