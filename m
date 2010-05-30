From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Sun, 30 May 2010 20:22:14 +0800
Message-ID: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:45534 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0E3MWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 08:22:04 -0400
Received: by pxi18 with SMTP id 18so1132964pxi.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 05:22:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ioread32() returns a 32-bit integer on all platforms.
There is no need to cast its return value.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/8139too.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 4ba7293..cc7d462 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -662,7 +662,7 @@ static const struct ethtool_ops rtl8139_ethtool_ops;
 /* read MMIO register */
 #define RTL_R8(reg)		ioread8 (ioaddr + (reg))
 #define RTL_R16(reg)		ioread16 (ioaddr + (reg))
-#define RTL_R32(reg)		((unsigned long) ioread32 (ioaddr + (reg)))
+#define RTL_R32(reg)		ioread32 (ioaddr + (reg))
 
 
 static const u16 rtl8139_intr_mask =
@@ -861,7 +861,7 @@ retry:
 
 	/* if unknown chip, assume array element #0, original RTL-8139 in this case */
 	dev_dbg(&pdev->dev, "unknown chip version, assuming RTL-8139\n");
-	dev_dbg(&pdev->dev, "TxConfig = 0x%lx\n", RTL_R32 (TxConfig));
+	dev_dbg(&pdev->dev, "TxConfig = 0x%x\n", RTL_R32 (TxConfig));
 	tp->chipset = 0;
 
 match:
@@ -1642,7 +1642,7 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	netdev_dbg(dev, "Tx queue start entry %ld  dirty entry %ld\n",
 		   tp->cur_tx, tp->dirty_tx);
 	for (i = 0; i < NUM_TX_DESC; i++)
-		netdev_dbg(dev, "Tx descriptor %d is %08lx%s\n",
+		netdev_dbg(dev, "Tx descriptor %d is %08x%s\n",
 			   i, RTL_R32(TxStatus0 + (i * 4)),
 			   i == tp->dirty_tx % NUM_TX_DESC ?
 			   " (queue head)" : "");
@@ -2486,7 +2486,7 @@ static void __set_rx_mode (struct net_device *dev)
 	int rx_mode;
 	u32 tmp;
 
-	netdev_dbg(dev, "rtl8139_set_rx_mode(%04x) done -- Rx config %08lx\n",
+	netdev_dbg(dev, "rtl8139_set_rx_mode(%04x) done -- Rx config %08x\n",
 		   dev->flags, RTL_R32(RxConfig));
 
 	/* Note: do not reorder, GCC is clever about common statements. */
--
