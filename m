From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/7 v3] au1000-eth: fix bad printk usages
Date: Wed, 8 Sep 2010 23:11:45 +0200
Message-ID: <201009082311.45685.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35261 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab0IHVKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:10:42 -0400
Received: by wwc33 with SMTP id 33so602889wwc.1
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 14:10:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use pr_(info|err) and pr_cont where required instead of calls to printk.
Add missing pr_fmt to the driver.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index a2d86cf..f758b60 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -34,6 +34,8 @@
  *
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
@@ -720,24 +722,26 @@ static int au1000_rx(struct net_device *dev)
 			netif_rx(skb);	/* pass the packet to upper layers */
 		} else {
 			if (au1000_debug > 4) {
+				pr_err("rx_error(s):");
 				if (status & RX_MISSED_FRAME)
-					printk("rx miss\n");
+					pr_cont(" miss");
 				if (status & RX_WDOG_TIMER)
-					printk("rx wdog\n");
+					pr_cont(" wdog");
 				if (status & RX_RUNT)
-					printk("rx runt\n");
+					pr_cont(" runt");
 				if (status & RX_OVERLEN)
-					printk("rx overlen\n");
+					pr_cont(" overlen");
 				if (status & RX_COLL)
-					printk("rx coll\n");
+					pr_cont(" coll");
 				if (status & RX_MII_ERROR)
-					printk("rx mii error\n");
+					pr_cont(" mii error");
 				if (status & RX_CRC_ERROR)
-					printk("rx crc error\n");
+					pr_cont(" crc error");
 				if (status & RX_LEN_ERROR)
-					printk("rx len error\n");
+					pr_cont(" len error");
 				if (status & RX_U_CNTRL_FRAME)
-					printk("rx u control frame\n");
+					pr_cont(" u control frame");
+				pr_cont("\n");
 			}
 		}
 		prxd->buff_stat = (u32)(pDB->dma_addr | RX_DMA_ENABLE);
@@ -1199,7 +1203,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	netdev_info(dev, "Au1xx0 Ethernet found at 0x%lx, irq %d\n",
 			(unsigned long)base->start, irq);
 	if (version_printed++ == 0)
-		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+		pr_info("%s version %s %s\n",
+					DRV_NAME, DRV_VERSION, DRV_AUTHOR);
 
 	return 0;
 


