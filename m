From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: ns83820 error handling
Date: Wed, 17 Sep 2003 14:58:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917145841.5527e046.rddunlap@osdl.org>
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
Acked by bcrl.

Thanks.
--
~Randy


Subject: Re: [Kernel-janitors] [PATCH] insert missing free_irq and fix 	cleanup path
From: Leann Ogasawara <ogasawara@osdl.org>

On Thu, 2003-09-04 at 13:17, Benjamin LaHaise wrote:
> The if()s before free are redundant, turf them and it's good.


 linux-260-test5-kj-rddunlap/drivers/net/ns83820.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff -puN drivers/net/ns83820.c~net_ns83820_err_handling drivers/net/ns83820.c
--- linux-260-test5-kj/drivers/net/ns83820.c~net_ns83820_err_handling	2003-09-10 16:46:45.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/ns83820.c	2003-09-10 16:46:45.000000000 -0700
@@ -1833,13 +1833,13 @@ static int __devinit ns83820_init_one(st
 	if (err) {
 		printk(KERN_INFO "ns83820: unable to register irq %d\n",
 			pci_dev->irq);
-		goto out_unmap;
+		goto out_disable;
 	}
 
 	err = register_netdev(&dev->net_dev);
 	if (err) {
 		printk(KERN_INFO "ns83820: unable to register netdev: %d\n", err);
-		goto out_unmap;
+		goto out_free_irq;
 	}
 
 	printk("%s: ns83820.c: 0x22c: %08x, subsystem: %04x:%04x\n",
@@ -2025,9 +2025,11 @@ static int __devinit ns83820_init_one(st
 
 	return 0;
 
-out_unmap:
-	iounmap(dev->base);
+out_free_irq:
+	free_irq(pci_dev->irq, dev);
 out_disable:
+	if (dev->base)
+		iounmap(dev->base);
 	pci_free_consistent(pci_dev, 4 * DESC_SIZE * NR_TX_DESC, dev->tx_descs, dev->tx_phy_descs);
 	pci_free_consistent(pci_dev, 4 * DESC_SIZE * NR_RX_DESC, dev->rx_info.descs, dev->rx_info.phy_descs);
 	pci_disable_device(pci_dev);

_
