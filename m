From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] Bogus return status in drivers/net/tg3.c
Date: Fri, 19 Dec 2003 23:32:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219233231.A2420@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Apply on top of 2.6.0 + Jeff Garzik's 2.6.0-test11-bk5-netdrvr-exp2


The status variable is not set before branching to the error path.


 drivers/net/tg3.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff -puN drivers/net/tg3.c~trivial-tg3-fscked-return-status drivers/net/tg3.c
--- linux-2.6.0-vanilla/drivers/net/tg3.c~trivial-tg3-fscked-return-status	2003-12-19 23:21:55.000000000 +0100
+++ linux-2.6.0-vanilla-fr/drivers/net/tg3.c	2003-12-19 23:24:10.000000000 +0100
@@ -7533,13 +7533,16 @@ static int __devinit tg3_init_one(struct
 	if (pm_cap == 0) {
 		printk(KERN_ERR PFX "Cannot find PowerManagement capability, "
 		       "aborting.\n");
+		err = -EIO;
 		goto err_out_free_res;
 	}
 
 	/* Configure DMA attributes. */
-	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+	err = pci_set_dma_mask(pdev, 0xffffffffffffffffULL);
+	if (!err) {
 		pci_using_dac = 1;
-		if (pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL)) {
+		err = pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL);
+		if (err < 0) {
 			printk(KERN_ERR PFX "Unable to obtain 64 bit DMA "
 			       "for consistent allocations\n");
 			goto err_out_free_res;

_
