From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] ATM-nicstar: Use kmalloc_array() in get_scq()
Date: Sat, 10 Sep 2016 09:17:48 +0200
Message-ID: <698e4922-e671-f60f-4599-ad4d7613c808@users.sourceforge.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe480e1f-285a-bb98-3550-b4fa354f8174@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 08:02:06 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data type by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 700ed15..50dec13 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -871,8 +871,9 @@ static scq_info *get_scq(ns_dev *card, int size, u32 scd)
 		kfree(scq);
 		return NULL;
 	}
-	scq->skb = kmalloc(sizeof(struct sk_buff *) *
-			   (size / NS_SCQE_SIZE), GFP_KERNEL);
+	scq->skb = kmalloc_array(size / NS_SCQE_SIZE,
+				 sizeof(*scq->skb),
+				 GFP_KERNEL);
 	if (!scq->skb) {
 		dma_free_coherent(&card->pcidev->dev,
 				  2 * size, scq->org, scq->dma);
-- 
2.10.0
