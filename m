From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 10/37] atl1c: remove dmaw_block
Date: Fri, 13 Apr 2012 08:14:35 +0800
Message-ID: <1334276102-15866-11-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dmaw_block is never used in the driver, remove it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    4 ----
 2 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index 16a5c7a..6e5ae89 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -374,7 +374,6 @@ struct atl1c_hw {
 	enum atl1c_dma_order dma_order;
 	enum atl1c_dma_rcb   rcb_value;
 	enum atl1c_dma_req_block dmar_block;
-	enum atl1c_dma_req_block dmaw_block;
 
 	u16 device_id;
 	u16 vendor_id;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1ce48d0..d6ebaa4 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -740,7 +740,6 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 	hw->rfd_burst = 8;
 	hw->dma_order = atl1c_dma_ord_out;
 	hw->dmar_block = atl1c_dma_req_1024;
-	hw->dmaw_block = atl1c_dma_req_1024;
 	hw->dmar_dly_cnt = 15;
 	hw->dmaw_dly_cnt = 4;
 
@@ -1056,9 +1055,6 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
 	AT_READ_REG(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
-	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT) &
-			DEVICE_CTRL_MAX_PAYLOAD_MASK;
-	hw->dmaw_block = min_t(u32, max_pay_load, hw->dmaw_block);
 	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT) &
 			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
 	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
-- 
1.7.7
