From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] ixgbe/ixgbevf: Limit maximum jumbo frame size to 9.5K to avoid Tx hangs
Date: Tue,  9 Oct 2012 03:13:31 -0700
Message-ID: <1349777612-30149-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755251Ab2JIKNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 06:13:46 -0400
In-Reply-To: <1349777612-30149-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change limits the PF/VF driver to 9.5K max jumbo frame size in order
prevent a possible Tx hang in the adapter when sending frames between
pools.

All of the parts in ixgbe support a maximum frame of 15.5K for standard
traffic, however with SR-IOV or DCB enabled they should be limiting the
MTU size to 9.5K.  Instead of adding extra checks which would have to
change the MTU when we go into or out of these modes it is preferred to
just use a standard 9.5K MTU limit for all modes so that this extra
overhead can be avoided.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h     | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 5bd2676..30efc9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -410,7 +410,7 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 #define IXGBE_TX_CTXTDESC(R, i)	    \
 	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
-#define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
+#define IXGBE_MAX_JUMBO_FRAME_SIZE	9728 /* Maximum Supported Size 9.5KB */
 #ifdef IXGBE_FCOE
 /* Use 3K as the baby jumbo frame size for FCoE */
 #define IXGBE_FCOE_JUMBO_FRAME_SIZE       3072
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 383b4e1..4a9c9c2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -175,7 +175,7 @@ struct ixgbevf_q_vector {
 #define IXGBEVF_TX_CTXTDESC(R, i)	    \
 	(&(((struct ixgbe_adv_tx_context_desc *)((R)->desc))[i]))
 
-#define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
+#define IXGBE_MAX_JUMBO_FRAME_SIZE	9728 /* Maximum Supported Size 9.5KB */
 
 #define OTHER_VECTOR 1
 #define NON_Q_VECTORS (OTHER_VECTOR)
-- 
1.7.11.4
