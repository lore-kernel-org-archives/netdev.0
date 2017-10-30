From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 5/6] net: mvpp2: use the aggr txq size define everywhere
Date: Mon, 30 Oct 2017 11:23:32 +0100
Message-ID: <20171030102333.30781-6-antoine.tenart@free-electrons.com>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cosmetic patch using the MVPP2_AGGR_TXQ_SIZE everywhere instead of the
size field of aggr_txq, as the size never change and is always equal to
the MVPP2_AGGR_TXQ_SIZE define.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8dc6bfbd5d0a..4b8c727ffea9 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5055,7 +5055,7 @@ static void mvpp2_aggr_txq_pend_desc_add(struct mvpp2_port *port, int pending)
 static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
 				     struct mvpp2_tx_queue *aggr_txq, int num)
 {
-	if ((aggr_txq->count + num) > aggr_txq->size) {
+	if ((aggr_txq->count + num) > MVPP2_AGGR_TXQ_SIZE) {
 		/* Update number of occupied aggregated Tx descriptors */
 		int cpu = smp_processor_id();
 		u32 val = mvpp2_read(priv, MVPP2_AGGR_TXQ_STATUS_REG(cpu));
@@ -5063,7 +5063,7 @@ static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
 		aggr_txq->count = val & MVPP2_AGGR_TXQ_PENDING_MASK;
 	}
 
-	if ((aggr_txq->count + num) > aggr_txq->size)
+	if ((aggr_txq->count + num) > MVPP2_AGGR_TXQ_SIZE)
 		return -ENOMEM;
 
 	return 0;
@@ -5447,7 +5447,7 @@ static int mvpp2_aggr_txq_init(struct platform_device *pdev,
 	if (!aggr_txq->descs)
 		return -ENOMEM;
 
-	aggr_txq->last_desc = aggr_txq->size - 1;
+	aggr_txq->last_desc = MVPP2_AGGR_TXQ_SIZE - 1;
 
 	/* Aggr TXQ no reset WA */
 	aggr_txq->next_desc_to_proc = mvpp2_read(priv,
-- 
2.14.3
