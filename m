From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbe: Drop unnecessary napi_schedule_prep and spare blank line from ixgbe_intr
Date: Mon, 12 Mar 2012 21:03:49 -0700
Message-ID: <1331611432-30109-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839Ab2CMEEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:04 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is a minor cleanup to address the unnecessary use of
napi_schedule_prep in ixgbe_intr and to also remove a blank line that is
not needed since it is separating a comment from the line it is explaining.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 80ae919..b1f53ed 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2401,16 +2401,13 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 
-	if (napi_schedule_prep(&(q_vector->napi))) {
-		/* would disable interrupts here but EIAM disabled it */
-		__napi_schedule(&(q_vector->napi));
-	}
+	/* would disable interrupts here but EIAM disabled it */
+	napi_schedule(&q_vector->napi);
 
 	/*
 	 * re-enable link(maybe) and non-queue interrupts, no flush.
 	 * ixgbe_poll will re-enable the queue interrupts
 	 */
-
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_enable(adapter, false, false);
 
-- 
1.7.7.6
