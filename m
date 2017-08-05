From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/4] atm: idt77252: Delete an error message for a failed
 memory allocation in seven functions
Date: Sat, 5 Aug 2017 14:28:20 +0200
Message-ID: <845a4e7c-fccc-a81b-cff5-3962e3cac155@users.sourceforge.net>
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
Date: Sat, 5 Aug 2017 12:45:34 +0200

Omit an extra message for a memory allocation failure in these functions.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/idt77252.c | 18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 6a051f5909d0..434dc4ee5f15 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -1307,8 +1307,6 @@ idt77252_rx_raw(struct idt77252_dev *card)
 	
 		sb = dev_alloc_skb(64);
 		if (!sb) {
-			printk("%s: Can't allocate buffers for AAL0.\n",
-			       card->name);
 			atomic_inc(&vcc->stats->rx_err);
 			goto drop;
 		}
@@ -2007,7 +2005,6 @@ idt77252_send_oam(struct atm_vcc *vcc, void *cell, int flags)
 
 	skb = dev_alloc_skb(64);
 	if (!skb) {
-		printk("%s: Out of memory in send_oam().\n", card->name);
 		atomic_inc(&vcc->stats->tx_err);
 		return -ENOMEM;
 	}
@@ -2427,7 +2424,6 @@ idt77252_open(struct atm_vcc *vcc)
 	if (!card->vcs[index]) {
 		card->vcs[index] = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
 		if (!card->vcs[index]) {
-			printk("%s: can't alloc vc in open()\n", card->name);
 			mutex_unlock(&card->mutex);
 			return -ENOMEM;
 		}
@@ -2857,10 +2853,9 @@ open_card_oam(struct idt77252_dev *card)
 			index = VPCI2VC(card, vpi, vci);
 
 			vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
-			if (!vc) {
-				printk("%s: can't alloc vc\n", card->name);
+			if (!vc)
 				return -ENOMEM;
-			}
+
 			vc->index = index;
 			card->vcs[index] = vc;
 
@@ -2924,10 +2919,9 @@ open_card_ubr0(struct idt77252_dev *card)
 	struct vc_map *vc;
 
 	vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
-	if (!vc) {
-		printk("%s: can't alloc vc\n", card->name);
+	if (!vc)
 		return -ENOMEM;
-	}
+
 	card->vcs[0] = vc;
 	vc->class = SCHED_UBR0;
 
@@ -3410,7 +3404,6 @@ static int init_card(struct atm_dev *dev)
 	IPRINTK("%s: allocate %d byte for VC map.\n", card->name, size);
 	card->vcs = vzalloc(size);
 	if (!card->vcs) {
-		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
@@ -3420,7 +3413,6 @@ static int init_card(struct atm_dev *dev)
 	        card->name, size);
 	card->scd2vc = vzalloc(size);
 	if (!card->scd2vc) {
-		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
@@ -3430,7 +3422,6 @@ static int init_card(struct atm_dev *dev)
 		card->name, size);
 	card->soft_tst = vmalloc(size);
 	if (!card->soft_tst) {
-		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
 		return -1;
 	}
@@ -3616,7 +3607,6 @@ static int idt77252_init_one(struct pci_dev *pcidev,
 
 	card = kzalloc(sizeof(struct idt77252_dev), GFP_KERNEL);
 	if (!card) {
-		printk("idt77252-%d: can't allocate private data\n", index);
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
-- 
2.13.4
