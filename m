From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] ATM-nicstar: Refactor a kmalloc() call in ns_init_card()
Date: Sat, 10 Sep 2016 09:20:30 +0200
Message-ID: <99cb1cdf-f2ab-f703-d214-cc0cc26c2668@users.sourceforge.net>
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
Date: Sat, 10 Sep 2016 08:48:17 +0200

* The script "checkpatch.pl" can point out that assignments should usually
  not be performed within condition checks.
  Thus move an assignment for a local variable to a separate statement
  in this function.

* Replace the specification of a data structure by a pointer dereference
  as the parameter for the operator "sizeof" to make the corresponding size
  determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/nicstar.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index ef977bf..04f5781 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -370,7 +370,8 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 		return error;
         }
 
-	if ((card = kmalloc(sizeof(ns_dev), GFP_KERNEL)) == NULL) {
+	card = kmalloc(sizeof(*card), GFP_KERNEL);
+	if (!card) {
 		printk
 		    ("nicstar%d: can't allocate memory for device structure.\n",
 		     i);
-- 
2.10.0
