From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/4] atm: idt77252: Adjust ten checks for null pointers
Date: Sat, 5 Aug 2017 14:32:08 +0200
Message-ID: <f842b298-8963-d8d3-8370-1c061bb672e8@users.sourceforge.net>
References: <df946de6-8112-2a23-ec98-ac6418ca8486@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <df946de6-8112-2a23-ec98-ac6418ca8486@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 5 Aug 2017 14:04:42 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/idt77252.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index e26e36a934e9..184934e05193 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -643,7 +643,7 @@ alloc_scq(struct idt77252_dev *card, int class)
 		return NULL;
 	scq->base = dma_zalloc_coherent(&card->pcidev->dev, SCQ_SIZE,
 					&scq->paddr, GFP_KERNEL);
-	if (scq->base == NULL) {
+	if (!scq->base) {
 		kfree(scq);
 		return NULL;
 	}
@@ -973,7 +973,7 @@ init_rsq(struct idt77252_dev *card)
 
 	card->rsq.base = dma_zalloc_coherent(&card->pcidev->dev, RSQSIZE,
 					     &card->rsq.paddr, GFP_KERNEL);
-	if (card->rsq.base == NULL) {
+	if (!card->rsq.base) {
 		printk("%s: can't allocate RSQ.\n", card->name);
 		return -1;
 	}
@@ -1026,7 +1026,7 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 	}
 
 	skb = sb_pool_skb(card, le32_to_cpu(rsqe->word_2));
-	if (skb == NULL) {
+	if (!skb) {
 		printk("%s: NULL skb in %s, rsqe: %08x %08x %08x %08x\n",
 		       card->name, __func__,
 		       le32_to_cpu(rsqe->word_1), le32_to_cpu(rsqe->word_2),
@@ -1242,7 +1242,7 @@ idt77252_rx_raw(struct idt77252_dev *card)
 	struct vc_map	*vc;
 	struct sk_buff	*sb;
 
-	if (card->raw_cell_head == NULL) {
+	if (!card->raw_cell_head) {
 		u32 handle = le32_to_cpu(*(card->raw_cell_hnd + 1));
 		card->raw_cell_head = sb_pool_skb(card, handle);
 	}
@@ -1375,7 +1375,7 @@ init_tsq(struct idt77252_dev *card)
 
 	card->tsq.base = dma_alloc_coherent(&card->pcidev->dev, RSQSIZE,
 					    &card->tsq.paddr, GFP_KERNEL);
-	if (card->tsq.base == NULL) {
+	if (!card->tsq.base) {
 		printk("%s: can't allocate TSQ.\n", card->name);
 		return -1;
 	}
@@ -1601,7 +1601,7 @@ __fill_tst(struct idt77252_dev *card, struct vc_map *vc,
 
 	avail = card->tst_size - 2;
 	for (e = 0; e < avail; e++) {
-		if (card->soft_tst[e].vc == NULL)
+		if (!card->soft_tst[e].vc)
 			break;
 	}
 	if (e >= avail) {
@@ -1624,7 +1624,7 @@ __fill_tst(struct idt77252_dev *card, struct vc_map *vc,
 	 * Fill Soft TST.
 	 */
 	while (r > 0) {
-		if ((cl >= avail) && (card->soft_tst[e].vc == NULL)) {
+		if ((cl >= avail) && !card->soft_tst[e].vc) {
 			if (vc)
 				card->soft_tst[e].vc = vc;
 			else
@@ -1948,7 +1948,7 @@ idt77252_send_skb(struct atm_vcc *vcc, struct sk_buff *skb, int oam)
 	struct vc_map *vc = vcc->dev_data;
 	int err;
 
-	if (vc == NULL) {
+	if (!vc) {
 		printk("%s: NULL connection in send().\n", card->name);
 		atomic_inc(&vcc->stats->tx_err);
 		dev_kfree_skb(skb);
@@ -3429,12 +3429,12 @@ static int init_card(struct atm_dev *dev)
 		card->soft_tst[i].vc = NULL;
 	}
 
-	if (dev->phy == NULL) {
+	if (!dev->phy) {
 		printk("%s: No LT device defined.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
-	if (dev->phy->ioctl == NULL) {
+	if (!dev->phy->ioctl) {
 		printk("%s: LT had no IOCTL function defined.\n", card->name);
 		deinit_card(card);
 		return -1;
-- 
2.13.4
