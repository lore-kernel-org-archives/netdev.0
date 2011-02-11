From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 06/15] ixgbe: DCB, remove round robin mode on 82598 devices
Date: Fri, 11 Feb 2011 09:20:53 -0800
Message-ID: <1297444862-32091-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2017 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757840Ab1BKRVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:21 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Remove round robin configuration code for 82598 parts it
is not settable and is always false.

If we need/want this in the future we can add it back properly.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.h       |    1 -
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    6 ++----
 drivers/net/ixgbe/ixgbe_main.c      |    1 -
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 1cfe38e..d0b2450 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -139,7 +139,6 @@ struct ixgbe_dcb_config {
 	struct tc_configuration tc_config[MAX_TRAFFIC_CLASS];
 	u8     bw_percentage[2][MAX_BW_GROUP]; /* One each for Tx/Rx */
 	bool   pfc_mode_enable;
-	bool   round_robin_enable;
 
 	enum dcb_rx_pba_cfg rx_pba_cfg;
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 9a5e89c..19aa806 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -146,10 +146,8 @@ static s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
 
 	/* Enable arbiter */
 	reg &= ~IXGBE_DPMCS_ARBDIS;
-	if (!(dcb_config->round_robin_enable)) {
-		/* Enable DFP and Recycle mode */
-		reg |= (IXGBE_DPMCS_TDPAC | IXGBE_DPMCS_TRM);
-	}
+	/* Enable DFP and Recycle mode */
+	reg |= (IXGBE_DPMCS_TDPAC | IXGBE_DPMCS_TRM);
 	reg |= IXGBE_DPMCS_TSOEF;
 	/* Configure Max TSO packet size 34KB including payload and headers */
 	reg |= (0x4 << IXGBE_DPMCS_MTSOS_SHIFT);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbae703..1e48148 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5173,7 +5173,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->dcb_cfg.bw_percentage[DCB_RX_CONFIG][0] = 100;
 	adapter->dcb_cfg.rx_pba_cfg = pba_equal;
 	adapter->dcb_cfg.pfc_mode_enable = false;
-	adapter->dcb_cfg.round_robin_enable = false;
 	adapter->dcb_set_bitmap = 0x00;
 	ixgbe_copy_dcb_cfg(&adapter->dcb_cfg, &adapter->temp_dcb_cfg,
 			   adapter->ring_feature[RING_F_DCB].indices);
-- 
1.7.4

