From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] dgrs: add missing iounmaps
Date: Mon, 5 Apr 2004 16:27:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405162753.7c0c5257.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[resend]


Insert missing iounmap's.

From: Leana Ogasawara <ogasawara@osdl.org>


---

 linux-265-kj1-rddunlap/drivers/net/dgrs.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletion(-)

diff -puN drivers/net/dgrs.c~dgrs_iounmap drivers/net/dgrs.c
--- linux-265-kj1/drivers/net/dgrs.c~dgrs_iounmap	2004-04-05 13:08:11.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/dgrs.c	2004-04-05 13:08:11.000000000 -0700
@@ -327,8 +327,10 @@ check_board_dma(struct net_device *dev0)
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
@@ -1020,6 +1022,8 @@ dgrs_download(struct net_device *dev0)
 		if (!is)
 		{
 			printk("%s: Illegal IRQ %d\n", dev0->name, dev0->irq);
+			iounmap(priv0->vmem);
+			priv0->vmem = NULL;
 			return -ENXIO;
 		}
 		OUTB(dev0->base_addr + ES4H_AS_31_24,
@@ -1101,6 +1105,8 @@ dgrs_download(struct net_device *dev0)
 	if (priv0->bcomm->bc_status < BC_RUN)
 	{
 		printk("%s: board not operating\n", dev0->name);
+		iounmap(priv0->vmem);
+		priv0->vmem = NULL;
 		return -ENXIO;
 	}
 

_


--
~Randy
"We have met the enemy and he is us."  -- Pogo (by Walt Kelly)
