From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: Update DESC_NEEDED define to adjust for changes to MAX_SKB_FRAGS
Date: Sat, 16 Feb 2013 00:33:36 -0800
Message-ID: <1361003616-3422-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535Ab3BPIdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:49 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Recent changes have made it so that MAX_SKB_FRAGS is now never less than 16.
As a result we were seeing issues on systems with 64K pages as it would
cause DESC_NEEDED to increase to 68, and we would need over 136 descriptors
free before clean_tx_irq would wake the queue.

This patch makes it so that DESC_NEEDED is always MAX_SKB_FRAGS + 4.  This
should prevent any possible deadlocks on the systems with 64K pages as we will
now only require 42 descriptors to wake.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 196002b..a8e10cf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -156,7 +156,7 @@ struct vf_macvlans {
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IXGBE_MAX_DATA_PER_TXD)
-#define DESC_NEEDED ((MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE)) + 4)
+#define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
-- 
1.7.11.7
