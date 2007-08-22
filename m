From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 8/11] cxgb3 - Update internal memory management
Date: Tue, 21 Aug 2007 20:49:41 -0700
Message-ID: <20070822034941.9387.79621.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24424 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757363AbXHVDto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Set PM1 internal memory to round robin mode
It balances access to this internal memory for multiport adapters.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/regs.h  |    2 ++
 drivers/net/cxgb3/t3_hw.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 2824278..5e1bc0d 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1326,6 +1326,7 @@
 #define V_D0_WEIGHT(x) ((x) << S_D0_WEIGHT)
 
 #define A_PM1_RX_CFG 0x5c0
+#define A_PM1_RX_MODE 0x5c4
 
 #define A_PM1_RX_INT_ENABLE 0x5d8
 
@@ -1394,6 +1395,7 @@
 #define A_PM1_RX_INT_CAUSE 0x5dc
 
 #define A_PM1_TX_CFG 0x5e0
+#define A_PM1_TX_MODE 0x5e4
 
 #define A_PM1_TX_INT_ENABLE 0x5f8
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 23b1a16..13bfbec 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3189,6 +3189,8 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 		t3_set_reg_field(adapter, A_PCIX_CFG, 0, F_CLIDECEN);
 
 	t3_write_reg(adapter, A_PM1_RX_CFG, 0xffffffff);
+	t3_write_reg(adapter, A_PM1_RX_MODE, 0);
+	t3_write_reg(adapter, A_PM1_TX_MODE, 0);
 	init_hw_for_avail_ports(adapter, adapter->params.nports);
 	t3_sge_init(adapter, &adapter->params.sge);
 
