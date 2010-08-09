From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/6] au1000-eth: fix bad printk usages
Date: Mon, 9 Aug 2010 22:03:40 +0200
Message-ID: <201008092203.41338.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55363 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755746Ab0HIUCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:02:52 -0400
Received: by mail-ww0-f44.google.com with SMTP id 40so12017023wwj.1
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 13:02:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use pr_(info|err) and pr_cont where required instead of calls to printk.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 9a0515d..f8f1f5e 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -732,24 +732,25 @@ static int au1000_rx(struct net_device *dev)
 			netif_rx(skb);	/* pass the packet to upper layers */
 		} else {
 			if (au1000_debug > 4) {
+				pr_err("rx_error: ");
 				if (status & RX_MISSED_FRAME)
-					printk("rx miss\n");
+					pr_cont("rx miss\n");
 				if (status & RX_WDOG_TIMER)
-					printk("rx wdog\n");
+					pr_cont("rx wdog\n");
 				if (status & RX_RUNT)
-					printk("rx runt\n");
+					pr_cont("rx runt\n");
 				if (status & RX_OVERLEN)
-					printk("rx overlen\n");
+					pr_cont("rx overlen\n");
 				if (status & RX_COLL)
-					printk("rx coll\n");
+					pr_cont("rx coll\n");
 				if (status & RX_MII_ERROR)
-					printk("rx mii error\n");
+					pr_cont("rx mii error\n");
 				if (status & RX_CRC_ERROR)
-					printk("rx crc error\n");
+					pr_cont("rx crc error\n");
 				if (status & RX_LEN_ERROR)
-					printk("rx len error\n");
+					pr_cont("rx len error\n");
 				if (status & RX_U_CNTRL_FRAME)
-					printk("rx u control frame\n");
+					pr_cont("rx u control frame\n");
 			}
 		}
 		prxd->buff_stat = (u32)(pDB->dma_addr | RX_DMA_ENABLE);
@@ -1225,7 +1226,8 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	netdev_info(dev, "Au1xx0 Ethernet found at 0x%lx, irq %d\n",
 			(unsigned long)base->start, irq);
 	if (version_printed++ == 0)
-		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+		pr_info("%s version %s %s\n",
+					DRV_NAME, DRV_VERSION, DRV_AUTHOR);
 
 	return 0;
 


