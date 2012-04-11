From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/8] r6040: define and use MLSR register bits
Date: Wed, 11 Apr 2012 19:18:40 +0200
Message-ID: <1334164723-9627-6-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45806 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760775Ab2DKRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:13 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the MLSR (MAC Last Status Register bits) for:
- tx fifo under-run
- tx exceed collision
- tx late collision

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index db33573..1a365ae 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -77,6 +77,9 @@
 #define MR_BSR		0x18	/* RX buffer size */
 #define MR_DCR		0x1A	/* RX descriptor control */
 #define MLSR		0x1C	/* Last status */
+#define  TX_FIFO_UNDR	0x0200	/* TX FIFO under-run */
+#define	 TX_EXCEEDC	0x2000	/* Transmit exceed collision */
+#define  TX_LATEC	0x4000	/* Transmit late collision */
 #define MMDIO		0x20	/* MDIO control register */
 #define  MDIO_WRITE	0x4000	/* MDIO write */
 #define  MDIO_READ	0x2000	/* MDIO read */
@@ -604,9 +607,9 @@ static void r6040_tx(struct net_device *dev)
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
 
-		if (err & 0x0200)
+		if (err & TX_FIFO_UNDR)
 			dev->stats.tx_fifo_errors++;
-		if (err & (0x2000 | 0x4000))
+		if (err & (TX_EXCEEDC | TX_LATEC))
 			dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & DSC_OWNER_MAC)
-- 
1.7.5.4
