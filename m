From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: faraday: ftmac100: Use BUG_ON instead of if condition
 followed by BUG.
Date: Thu, 26 Oct 2017 07:27:45 -0500
Message-ID: <20171026122745.GA9510@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Notice that in this particular case unlikely() is already being called
inside BUG_ON macro.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/faraday/ftmac100.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 66928a9..aecc765 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -402,6 +402,7 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	struct page *page;
 	dma_addr_t map;
 	int length;
+	bool ret;
 
 	rxdes = ftmac100_rx_locate_first_segment(priv);
 	if (!rxdes)
@@ -416,8 +417,8 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	 * It is impossible to get multi-segment packets
 	 * because we always provide big enough receive buffers.
 	 */
-	if (unlikely(!ftmac100_rxdes_last_segment(rxdes)))
-		BUG();
+	ret = ftmac100_rxdes_last_segment(rxdes);
+	BUG_ON(!ret);
 
 	/* start processing */
 	skb = netdev_alloc_skb_ip_align(netdev, 128);
-- 
2.7.4
