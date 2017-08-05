From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/4] atm: idt77252: Adjust four function calls together with a
 variable assignment
Date: Sat, 5 Aug 2017 14:26:45 +0200
Message-ID: <c03d54ed-7c1d-351b-3e84-30cc4af38c5f@users.sourceforge.net>
References: <df946de6-8112-2a23-ec98-ac6418ca8486@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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
Date: Fri, 4 Aug 2017 22:20:08 +0200

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/idt77252.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index b7a168c46692..6a051f5909d0 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1070,7 +1070,8 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 
 		cell = skb->data;
 		for (i = (stat & SAR_RSQE_CELLCNT); i; i--) {
-			if ((sb = dev_alloc_skb(64)) == NULL) {
+			sb = dev_alloc_skb(64);
+			if (!sb) {
 				printk("%s: Can't allocate buffers for aal0.\n",
 				       card->name);
 				atomic_add(i, &vcc->stats->rx_drop);
@@ -1304,7 +1305,8 @@ idt77252_rx_raw(struct idt77252_dev *card)
 			goto drop;
 		}
 	
-		if ((sb = dev_alloc_skb(64)) == NULL) {
+		sb = dev_alloc_skb(64);
+		if (!sb) {
 			printk("%s: Can't allocate buffers for AAL0.\n",
 			       card->name);
 			atomic_inc(&vcc->stats->rx_err);
@@ -3600,13 +3602,14 @@ static int idt77252_init_one(struct pci_dev *pcidev,
 	struct atm_dev *dev;
 	int i, err;
 
-
-	if ((err = pci_enable_device(pcidev))) {
+	err = pci_enable_device(pcidev);
+	if (err) {
 		printk("idt77252: can't enable PCI device at %s\n", pci_name(pcidev));
 		return err;
 	}
 
-	if ((err = dma_set_mask_and_coherent(&pcidev->dev, DMA_BIT_MASK(32)))) {
+	err = dma_set_mask_and_coherent(&pcidev->dev, DMA_BIT_MASK(32));
+	if (err) {
 		printk("idt77252: can't enable DMA for PCI device at %s\n", pci_name(pcidev));
 		return err;
 	}
-- 
2.13.4
