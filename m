From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: use e_dev_warn instead of netif_printk
Date: Thu, 18 Sep 2014 05:26:54 -0700
Message-ID: <1411043221-7163-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56568 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649AbaIRM1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:05 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The netif_printk relies on our netdevice structure to be registered
already. We may call ixgbe_acquire_msix_vectors prior to registering our
netdevice, so we should not use the netdevice specific printk.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 7ecd99c..5d085d5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -717,12 +717,12 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 					vector_threshold, vectors);
 
 	if (vectors < 0) {
-		/* Can't allocate enough MSI-X interrupts?  Oh well.
-		 * This just means we'll go with either a single MSI
-		 * vector or fall back to legacy interrupts.
+		/* A negative count of allocated vectors indicates an error in
+		 * acquiring within the specified range of MSI-X vectors
 		 */
-		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
-			     "Unable to allocate MSI-X interrupts\n");
+		e_dev_warn("Failed to allocate MSI-X interrupts. Err: %d\n",
+			   vectors);
+
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-- 
1.9.3
