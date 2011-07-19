From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 01/10] bnx2x: use correct dma_sync function
Date: Tue, 19 Jul 2011 14:37:42 +0300
Message-ID: <1311075462.30287.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4807 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab1GSLuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index b05ce93..150147a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -676,7 +676,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			/* non TPA */
 			len = le16_to_cpu(cqe_fp->pkt_len);
 			pad = cqe_fp->placement_offset;
-			dma_sync_single_for_device(&bp->pdev->dev,
+			dma_sync_single_for_cpu(&bp->pdev->dev,
 					dma_unmap_addr(rx_buf, mapping),
 						       pad + RX_COPY_THRESH,
 						       DMA_FROM_DEVICE);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index ac02231..eda0f7b 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1752,7 +1752,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 		goto test_loopback_rx_exit;
 
 	rx_buf = &fp_rx->rx_buf_ring[RX_BD(fp_rx->rx_bd_cons)];
-	dma_sync_single_for_device(&bp->pdev->dev,
+	dma_sync_single_for_cpu(&bp->pdev->dev,
 				   dma_unmap_addr(rx_buf, mapping),
 				   fp_rx->rx_buf_size, DMA_FROM_DEVICE);
 	skb = rx_buf->skb;
-- 
1.7.2.2




