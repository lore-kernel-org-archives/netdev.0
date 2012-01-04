From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/6] r6040: use definitions for MAC_SM register read/writes
Date: Wed,  4 Jan 2012 19:59:36 +0100
Message-ID: <1325703578-17275-5-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60758 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756713Ab2ADS7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:51 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bit 1 is the reset bit of the MAC status machine register, define and
use it.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4665a39..e9054a9 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -126,6 +126,7 @@
 #define PHY_CC		0x88	/* PHY status change configuration register */
 #define PHY_ST		0x8A	/* PHY status register */
 #define MAC_SM		0xAC	/* MAC status machine */
+#define  MAC_SM_RST	0x0002	/* MAC status machine reset */
 #define MAC_ID		0xBE	/* Identifier register */
 
 #define TX_DCNT		0x80	/* TX descriptor count */
@@ -375,7 +376,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 			break;
 	}
 	/* Reset internal state machine */
-	iowrite16(2, ioaddr + MAC_SM);
+	iowrite16(MAC_SM_RST, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
 	mdelay(5);
 
@@ -736,7 +737,7 @@ static void r6040_mac_address(struct net_device *dev)
 
 	/* MAC operation register */
 	iowrite16(MAC_RST, ioaddr + MCR1); /* Reset MAC */
-	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
+	iowrite16(MAC_SM_RST, ioaddr + MAC_SM); /* Reset internal state machine */
 	iowrite16(0, ioaddr + MAC_SM);
 	mdelay(5);
 
-- 
1.7.5.4
