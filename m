From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (addendum) sk98: elimnate AllocFlag
Date: Fri, 19 Nov 2004 11:52:33 -0800
Message-ID: <20041119115233.0a41354f@zqx3.pdx.osdl.net>
References: <20041115163616.17dfe933@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115163616.17dfe933@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't need AllocFlag in device structure since FreeResources only
called in case where allocation was done.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-19 11:49:15 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-19 11:49:15 -08:00
@@ -316,25 +316,13 @@
  */
 static void FreeResources(struct net_device *dev)
 {
-SK_U32 AllocFlag;
-DEV_NET		*pNet;
-SK_AC		*pAC;
-
-	pNet = netdev_priv(dev);
-	pAC = pNet->pAC;
-	AllocFlag = pAC->AllocFlag;
-	if (pAC->PciDev) {
-		pci_release_regions(pAC->PciDev);
-	}
-	if (AllocFlag & SK_ALLOC_IRQ) {
-		free_irq(dev->irq, dev);
-	}
-	if (pAC->IoBase) {
-		iounmap(pAC->IoBase);
-	}
-	if (pAC->pDescrMem) {
-		BoardFreeMem(pAC);
-	}
+	DEV_NET		*pNet = netdev_priv(dev);
+	SK_AC		*pAC = pNet->pAC;
+
+	pci_release_regions(pAC->PciDev);
+	free_irq(dev->irq, dev);
+	iounmap(pAC->IoBase);
+	BoardFreeMem(pAC);
 	
 } /* FreeResources */
 
@@ -559,7 +547,6 @@
 		       dev->irq);
 		return -EAGAIN;
 	}
-	pAC->AllocFlag |= SK_ALLOC_IRQ;
 
 	/* Alloc memory for this board (Mem for RxD/TxD) : */
 	if(!BoardAllocMem(pAC)) {
