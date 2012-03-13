From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] ixgbe: Correct Adaptive Interrupt Moderation so that it will change values
Date: Mon, 12 Mar 2012 21:03:47 -0700
Message-ID: <1331611432-30109-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11875 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2CMEEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:04 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects an issue in which Adaptive Interrupt Moderation was
not changing values due to the fact that we were performing an and
operation on the resultant value that was causing the value to never change
from the default 20K interrupts per second.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fc3c33a..bad9c05 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1834,7 +1834,7 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int v_idx = q_vector->v_idx;
-	u32 itr_reg = q_vector->itr;
+	u32 itr_reg = q_vector->itr & IXGBE_MAX_EITR;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82598EB:
@@ -1886,7 +1886,7 @@ static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 			  ((9 * new_itr) + q_vector->itr);
 
 		/* save the algorithm value here */
-		q_vector->itr = new_itr & IXGBE_MAX_EITR;
+		q_vector->itr = new_itr;
 
 		ixgbe_write_eitr(q_vector);
 	}
-- 
1.7.7.6
