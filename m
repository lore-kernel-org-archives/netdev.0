From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: cleanup X540 interrupt enablement
Date: Wed, 21 Sep 2011 03:12:50 -0700
Message-ID: <1316599974-23205-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1070 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab1IUKM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 06:12:59 -0400
In-Reply-To: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We don't need SFP+ plugable support for X540 hardware (copper only) so
don't enable the SFP+ interrupts.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4cbc3f9..fae2f44 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1863,10 +1863,10 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 		mask |= IXGBE_EIMS_GPI_SDP1;
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_GPI_SDP1;
 		mask |= IXGBE_EIMS_GPI_SDP2;
+	case ixgbe_mac_X540:
+		mask |= IXGBE_EIMS_ECC;
 		mask |= IXGBE_EIMS_MAILBOX;
 		break;
 	default:
-- 
1.7.6.2
