From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/8] r6040: define and use MTPR transmit enable bit
Date: Wed, 11 Apr 2012 19:18:41 +0200
Message-ID: <1334164723-9627-7-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45813 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760771Ab2DKRUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:14 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define MTPR bit 0 of the register and use it where it is appropriate.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1a365ae..afa4186 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -74,6 +74,7 @@
 #define MT_ICR		0x0C	/* TX interrupt control */
 #define MR_ICR		0x10	/* RX interrupt control */
 #define MTPR		0x14	/* TX poll command register */
+#define  TM2TX		0x0001	/* Trigger MAC to transmit */
 #define MR_BSR		0x18	/* RX buffer size */
 #define MR_DCR		0x1A	/* RX descriptor control */
 #define MLSR		0x1C	/* Last status */
@@ -420,7 +421,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	/* Let TX poll the descriptors
 	 * we may got called by r6040_tx_timeout which has left
 	 * some unsent tx buffers */
-	iowrite16(0x01, ioaddr + MTPR);
+	iowrite16(TM2TX, ioaddr + MTPR);
 }
 
 static void r6040_tx_timeout(struct net_device *dev)
@@ -844,7 +845,7 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	skb_tx_timestamp(skb);
 
 	/* Trigger the MAC to check the TX descriptor */
-	iowrite16(0x01, ioaddr + MTPR);
+	iowrite16(TM2TX, ioaddr + MTPR);
 	lp->tx_insert_ptr = descptr->vndescp;
 
 	/* If no tx resource, stop */
-- 
1.7.5.4
