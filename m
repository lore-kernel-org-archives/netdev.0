From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 04/25] net: mvneta: Adjust six checks for null pointers
Date: Mon, 17 Apr 2017 17:14:25 +0200
Message-ID: <6b0f9c85-0a3e-4f4f-9790-05436bb31d2d@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 16 Apr 2017 22:45:33 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 9c2ddd22a86f..6f436db8b01e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1107,7 +1107,7 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	q_map = 0;
 	for (queue = 0; queue < txq_number; queue++) {
 		struct mvneta_tx_queue *txq = &pp->txqs[queue];
-		if (txq->descs != NULL)
+		if (txq->descs)
 			q_map |= (1 << queue);
 	}
 	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
@@ -1116,7 +1116,7 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	for (queue = 0; queue < rxq_number; queue++) {
 		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
 
-		if (rxq->descs != NULL)
+		if (rxq->descs)
 			q_map |= (1 << queue);
 	}
 	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
@@ -2850,7 +2850,7 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	rxq->descs = dma_alloc_coherent(pp->dev->dev.parent,
 					rxq->size * MVNETA_DESC_ALIGNED_SIZE,
 					&rxq->descs_phys, GFP_KERNEL);
-	if (rxq->descs == NULL)
+	if (!rxq->descs)
 		return -ENOMEM;
 
 	rxq->last_desc = rxq->size - 1;
@@ -2920,7 +2920,7 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 	txq->descs = dma_alloc_coherent(pp->dev->dev.parent,
 					txq->size * MVNETA_DESC_ALIGNED_SIZE,
 					&txq->descs_phys, GFP_KERNEL);
-	if (txq->descs == NULL)
+	if (!txq->descs)
 		return -ENOMEM;
 
 	txq->last_desc = txq->size - 1;
@@ -2935,7 +2935,7 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 
 	txq->tx_skb = kmalloc_array(txq->size, sizeof(*txq->tx_skb),
 				    GFP_KERNEL);
-	if (txq->tx_skb == NULL) {
+	if (!txq->tx_skb) {
 		dma_free_coherent(pp->dev->dev.parent,
 				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
 				  txq->descs, txq->descs_phys);
@@ -2946,7 +2946,7 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 	txq->tso_hdrs = dma_alloc_coherent(pp->dev->dev.parent,
 					   txq->size * TSO_HEADER_SIZE,
 					   &txq->tso_hdrs_phys, GFP_KERNEL);
-	if (txq->tso_hdrs == NULL) {
+	if (!txq->tso_hdrs) {
 		kfree(txq->tx_skb);
 		dma_free_coherent(pp->dev->dev.parent,
 				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
-- 
2.12.2
