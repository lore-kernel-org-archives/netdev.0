From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] e1000e: use hardware default values for Transmit Control register
Date: Wed, 25 Jan 2012 23:21:54 -0800
Message-ID: <1327562515-29664-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17059 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705Ab2AZHWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:22:02 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This code snippet is simply writing default values to the register which is
unnecessary since the values are programmed into the register by default.
There is a special case for 80003es2lan needing the Retransmit on Late
Collision bit set but that is also done in e1000_init_hw_80003es2lan().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index fb29990..89af6c0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2770,7 +2770,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	u64 tdba;
-	u32 tdlen, tctl, tarc;
+	u32 tdlen, tarc;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	tdba = tx_ring->dma;
@@ -2808,12 +2808,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	/* erratum work around: set txdctl the same for both queues */
 	ew32(TXDCTL(1), er32(TXDCTL(0)));
 
-	/* Program the Transmit Control Register */
-	tctl = er32(TCTL);
-	tctl &= ~E1000_TCTL_CT;
-	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
-		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
-
 	if (adapter->flags & FLAG_TARC_SPEED_MODE_BIT) {
 		tarc = er32(TARC(0));
 		/*
@@ -2845,8 +2839,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	/* enable Report Status bit */
 	adapter->txd_cmd |= E1000_TXD_CMD_RS;
 
-	ew32(TCTL, tctl);
-
 	e1000e_config_collision_dist(hw);
 }
 
-- 
1.7.7.6
