From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 9/9] bnx2x: Get gso_segs from FW
Date: Mon, 18 Feb 2013 10:16:38 +0200
Message-ID: <1361175398-12888-10-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2379 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757459Ab3BRJVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:37 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 525c2b5..dc8d135 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -451,7 +451,8 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
  * Compute number of aggregated segments, and gso_type.
  */
 static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
-				 u16 len_on_bd, unsigned int pkt_len)
+				 u16 len_on_bd, unsigned int pkt_len,
+				 u16 num_of_coalesced_segs)
 {
 	/* TPA aggregation won't have either IP options or TCP options
 	 * other than timestamp or IPv6 extension headers.
@@ -480,8 +481,7 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
 	/* tcp_gro_complete() will copy NAPI_GRO_CB(skb)->count
 	 * to skb_shinfo(skb)->gso_segs
 	 */
-	NAPI_GRO_CB(skb)->count = DIV_ROUND_UP(pkt_len - hdrs_len,
-					       skb_shinfo(skb)->gso_size);
+	NAPI_GRO_CB(skb)->count = num_of_coalesced_segs;
 }
 
 static int bnx2x_alloc_rx_sge(struct bnx2x *bp,
@@ -537,7 +537,8 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	/* This is needed in order to enable forwarding support */
 	if (frag_size)
 		bnx2x_set_gro_params(skb, tpa_info->parsing_flags, len_on_bd,
-				     le16_to_cpu(cqe->pkt_len));
+				     le16_to_cpu(cqe->pkt_len),
+				     le16_to_cpu(cqe->num_of_coalesced_segs));
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (pages > min_t(u32, 8, MAX_SKB_FRAGS) * SGE_PAGES) {
-- 
1.7.9.GIT
