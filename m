From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [for 4.14] net: qcom/emac: specify the correct size when mapping a DMA buffer
Date: Fri, 22 Sep 2017 15:32:44 -0500
Message-ID: <1506112364-26787-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When mapping the RX DMA buffers, the driver was accidentally specifying
zero for the buffer length.  Under normal circumstances, SWIOTLB does not
need to allocate a bounce buffer, so the address is just mapped without
checking the size field.  This is why the error was not detected earlier.

Fixes: b9b17debc69d ("net: emac: emac gigabit ethernet controller driver")
Cc: stable@vger.kernel.org
Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 0ea3ca09c689..3ed9033e56db 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -898,7 +898,8 @@ static void emac_mac_rx_descs_refill(struct emac_adapter *adpt,
 
 		curr_rxbuf->dma_addr =
 			dma_map_single(adpt->netdev->dev.parent, skb->data,
-				       curr_rxbuf->length, DMA_FROM_DEVICE);
+				       adpt->rxbuf_size, DMA_FROM_DEVICE);
+
 		ret = dma_mapping_error(adpt->netdev->dev.parent,
 					curr_rxbuf->dma_addr);
 		if (ret) {
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
