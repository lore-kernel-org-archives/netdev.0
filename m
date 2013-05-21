From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 07/19] net/ethernet/toshiba/tc35815: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:42:12 +0200
Message-ID: <1369176146-19383-7-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ethernet/toshiba/tc35815.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index fe25609..a971b9c 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -2209,18 +2209,6 @@ MODULE_PARM_DESC(speed, "0:auto, 10:10Mbps, 100:100Mbps");
 module_param_named(duplex, options.duplex, int, 0);
 MODULE_PARM_DESC(duplex, "0:auto, 1:half, 2:full");
 
-static int __init tc35815_init_module(void)
-{
-	return pci_register_driver(&tc35815_pci_driver);
-}
-
-static void __exit tc35815_cleanup_module(void)
-{
-	pci_unregister_driver(&tc35815_pci_driver);
-}
-
-module_init(tc35815_init_module);
-module_exit(tc35815_cleanup_module);
-
+module_pci_driver(tc35815_pci_driver);
 MODULE_DESCRIPTION("TOSHIBA TC35815 PCI 10M/100M Ethernet driver");
 MODULE_LICENSE("GPL");
-- 
1.8.1.5
