From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: ec_bhf: Use module_pci_driver
Date: Tue, 7 Jul 2015 12:32:54 +0530
Message-ID: <20150707070254.GA18958@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dariusz Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use module_pci_driver for drivers whose init and exit functions
only register and unregister, respectively.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@a@
identifier f, x;
@@
-static f(...) { return pci_register_driver(&x); }

@b depends on a@
identifier e, a.x;
@@
-static e(...) { pci_unregister_driver(&x); }

@c depends on a && b@
identifier a.f;
declarer name module_init;
@@
-module_init(f);

@d depends on a && b && c@
identifier b.e, a.x;
declarer name module_exit;
declarer name module_pci_driver;
@@
-module_exit(e);
+module_pci_driver(x);

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/ec_bhf.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index d101750..f7b4248 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -604,19 +604,7 @@ static struct pci_driver pci_driver = {
 	.probe		= ec_bhf_probe,
 	.remove		= ec_bhf_remove,
 };
-
-static int __init ec_bhf_init(void)
-{
-	return pci_register_driver(&pci_driver);
-}
-
-static void __exit ec_bhf_exit(void)
-{
-	pci_unregister_driver(&pci_driver);
-}
-
-module_init(ec_bhf_init);
-module_exit(ec_bhf_exit);
+module_pci_driver(pci_driver);
 
 module_param(polling_frequency, long, S_IRUGO);
 MODULE_PARM_DESC(polling_frequency, "Polling timer frequency in ns");
-- 
1.9.1
