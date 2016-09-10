From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] ATM-nicstar: Improve another size determination in
 get_scq()
Date: Sat, 10 Sep 2016 09:18:46 +0200
Message-ID: <0bd4a38e-cd33-ecda-ed3a-73f743ed46e2@users.sourceforge.net>
References: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Paolo Bonzini <pbonzini@redhat.com>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 08:18:10 +0200

Replace the specification of a data structure by a pointer dereference
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 50dec13..96062e1 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -862,7 +862,7 @@ static scq_info *get_scq(ns_dev *card, int size, u32 scd)
 	if (size != VBR_SCQSIZE && size != CBR_SCQSIZE)
 		return NULL;
 
-	scq = kmalloc(sizeof(scq_info), GFP_KERNEL);
+	scq = kmalloc(sizeof(*scq), GFP_KERNEL);
 	if (!scq)
 		return NULL;
         scq->org = dma_alloc_coherent(&card->pcidev->dev,
-- 
2.10.0

