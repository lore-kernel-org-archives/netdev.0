From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] ixgbe: Fill at least min credits to a TC credit refills
Date: Fri,  8 Jan 2016 05:00:23 -0800
Message-ID: <1452258030-63996-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbcAHNAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:32 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Currently credit_refill and credit_max could be zero for a TC and that
is causing Tx hang for CEE mode configuration, so to fix that have at
min credit assigned to a TC and that is as what IEEE mode already does.

Change-ID: If652c133093a21e530f4e9eab09097976f57fb12
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index a507a6f..02c7333 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -139,6 +139,11 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *hw,
 		/* Calculate credit refill ratio using multiplier */
 		credit_refill = min(link_percentage * min_multiplier,
 				    MAX_CREDIT_REFILL);
+
+		/* Refill at least minimum credit */
+		if (credit_refill < min_credit)
+			credit_refill = min_credit;
+
 		p->data_credits_refill = (u16)credit_refill;
 
 		/* Calculate maximum credit for the TC */
@@ -149,7 +154,7 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *hw,
 		 * of a TC is too small, the maximum credit may not be
 		 * enough to send out a jumbo frame in data plane arbitration.
 		 */
-		if (credit_max && (credit_max < min_credit))
+		if (credit_max < min_credit)
 			credit_max = min_credit;
 
 		if (direction == DCB_TX_CONFIG) {
-- 
2.5.0
