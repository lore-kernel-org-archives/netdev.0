From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 14/19] bnx2x: use L1_CACHE_BYTES instead of
 magic number
Date: Wed, 6 Oct 2010 15:31:20 +0200
Message-ID: <1286371880.30552.52.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2439 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758907Ab0JFNkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 7ee9af0..da46309 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -358,7 +358,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 #endif
 
 		prefetch(skb);
-		prefetch(((char *)(skb)) + 128);
+		prefetch(((char *)(skb)) + L1_CACHE_BYTES);
 
 #ifdef BNX2X_STOP_ON_ERROR
 		if (pad + len > bp->rx_buf_size) {
@@ -561,7 +561,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 					dma_unmap_addr(rx_buf, mapping),
 						   pad + RX_COPY_THRESH,
 						   DMA_FROM_DEVICE);
-			prefetch(((char *)(skb)) + 128);
+			prefetch(((char *)(skb)) + L1_CACHE_BYTES);
 
 			/* is this an error packet? */
 			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
-- 
1.7.1




