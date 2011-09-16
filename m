From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: Use ring->dev instead of adapter->pdev->dev when updating DCA
Date: Thu, 15 Sep 2011 21:42:46 -0700
Message-ID: <1316148173-11209-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929Ab1IPEm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:58 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change switches us over to using the ring->dev pointer instead of
having to use the adapter->pdev->dev reference.  The advantage to this is
that it is a much shorter route to get the to final needed value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 73a669d..0564c65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -924,12 +924,12 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-		rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		rxctrl |= dca3_get_tag(rx_ring->dev, cpu);
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK_82599;
-		rxctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+		rxctrl |= (dca3_get_tag(rx_ring->dev, cpu) <<
 			   IXGBE_DCA_RXCTRL_CPUID_SHIFT_82599);
 		break;
 	default:
@@ -953,7 +953,7 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 	case ixgbe_mac_82598EB:
 		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(reg_idx));
 		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-		txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+		txctrl |= dca3_get_tag(tx_ring->dev, cpu);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(reg_idx), txctrl);
 		break;
@@ -961,7 +961,7 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 	case ixgbe_mac_X540:
 		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx));
 		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
-		txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
+		txctrl |= (dca3_get_tag(tx_ring->dev, cpu) <<
 			   IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(reg_idx), txctrl);
-- 
1.7.6
