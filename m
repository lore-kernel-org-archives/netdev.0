From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: handle serial flash interrupt
Date: Wed, 14 Jun 2017 00:45:43 +0530
Message-ID: <1497381343-31705-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:63312 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753764AbdFMTQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 15:16:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SF bit is not cleared in PL_INT_CAUSE, subsequent non-data
interrupts are not raised.  Enable SF bit in Global Interrupt
Mask and handle it as non-fatal and hence eventually clear it.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 16af646..d5e316d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4462,7 +4462,7 @@ static void pl_intr_handler(struct adapter *adap)
 #define PF_INTR_MASK (PFSW_F)
 #define GLBL_INTR_MASK (CIM_F | MPS_F | PL_F | PCIE_F | MC_F | EDC0_F | \
 		EDC1_F | LE_F | TP_F | MA_F | PM_TX_F | PM_RX_F | ULP_RX_F | \
-		CPL_SWITCH_F | SGE_F | ULP_TX_F)
+		CPL_SWITCH_F | SGE_F | ULP_TX_F | SF_F)
 
 /**
  *	t4_slow_intr_handler - control path interrupt handler
-- 
2.1.0
