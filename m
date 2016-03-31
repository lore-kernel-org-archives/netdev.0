From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v2] net: mvneta: replace MVNETA_CPU_D_CACHE_LINE_SIZE with cache_line_size
Date: Thu, 31 Mar 2016 16:54:14 +0800
Message-ID: <1459414454-6095-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <mw@semihalf.com>,
	<gregory.clement@free-electrons.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mvneta is also used in some Marvell berlin family SoCs which may
have different cacheline size. Replace the MVNETA_CPU_D_CACHE_LINE_SIZE
usage with cache_line_size().

And since dma_alloc_coherent() is always cacheline size aligned, so
remove the align checks.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
Since v1:
 - use cache_line_size() suggested by Marcin

 drivers/net/ethernet/marvell/mvneta.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 577f7ca..b1db000 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -260,7 +260,6 @@
 
 #define MVNETA_VLAN_TAG_LEN             4
 
-#define MVNETA_CPU_D_CACHE_LINE_SIZE    32
 #define MVNETA_TX_CSUM_DEF_SIZE		1600
 #define MVNETA_TX_CSUM_MAX_SIZE		9800
 #define MVNETA_ACC_MODE_EXT1		1
@@ -300,7 +299,7 @@
 #define MVNETA_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
 	      ETH_HLEN + ETH_FCS_LEN,			     \
-	      MVNETA_CPU_D_CACHE_LINE_SIZE)
+	      cache_line_size())
 
 #define IS_TSO_HEADER(txq, addr) \
 	((addr >= txq->tso_hdrs_phys) && \
@@ -2764,9 +2763,6 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	if (rxq->descs == NULL)
 		return -ENOMEM;
 
-	BUG_ON(rxq->descs !=
-	       PTR_ALIGN(rxq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));
-
 	rxq->last_desc = rxq->size - 1;
 
 	/* Set Rx descriptors queue starting address */
@@ -2837,10 +2833,6 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 	if (txq->descs == NULL)
 		return -ENOMEM;
 
-	/* Make sure descriptor address is cache line size aligned  */
-	BUG_ON(txq->descs !=
-	       PTR_ALIGN(txq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));
-
 	txq->last_desc = txq->size - 1;
 
 	/* Set maximum bandwidth for enabled TXQs */
-- 
2.8.0.rc3
