From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 1/3] net: mvpp2: fix TSO headers allocation and management
Date: Mon, 23 Oct 2017 15:24:29 +0200
Message-ID: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
Cc: Yan Markman <ymarkman@marvell.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yan Markman <ymarkman@marvell.com>

TSO headers are managed with txq index and therefore should be aligned
with the txq size, not with the aggregated txq size.

Fixes: 186cd4d4e414 ("net: mvpp2: software tso support")
Reported-by: Marc Zyngier <marc.zyngier@arm.com>
Signed-off-by: Yan Markman <ymarkman@marvell.com>
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 1a540c88c974..2898ac70b826 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5609,7 +5609,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 
 		txq_pcpu->tso_headers =
 			dma_alloc_coherent(port->dev->dev.parent,
-					   MVPP2_AGGR_TXQ_SIZE * TSO_HEADER_SIZE,
+					   txq_pcpu->size * TSO_HEADER_SIZE,
 					   &txq_pcpu->tso_headers_dma,
 					   GFP_KERNEL);
 		if (!txq_pcpu->tso_headers)
@@ -5623,7 +5623,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 		kfree(txq_pcpu->buffs);
 
 		dma_free_coherent(port->dev->dev.parent,
-				  MVPP2_AGGR_TXQ_SIZE * MVPP2_DESC_ALIGNED_SIZE,
+				  txq_pcpu->size * TSO_HEADER_SIZE,
 				  txq_pcpu->tso_headers,
 				  txq_pcpu->tso_headers_dma);
 	}
@@ -5647,7 +5647,7 @@ static void mvpp2_txq_deinit(struct mvpp2_port *port,
 		kfree(txq_pcpu->buffs);
 
 		dma_free_coherent(port->dev->dev.parent,
-				  MVPP2_AGGR_TXQ_SIZE * MVPP2_DESC_ALIGNED_SIZE,
+				  txq_pcpu->size * TSO_HEADER_SIZE,
 				  txq_pcpu->tso_headers,
 				  txq_pcpu->tso_headers_dma);
 	}
-- 
2.14.2
