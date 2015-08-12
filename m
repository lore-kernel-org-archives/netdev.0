From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V1 Resend 05/10] drivers: net: Drop unlikely before IS_ERR(_OR_NULL)
Date: Wed, 12 Aug 2015 15:59:42 +0530
Message-ID: <be6452a07902fa6a50be0fa06af90dc172cc65fc.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Murali Karicheri <m-karicheri2@ti.com>,
	netdev@vger.kernel.org (open list:TI NETCP ETHERNET DRIVER),
	Wingman Kwok <w-kwok2@ti.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
is no need to do that again from its callers. Drop it.

Acked-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 drivers/net/ethernet/ti/netcp_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 1a5aca55ea9f..f7f6e442e94b 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1026,7 +1026,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 	}
 
 	desc = knav_pool_desc_get(netcp->tx_pool);
-	if (unlikely(IS_ERR_OR_NULL(desc))) {
+	if (IS_ERR_OR_NULL(desc)) {
 		dev_err(netcp->ndev_dev, "out of TX desc\n");
 		dma_unmap_single(dev, dma_addr, pkt_len, DMA_TO_DEVICE);
 		return NULL;
@@ -1059,7 +1059,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 		}
 
 		ndesc = knav_pool_desc_get(netcp->tx_pool);
-		if (unlikely(IS_ERR_OR_NULL(ndesc))) {
+		if (IS_ERR_OR_NULL(ndesc)) {
 			dev_err(netcp->ndev_dev, "out of TX desc for frags\n");
 			dma_unmap_page(dev, dma_addr, buf_len, DMA_TO_DEVICE);
 			goto free_descs;
-- 
2.4.0
