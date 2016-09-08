From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ATM-ENI: Use kmalloc_array() in eni_start()
Date: Thu, 8 Sep 2016 14:40:06 +0200
Message-ID: <d8468294-dff0-f34c-bf16-bb04435d465c@users.sourceforge.net>
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
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 8 Sep 2016 14:20:17 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/eni.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 6339efd..f2aaf9e 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1845,8 +1845,9 @@ static int eni_start(struct atm_dev *dev)
 	/* initialize memory management */
 	buffer_mem = eni_dev->mem - (buf - eni_dev->ram);
 	eni_dev->free_list_size = buffer_mem/MID_MIN_BUF_SIZE/2;
-	eni_dev->free_list = kmalloc(
-	    sizeof(struct eni_free)*(eni_dev->free_list_size+1),GFP_KERNEL);
+	eni_dev->free_list = kmalloc_array(eni_dev->free_list_size + 1,
+					   sizeof(*eni_dev->free_list),
+					   GFP_KERNEL);
 	if (!eni_dev->free_list) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): couldn't get free page\n",
 		    dev->number);
-- 
2.10.0
