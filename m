From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: Fix build due to wrong dev annotation
Date: Tue,  7 Feb 2012 16:27:31 -0200
Message-ID: <1328639251-26310-1-git-send-email-festevam@gmail.com>
Cc: davem@davemloft.net, netdev@pradeepdalvi.com,
	kernel@pengutronix.de, Fabio Estevam <festevam@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55816 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab2BGS1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:27:40 -0500
Received: by yenm8 with SMTP id m8so3165531yen.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 10:27:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 21a4e469 (netdev: ethernet dev_alloc_skb to netdev_alloc_skb) 
should have used "ndev" instead of "dev".

This causes the following build errors:

drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_rx':
drivers/net/ethernet/freescale/fec.c:714: error: 'dev' undeclared (first use in this function)
drivers/net/ethernet/freescale/fec.c:714: error: (Each undeclared identifier is reported only once
drivers/net/ethernet/freescale/fec.c:714: error: for each function it appears in.)
drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_alloc_buffers':
drivers/net/ethernet/freescale/fec.c:1213: error: 'dev' undeclared (first use in this function)

Fix it, so that fec driver can be built again.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f976619..0ee2ca7 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -711,7 +711,7 @@ fec_enet_rx(struct net_device *ndev)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		skb = netdev_alloc_skb(dev, pkt_len - 4 + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(ndev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
@@ -1210,7 +1210,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = netdev_alloc_skb(dev, FEC_ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
-- 
1.7.1
