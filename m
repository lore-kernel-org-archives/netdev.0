From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/9] chelsio: use SKB_WITH_OVERHEAD
Date: Thu, 3 May 2012 15:56:05 +0100
Message-ID: <1336056971-7839-3-git-send-email-ian.campbell@citrix.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43303 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939Ab2ECO7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:59:21 -0400
In-Reply-To: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb/sge.c  |    3 +--
 drivers/net/ethernet/chelsio/cxgb3/sge.c |    6 +++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 47a8435..52373db 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -599,8 +599,7 @@ static int alloc_rx_resources(struct sge *sge, struct sge_params *p)
 		sizeof(struct cpl_rx_data) +
 		sge->freelQ[!sge->jumbo_fl].dma_offset;
 
-		size = (16 * 1024) -
-		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	size = SKB_WITH_OVERHEAD(16 * 1024);
 
 	sge->freelQ[sge->jumbo_fl].rx_buffer_size = size;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index cfb60e1..b804470 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -3043,7 +3043,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->fl[1].buf_size = FL1_PG_CHUNK_SIZE;
 #else
 	q->fl[1].buf_size = is_offload(adapter) ?
-		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
+		SKB_WITH_OVERHEAD(16 * 1024) :
 		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
 #endif
 
@@ -3282,8 +3282,8 @@ void t3_sge_prep(struct adapter *adap, struct sge_params *p)
 {
 	int i;
 
-	p->max_pkt_size = (16 * 1024) - sizeof(struct cpl_rx_data) -
-	    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	p->max_pkt_size =
+		SKB_WITH_OVERHEAD((16*1024) - sizeof(struct cpl_rx_data));
 
 	for (i = 0; i < SGE_QSETS; ++i) {
 		struct qset_params *q = p->qset + i;
-- 
1.7.2.5
