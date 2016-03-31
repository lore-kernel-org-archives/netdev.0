From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v2] net: mvpp2: replace MVPP2_CPU_D_CACHE_LINE_SIZE with cache_line_size
Date: Thu, 31 Mar 2016 17:03:45 +0800
Message-ID: <1459415025-6342-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <davem@davemloft.net>, <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mvpp2 ip maybe used in SoCs which may have have different cacheline
size. Replace the MVPP2_CPU_D_CACHE_LINE_SIZE with cache_line_size.

And since dma_alloc_coherent() is always cacheline size aligned, so
remove the align checks.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
Since v1:
 - use cache_line_size() suggested by Marcin

 drivers/net/ethernet/marvell/mvpp2.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index e9aa8d9..868a957 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -321,7 +321,6 @@
 /* Lbtd 802.3 type */
 #define MVPP2_IP_LBDT_TYPE		0xfffa
 
-#define MVPP2_CPU_D_CACHE_LINE_SIZE	32
 #define MVPP2_TX_CSUM_MAX_SIZE		9800
 
 /* Timeout constants */
@@ -377,7 +376,7 @@
 
 #define MVPP2_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVPP2_MH_SIZE + MVPP2_VLAN_TAG_LEN + \
-	      ETH_HLEN + ETH_FCS_LEN, MVPP2_CPU_D_CACHE_LINE_SIZE)
+	      ETH_HLEN + ETH_FCS_LEN, cache_line_size())
 
 #define MVPP2_RX_BUF_SIZE(pkt_size)	((pkt_size) + NET_SKB_PAD)
 #define MVPP2_RX_TOTAL_SIZE(buf_size)	((buf_size) + MVPP2_SKB_SHINFO_SIZE)
@@ -4493,10 +4492,6 @@ static int mvpp2_aggr_txq_init(struct platform_device *pdev,
 	if (!aggr_txq->descs)
 		return -ENOMEM;
 
-	/* Make sure descriptor address is cache line size aligned  */
-	BUG_ON(aggr_txq->descs !=
-	       PTR_ALIGN(aggr_txq->descs, MVPP2_CPU_D_CACHE_LINE_SIZE));
-
 	aggr_txq->last_desc = aggr_txq->size - 1;
 
 	/* Aggr TXQ no reset WA */
@@ -4526,9 +4521,6 @@ static int mvpp2_rxq_init(struct mvpp2_port *port,
 	if (!rxq->descs)
 		return -ENOMEM;
 
-	BUG_ON(rxq->descs !=
-	       PTR_ALIGN(rxq->descs, MVPP2_CPU_D_CACHE_LINE_SIZE));
-
 	rxq->last_desc = rxq->size - 1;
 
 	/* Zero occupied and non-occupied counters - direct access */
@@ -4616,10 +4608,6 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	if (!txq->descs)
 		return -ENOMEM;
 
-	/* Make sure descriptor address is cache line size aligned  */
-	BUG_ON(txq->descs !=
-	       PTR_ALIGN(txq->descs, MVPP2_CPU_D_CACHE_LINE_SIZE));
-
 	txq->last_desc = txq->size - 1;
 
 	/* Set Tx descriptors queue starting address - indirect access */
-- 
2.8.0.rc3
