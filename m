From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net] dwc_eth_qos: Fix dma address for multi-fragment skbs
Date: Tue, 12 Jan 2016 15:28:13 +0100
Message-ID: <1452608893-19126-1-git-send-email-larper@axis.com>
Cc: Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The offset inside the fragment was not used for the dma address and
silent data corruption resulted because TSO makes the checksum match.

Fixes: 077742dac2c7 ("dwc_eth_qos: Add support for Synopsys DWC Ethernet QoS")
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 9066d7a..f96c6b3 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2107,7 +2107,7 @@ static int dwceqos_tx_frags(struct sk_buff *skb, struct net_local *lp,
 			dd = &lp->tx_descs[lp->tx_next];
 
 			/* Set DMA Descriptor fields */
-			dd->des0 = dma_handle;
+			dd->des0 = dma_handle + consumed_size;
 			dd->des1 = 0;
 			dd->des2 = dma_size;
 
-- 
2.1.4
