From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH 08/15] drivers: net: Drop unlikely before IS_ERR(_OR_NULL)
Date: Fri, 31 Jul 2015 14:08:28 +0530
Message-ID: <ceb569d147977a4138a7dd334fe7b9b0efdac8ac.1438331416.git.viresh.kumar@linaro.org>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Murali Karicheri <m-karicheri2@ti.com>,
	netdev@vger.kernel.org (open list:TI NETCP ETHERNET DRIVER),
	Wingman Kwok <w-kwok2@ti.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34296 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbbGaIjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 04:39:39 -0400
Received: by pdbbh15 with SMTP id bh15so38959931pdb.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 01:39:39 -0700 (PDT)
In-Reply-To: <cover.1438331416.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1438331416.git.viresh.kumar@linaro.org>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
is no need to do that again from its callers. Drop it.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 drivers/net/ethernet/ti/netcp_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index ec8ed30196f3..f685a19a3703 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1016,7 +1016,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 	}
 
 	desc = knav_pool_desc_get(netcp->tx_pool);
-	if (unlikely(IS_ERR_OR_NULL(desc))) {
+	if (IS_ERR_OR_NULL(desc)) {
 		dev_err(netcp->ndev_dev, "out of TX desc\n");
 		dma_unmap_single(dev, dma_addr, pkt_len, DMA_TO_DEVICE);
 		return NULL;
@@ -1049,7 +1049,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 		}
 
 		ndesc = knav_pool_desc_get(netcp->tx_pool);
-		if (unlikely(IS_ERR_OR_NULL(ndesc))) {
+		if (IS_ERR_OR_NULL(ndesc)) {
 			dev_err(netcp->ndev_dev, "out of TX desc for frags\n");
 			dma_unmap_page(dev, dma_addr, buf_len, DMA_TO_DEVICE);
 			goto free_descs;
-- 
2.4.0
