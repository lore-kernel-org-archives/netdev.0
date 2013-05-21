From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 12/19] net/ethernet/sgi/ioc3-eth: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:07 +0200
Message-ID: <1369177096-19674-12-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
        Ralf Baechle <ralf@linux-mips.org>,
        linux-mips@linux-mips.org (open list:IOC3 ETHERNET DRIVER),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ethernet/sgi/ioc3-eth.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7ed08c3..ffa7843 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1398,16 +1398,6 @@ static struct pci_driver ioc3_driver = {
 	.remove		= ioc3_remove_one,
 };
 
-static int __init ioc3_init_module(void)
-{
-	return pci_register_driver(&ioc3_driver);
-}
-
-static void __exit ioc3_cleanup_module(void)
-{
-	pci_unregister_driver(&ioc3_driver);
-}
-
 static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long data;
@@ -1677,9 +1667,7 @@ static void ioc3_set_multicast_list(struct net_device *dev)
 	netif_wake_queue(dev);			/* Let us get going again. */
 }
 
+module_pci_driver(ioc3_driver);
 MODULE_AUTHOR("Ralf Baechle <ralf@linux-mips.org>");
 MODULE_DESCRIPTION("SGI IOC3 Ethernet driver");
 MODULE_LICENSE("GPL");
-
-module_init(ioc3_init_module);
-module_exit(ioc3_cleanup_module);
-- 
1.8.1.5
