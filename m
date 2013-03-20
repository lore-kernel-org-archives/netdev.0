From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: Define indexes as 'unsigned int'
Date: Wed, 20 Mar 2013 12:31:07 -0300
Message-ID: <1363793467-18860-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:60164 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3CTPbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:31:23 -0400
Received: by mail-qa0-f51.google.com with SMTP id g10so1088424qah.10
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 08:31:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Fix the following warnings that happen when building with W=1 option:

drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_free_buffers':
drivers/net/ethernet/freescale/fec.c:1337:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_alloc_buffers':
drivers/net/ethernet/freescale/fec.c:1361:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_init':
drivers/net/ethernet/freescale/fec.c:1631:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 8ca2cf6..186222e 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1329,7 +1329,7 @@ static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 static void fec_enet_free_buffers(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	int i;
+	unsigned int i;
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
 
@@ -1353,7 +1353,7 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 static int fec_enet_alloc_buffers(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	int i;
+	unsigned int i;
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
 
@@ -1595,7 +1595,7 @@ static int fec_enet_init(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct bufdesc *cbd_base;
 	struct bufdesc *bdp;
-	int i;
+	unsigned int i;
 
 	/* Allocate memory for buffer descriptors. */
 	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
-- 
1.7.9.5
