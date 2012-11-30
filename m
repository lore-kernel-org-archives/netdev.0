From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 17/17] solos-pci: remove list_vccs() debugging function
Date: Fri, 30 Nov 2012 00:35:36 +0000
Message-ID: <1354235736-26833-18-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37543 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab2K3Agn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:43 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <David.Woodhouse@intel.com>

No idea why we've gone so long dumping a list of VCCs with vci==0 on
every ->open() call...

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 41 -----------------------------------------
 1 file changed, 41 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index af19202..e59bcfd 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -165,7 +165,6 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 static uint32_t fpga_tx(struct solos_card *);
 static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
-static int list_vccs(int vci);
 static int atm_init(struct solos_card *, struct device *);
 static void atm_remove(struct solos_card *);
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
@@ -792,44 +791,6 @@ static struct atm_vcc *find_vcc(struct atm_dev *dev, short vpi, int vci)
 	return vcc;
 }
 
-static int list_vccs(int vci)
-{
-	struct hlist_head *head;
-	struct atm_vcc *vcc;
-	struct hlist_node *node;
-	struct sock *s;
-	int num_found = 0;
-	int i;
-
-	read_lock(&vcc_sklist_lock);
-	if (vci != 0){
-		head = &vcc_hash[vci & (VCC_HTABLE_SIZE -1)];
-		sk_for_each(s, node, head) {
-			num_found ++;
-			vcc = atm_sk(s);
-			printk(KERN_DEBUG "Device: %d Vpi: %d Vci: %d\n",
-			       vcc->dev->number,
-			       vcc->vpi,
-			       vcc->vci);
-		}
-	} else {
-		for(i = 0; i < VCC_HTABLE_SIZE; i++){
-			head = &vcc_hash[i];
-			sk_for_each(s, node, head) {
-				num_found ++;
-				vcc = atm_sk(s);
-				printk(KERN_DEBUG "Device: %d Vpi: %d Vci: %d\n",
-				       vcc->dev->number,
-				       vcc->vpi,
-				       vcc->vci);
-			}
-		}
-	}
-	read_unlock(&vcc_sklist_lock);
-	return num_found;
-}
-
-
 static int popen(struct atm_vcc *vcc)
 {
 	struct solos_card *card = vcc->dev->dev_data;
@@ -859,8 +820,6 @@ static int popen(struct atm_vcc *vcc)
 
 	set_bit(ATM_VF_ADDR, &vcc->flags);
 	set_bit(ATM_VF_READY, &vcc->flags);
-	list_vccs(0);
-
 
 	return 0;
 }
-- 
1.8.0
