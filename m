From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH[ via-ircc: fix exit section usage
Date: Thu, 6 Jan 2005 23:08:03 -0800
Message-ID: <20050106230803.00714c45.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix exit section usage, starting with this Error
from reference_discarded.pl (make buildcheck):
Error: ./drivers/net/irda/via-ircc.o .data refers to 000000f8 R_386_32          .exit.text

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/irda/via-ircc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff -Naurp ./drivers/net/irda/via-ircc.c~irda_via_devexit ./drivers/net/irda/via-ircc.c
--- ./drivers/net/irda/via-ircc.c~irda_via_devexit	2004-12-24 13:33:47.000000000 -0800
+++ ./drivers/net/irda/via-ircc.c	2005-01-06 21:18:49.742203456 -0800
@@ -83,7 +83,7 @@ static struct via_ircc_cb *dev_self[] = 
 
 /* Some prototypes */
 static int via_ircc_open(int i, chipio_t * info, unsigned int id);
-static int __exit via_ircc_close(struct via_ircc_cb *self);
+static int via_ircc_close(struct via_ircc_cb *self);
 static int via_ircc_dma_receive(struct via_ircc_cb *self);
 static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
 					 int iobase);
@@ -111,7 +111,7 @@ static void hwreset(struct via_ircc_cb *
 static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase);
 static int upload_rxdata(struct via_ircc_cb *self, int iobase);
 static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id);
-static void __exit via_remove_one (struct pci_dev *pdev);
+static void __devexit via_remove_one (struct pci_dev *pdev);
 
 /* FIXME : Should use udelay() instead, even if we are x86 only - Jean II */
 static void iodelay(int udelay)
@@ -140,7 +140,7 @@ static struct pci_driver via_driver = {
 	.name		= VIA_MODULE_NAME,
 	.id_table	= via_pci_tbl,
 	.probe		= via_init_one,
-	.remove		= via_remove_one,
+	.remove		= __devexit_p(via_remove_one),
 };
 
 
@@ -273,7 +273,7 @@ static int __devinit via_init_one (struc
  *    Close all configured chips
  *
  */
-static void __exit via_ircc_clean(void)
+static void via_ircc_clean(void)
 {
 	int i;
 
@@ -285,7 +285,7 @@ static void __exit via_ircc_clean(void)
 	}
 }
 
-static void __exit via_remove_one (struct pci_dev *pdev)
+static void __devexit via_remove_one (struct pci_dev *pdev)
 {
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
@@ -468,7 +468,7 @@ static __devinit int via_ircc_open(int i
  *    Close driver instance
  *
  */
-static int __exit via_ircc_close(struct via_ircc_cb *self)
+static int via_ircc_close(struct via_ircc_cb *self)
 {
 	int iobase;
 

---
