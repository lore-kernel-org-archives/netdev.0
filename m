From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 11/19] bnx2x: remove unused parameter in
 reuse_rx_skb()
Date: Wed, 6 Oct 2010 15:29:05 +0200
Message-ID: <1286371745.30552.44.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757383Ab0JFNkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    4 ++--
 drivers/net/bnx2x/bnx2x_cmn.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index cffa778..5b8c0b6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -595,7 +595,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				skb_reserve(new_skb, pad);
 				skb_put(new_skb, len);
 
-				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
+				bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
 
 				skb = new_skb;
 
@@ -614,7 +614,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				   "of alloc failure\n");
 				fp->eth_q_stats.rx_skb_alloc_failed++;
 reuse_rx:
-				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
+				bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
 				goto next_rx;
 			}
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 41d0a17..73ed5a6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -696,7 +696,7 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
  * so there is no need to check for dma_mapping_error().
  */
 static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
-			       struct sk_buff *skb, u16 cons, u16 prod)
+				      u16 cons, u16 prod)
 {
 	struct bnx2x *bp = fp->bp;
 	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
-- 
1.7.1




