From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] dgrs: add iounmap()s to failure paths
Date: Sat, 24 Jan 2004 22:32:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124223222.52a97b25.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.current.

Thanks,
--
~Randy


From: Leann Ogasawara <ogasawara@osdl.org>


Hi All,

Insert missing iounmap's.  You know the drill, feedback wanted.

diffed against 2.6.1

Leann

===== drivers/net/dgrs.c 1.22 vs edited =====

diff -puN drivers/net/dgrs.c~dgrs_iounmap drivers/net/dgrs.c

diff -puN drivers/net/dgrs.c~dgrs_iounmap drivers/net/dgrs.c


 linux-262-rc1-bk1-rddunlap/drivers/net/dgrs.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/dgrs.c~dgrs_iounmap drivers/net/dgrs.c
--- linux-262-rc1-bk1/drivers/net/dgrs.c~dgrs_iounmap	2004-01-23 15:49:58.000000000 -0800
+++ linux-262-rc1-bk1-rddunlap/drivers/net/dgrs.c	2004-01-23 15:49:58.000000000 -0800
@@ -322,8 +322,10 @@ check_board_dma(struct net_device *dev0)
 	 */
 	priv0->vplxdma[PLX_DMA0_MODE/4] = 0xFFFFFFFF;
 	x = priv0->vplxdma[PLX_DMA0_MODE/4];
-	if (x != 0x00001FFF)
+	if (x != 0x00001FFF) {
+		iounmap((void *)priv0->vplxdma);
 		return (0);
+	}
 
 	return (1);
 }
@@ -1015,6 +1017,8 @@ dgrs_download(struct net_device *dev0)
 		if (!is)
 		{
 			printk("%s: Illegal IRQ %d\n", dev0->name, dev0->irq);
+			iounmap(priv0->vmem);
+			priv0->vmem = NULL;
 			return -ENXIO;
 		}
 		OUTB(dev0->base_addr + ES4H_AS_31_24,
@@ -1096,6 +1100,8 @@ dgrs_download(struct net_device *dev0)
 	if (priv0->bcomm->bc_status < BC_RUN)
 	{
 		printk("%s: board not operating\n", dev0->name);
+		iounmap(priv0->vmem);
+		priv0->vmem = NULL;
 		return -ENXIO;
 	}
 

_
