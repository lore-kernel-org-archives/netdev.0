From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: add ECC warning for legacy interrupts
Date: Wed, 28 Sep 2011 23:30:16 -0700
Message-ID: <1317277816-6024-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18142 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755582Ab1I2GaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:22 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Noticed that the legacy Interrupt handler didn't have the same
ECC warning as did the MSI.  So this patch adds it.

Signed-off-by: Don Skidmore <donald.c.skidmore>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3f5c5a4..9cd44ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2175,8 +2175,12 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
 		ixgbe_check_sfp_event(adapter, eicr);
+		/* Fall through */
+	case ixgbe_mac_X540:
+		if (eicr & IXGBE_EICR_ECC)
+			e_info(link, "Received unrecoverable ECC err, please "
+				     "reboot\n");
 		ixgbe_check_overtemp_event(adapter, eicr);
 		break;
 	default:
-- 
1.7.6.2
