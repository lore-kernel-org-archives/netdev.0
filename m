From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] ll_temac: Add support for V2 LLTEMAC core
Date: Wed, 17 Feb 2010 11:14:20 -0600
Message-ID: <1266426860-5634-1-git-send-email-steve@digidescorp.com>
Cc: linux-kernel@vger.kernel.org,
	"Steven J. Magnani" <steve@digidescorp.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LLTEMAC V1 cores place only received packet length in the app4 word.
V2 cores place additional information in app4.
Mask out the additional information when retrieving the packet length.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
--- a/drivers/net/ll_temac_main.c	2010-02-17 10:38:35.000000000 -0600
+++ b/drivers/net/ll_temac_main.c	2010-02-17 10:57:01.000000000 -0600
@@ -615,7 +615,7 @@ static void ll_temac_recv(struct net_dev
 	while ((bdstat & STS_CTRL_APP0_CMPLT)) {
 
 		skb = lp->rx_skb[lp->rx_bd_ci];
-		length = cur_p->app4;
+		length = cur_p->app4 & 0x3FFF;
 
 		skb_vaddr = virt_to_bus(skb->data);
 		dma_unmap_single(ndev->dev.parent, skb_vaddr, length,
@@ -938,6 +938,9 @@ static int __devexit temac_of_remove(str
 
 static struct of_device_id temac_of_match[] __devinitdata = {
 	{ .compatible = "xlnx,xps-ll-temac-1.01.b", },
+	{ .compatible = "xlnx,xps-ll-temac-2.00.a", },
+	{ .compatible = "xlnx,xps-ll-temac-2.02.a", },
+	{ .compatible = "xlnx,xps-ll-temac-2.03.a", },
 	{},
 };
 MODULE_DEVICE_TABLE(of, temac_of_match);
