From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/4] atm: idt77252: Improve seven size determinations
Date: Sat, 5 Aug 2017 14:30:21 +0200
Message-ID: <39f09a7c-b6a6-9694-133f-237fba64a2dd@users.sourceforge.net>
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
Date: Sat, 5 Aug 2017 13:51:04 +0200

Replace the specification of data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/idt77252.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 434dc4ee5f15..e26e36a934e9 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -638,7 +638,7 @@ alloc_scq(struct idt77252_dev *card, int class)
 {
 	struct scq_info *scq;
 
-	scq = kzalloc(sizeof(struct scq_info), GFP_KERNEL);
+	scq = kzalloc(sizeof(*scq), GFP_KERNEL);
 	if (!scq)
 		return NULL;
 	scq->base = dma_zalloc_coherent(&card->pcidev->dev, SCQ_SIZE,
@@ -2119,7 +2119,7 @@ idt77252_init_est(struct vc_map *vc, int pcr)
 {
 	struct rate_estimator *est;
 
-	est = kzalloc(sizeof(struct rate_estimator), GFP_KERNEL);
+	est = kzalloc(sizeof(*est), GFP_KERNEL);
 	if (!est)
 		return NULL;
 	est->maxcps = pcr < 0 ? -pcr : pcr;
@@ -2422,7 +2422,8 @@ idt77252_open(struct atm_vcc *vcc)
 
 	index = VPCI2VC(card, vpi, vci);
 	if (!card->vcs[index]) {
-		card->vcs[index] = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
+		card->vcs[index] = kzalloc(sizeof(*card->vcs[index]),
+					   GFP_KERNEL);
 		if (!card->vcs[index]) {
 			mutex_unlock(&card->mutex);
 			return -ENOMEM;
@@ -2612,8 +2613,7 @@ idt77252_change_qos(struct atm_vcc *vcc, struct atm_qos *qos, int flags)
 			goto out;
 	}
 
-	memcpy(&vcc->qos, qos, sizeof(struct atm_qos));
-
+	memcpy(&vcc->qos, qos, sizeof(*qos));
 	set_bit(ATM_VF_HASQOS, &vcc->flags);
 
 out:
@@ -2851,8 +2851,7 @@ open_card_oam(struct idt77252_dev *card)
 	for (vpi = 0; vpi < (1 << card->vpibits); vpi++) {
 		for (vci = 3; vci < 5; vci++) {
 			index = VPCI2VC(card, vpi, vci);
-
-			vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
+			vc = kzalloc(sizeof(*vc), GFP_KERNEL);
 			if (!vc)
 				return -ENOMEM;
 
@@ -2918,7 +2917,7 @@ open_card_ubr0(struct idt77252_dev *card)
 {
 	struct vc_map *vc;
 
-	vc = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
+	vc = kzalloc(sizeof(*vc), GFP_KERNEL);
 	if (!vc)
 		return -ENOMEM;
 
@@ -3605,7 +3604,7 @@ static int idt77252_init_one(struct pci_dev *pcidev,
 		return err;
 	}
 
-	card = kzalloc(sizeof(struct idt77252_dev), GFP_KERNEL);
+	card = kzalloc(sizeof(*card), GFP_KERNEL);
 	if (!card) {
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
-- 
2.13.4
