From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: insert a missing iounmap()
Date: Wed, 17 Sep 2003 15:01:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917150105.3a26e2a8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks.
--
~Randy


From: Leann Ogasawara <ogasawara@osdl.org>
Subject: [Kernel-janitors] [PATCH] insert missing iounmap()

Patch inserts a missing iounmap().


 linux-260-test5-kj-rddunlap/drivers/net/rcpci45.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN drivers/net/rcpci45.c~net_rcpci_iounmap drivers/net/rcpci45.c
--- linux-260-test5-kj/drivers/net/rcpci45.c~net_rcpci_iounmap	2003-09-10 16:47:04.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/rcpci45.c	2003-09-10 16:47:04.000000000 -0700
@@ -259,10 +259,12 @@ rcpci45_init_one (struct pci_dev *pdev, 
 	dev->set_config = &RCconfig;
 
 	if ((error = register_netdev(dev)))
-		goto err_out_free_region;
+		goto err_out_iounmap;
 
 	return 0;		/* success */
 
+err_out_iounmap:
+	iounmap((void *) dev->base_addr);
 err_out_free_region:
 	pci_release_regions (pdev);
 err_out_free_msgbuf:

_
