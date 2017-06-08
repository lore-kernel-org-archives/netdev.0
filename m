From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix to bring link down after adapter crash
Date: Thu,  8 Jun 2017 10:52:11 +0530
Message-ID: <1496899331-18481-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:24023 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdFHFWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 01:22:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>

Use PORT_REG for T4 and T5_PORT_REG for > T4 to write to correct
register to bring down link during shutdown after adapter crash.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 4618185..da1322d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7688,10 +7688,9 @@ int t4_shutdown_adapter(struct adapter *adapter)
 	t4_intr_disable(adapter);
 	t4_write_reg(adapter, DBG_GPIO_EN_A, 0);
 	for_each_port(adapter, port) {
-		u32 a_port_cfg = PORT_REG(port,
-					  is_t4(adapter->params.chip)
-					  ? XGMAC_PORT_CFG_A
-					  : MAC_PORT_CFG_A);
+		u32 a_port_cfg = is_t4(adapter->params.chip) ?
+				       PORT_REG(port, XGMAC_PORT_CFG_A) :
+				       T5_PORT_REG(port, MAC_PORT_CFG_A);
 
 		t4_write_reg(adapter, a_port_cfg,
 			     t4_read_reg(adapter, a_port_cfg)
-- 
2.1.0
