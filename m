From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] ATM-ForeRunnerHE: Use kmalloc_array() in he_init_group()
Date: Thu, 8 Sep 2016 15:50:05 +0200
Message-ID: <edd03d91-0aff-73ed-cb04-c5851ac90dca@users.sourceforge.net>
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
Date: Thu, 8 Sep 2016 15:43:37 +0200

* Multiplications for the size determination of memory allocations
  indicated that array data structures should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of data types by pointer dereferences
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/he.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 0f5cb37..31b513a 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -779,8 +779,9 @@ static int he_init_group(struct he_dev *he_dev, int group)
 		  G0_RBPS_BS + (group * 32));
 
 	/* bitmap table */
-	he_dev->rbpl_table = kmalloc(BITS_TO_LONGS(RBPL_TABLE_SIZE)
-				     * sizeof(unsigned long), GFP_KERNEL);
+	he_dev->rbpl_table = kmalloc_array(BITS_TO_LONGS(RBPL_TABLE_SIZE),
+					   sizeof(*he_dev->rbpl_table),
+					   GFP_KERNEL);
 	if (!he_dev->rbpl_table) {
 		hprintk("unable to allocate rbpl bitmap table\n");
 		return -ENOMEM;
@@ -788,8 +789,9 @@ static int he_init_group(struct he_dev *he_dev, int group)
 	bitmap_zero(he_dev->rbpl_table, RBPL_TABLE_SIZE);
 
 	/* rbpl_virt 64-bit pointers */
-	he_dev->rbpl_virt = kmalloc(RBPL_TABLE_SIZE
-				    * sizeof(struct he_buff *), GFP_KERNEL);
+	he_dev->rbpl_virt = kmalloc_array(RBPL_TABLE_SIZE,
+					  sizeof(*he_dev->rbpl_virt),
+					  GFP_KERNEL);
 	if (!he_dev->rbpl_virt) {
 		hprintk("unable to allocate rbpl virt table\n");
 		goto out_free_rbpl_table;
-- 
2.10.0
