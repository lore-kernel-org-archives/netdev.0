From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH net-next 2/2] net: gianfar: add missing __iomem annotation
Date: Wed, 24 Dec 2014 14:05:45 +0800
Message-ID: <1419401145-8967-2-git-send-email-haokexin@gmail.com>
References: <1419401145-8967-1-git-send-email-haokexin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51956 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaLXGGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 01:06:51 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so9438149pab.40
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 22:06:51 -0800 (PST)
In-Reply-To: <1419401145-8967-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following spare warning:
drivers/net/ethernet/freescale/gianfar.c:3521:60: warning: incorrect type in argument 1 (different address spaces)
drivers/net/ethernet/freescale/gianfar.c:3521:60:    expected unsigned int [noderef] <asn:2>*addr
drivers/net/ethernet/freescale/gianfar.c:3521:60:    got unsigned int [usertype] *rfbptr
drivers/net/ethernet/freescale/gianfar.c:205:16: warning: incorrect type in assignment (different address spaces)
drivers/net/ethernet/freescale/gianfar.c:205:16:    expected unsigned int [usertype] *rfbptr
drivers/net/ethernet/freescale/gianfar.c:205:16:    got unsigned int [noderef] <asn:2>*<noident>
drivers/net/ethernet/freescale/gianfar.c:2918:44: warning: incorrect type in argument 1 (different address spaces)
drivers/net/ethernet/freescale/gianfar.c:2918:44:    expected unsigned int [noderef] <asn:2>*addr
drivers/net/ethernet/freescale/gianfar.c:2918:44:    got unsigned int [usertype] *rfbptr

Signed-off-by: Kevin Hao <haokexin@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 drivers/net/ethernet/freescale/gianfar.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d2a67ed10a38..e54b1e39f9b4 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -177,7 +177,7 @@ static int gfar_init_bds(struct net_device *ndev)
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	u32 *rfbptr;
+	u32 __iomem *rfbptr;
 	int i, j;
 	dma_addr_t bufaddr;
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index b581b8823a2a..9e1802400c23 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1039,7 +1039,7 @@ struct gfar_priv_rx_q {
 	/* RX Coalescing values */
 	unsigned char rxcoalescing;
 	unsigned long rxic;
-	u32 *rfbptr;
+	u32 __iomem *rfbptr;
 };
 
 enum gfar_irqinfo_id {
-- 
1.9.3
