From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] cs89x0: fix warning release_irq label
Date: Mon, 25 Aug 2008 23:37:36 +0900
Message-ID: <20080825233736.e7a17376.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo32.po.2iij.NET ([210.128.50.17]:17469 "EHLO mo32.po.2iij.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097AbYHYOi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:38:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

release_irq label is only used when ALLOW_DMA is defined.

drivers/net/cs89x0.c: In function 'net_open':
drivers/net/cs89x0.c:1401: warning: label 'release_irq' defined but not used

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/net/cs89x0.c linux/drivers/net/cs89x0.c
--- linux-orig/drivers/net/cs89x0.c	2008-08-07 13:14:59.904521743 +0900
+++ linux/drivers/net/cs89x0.c	2008-08-07 16:11:31.469037245 +0900
@@ -1397,9 +1397,7 @@ net_open(struct net_device *dev)
 release_dma:
 #if ALLOW_DMA
 		free_dma(dev->dma);
-#endif
 release_irq:
-#if ALLOW_DMA
 		release_dma_buff(lp);
 #endif
                 writereg(dev, PP_LineCTL, readreg(dev, PP_LineCTL) & ~(SERIAL_TX_ON | SERIAL_RX_ON));
