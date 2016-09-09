From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ATM-iphase: Use kmalloc_array() in tx_init()
Date: Fri, 9 Sep 2016 20:42:16 +0200
Message-ID: <87a58007-c560-eb8d-b268-5a25452a8daf@users.sourceforge.net>
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
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 9 Sep 2016 20:40:16 +0200

* Multiplications for the size determination of memory allocations
  indicated that array data structures should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of data types by pointer dereferences
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/iphase.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 809dd1e..9d8807e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1975,7 +1975,9 @@ static int tx_init(struct atm_dev *dev)
 		buf_desc_ptr++;		  
 		tx_pkt_start += iadev->tx_buf_sz;  
 	}  
-        iadev->tx_buf = kmalloc(iadev->num_tx_desc*sizeof(struct cpcs_trailer_desc), GFP_KERNEL);
+	iadev->tx_buf = kmalloc_array(iadev->num_tx_desc,
+				      sizeof(*iadev->tx_buf),
+				      GFP_KERNEL);
         if (!iadev->tx_buf) {
             printk(KERN_ERR DEV_LABEL " couldn't get mem\n");
 	    goto err_free_dle;
@@ -1995,8 +1997,9 @@ static int tx_init(struct atm_dev *dev)
 						       sizeof(*cpcs),
 						       DMA_TO_DEVICE);
         }
-        iadev->desc_tbl = kmalloc(iadev->num_tx_desc *
-                                   sizeof(struct desc_tbl_t), GFP_KERNEL);
+	iadev->desc_tbl = kmalloc_array(iadev->num_tx_desc,
+					sizeof(*iadev->desc_tbl),
+					GFP_KERNEL);
 	if (!iadev->desc_tbl) {
 		printk(KERN_ERR DEV_LABEL " couldn't get mem\n");
 		goto err_free_all_tx_bufs;
@@ -2124,7 +2127,9 @@ static int tx_init(struct atm_dev *dev)
 	memset((caddr_t)(iadev->seg_ram+i),  0, iadev->num_vc*4);
 	vc = (struct main_vc *)iadev->MAIN_VC_TABLE_ADDR;  
 	evc = (struct ext_vc *)iadev->EXT_VC_TABLE_ADDR;  
-        iadev->testTable = kmalloc(sizeof(long)*iadev->num_vc, GFP_KERNEL); 
+	iadev->testTable = kmalloc_array(iadev->num_vc,
+					 sizeof(*iadev->testTable),
+					 GFP_KERNEL);
         if (!iadev->testTable) {
            printk("Get freepage  failed\n");
 	   goto err_free_desc_tbl;
-- 
2.10.0

