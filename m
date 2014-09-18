From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: use e_dev_warn instead of netif_printk
Date: Thu, 18 Sep 2014 05:26:59 -0700
Message-ID: <1411043221-7163-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392AbaIRM1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:07 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Again, we should not be directly using netif_printk, as we have our own
error print routines that we generate. In addition, instead of using an
early return we can just use the else block of this one line if
statement.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 969b979..0ec22d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1130,13 +1130,11 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	adapter->num_q_vectors = 1;
 
 	err = pci_enable_msi(adapter->pdev);
-	if (err) {
-		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
-			     "Unable to allocate MSI interrupt, falling back to legacy.  Error: %d\n",
-			     err);
-		return;
-	}
-	adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
+	if (err)
+		e_dev_warn("Failed to allocate MSI interrupt, falling back to legacy. Error: %d\n",
+			   err);
+	else
+		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
 }
 
 /**
-- 
1.9.3
