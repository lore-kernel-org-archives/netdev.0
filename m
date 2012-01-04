From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/6] r6040: use MAC_RST bit definition with MCR1 read/writes
Date: Wed,  4 Jan 2012 19:59:35 +0100
Message-ID: <1325703578-17275-4-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60754 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467Ab2ADS7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:51 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC_RST bit is already defined, use it instead of 0x1 where applicable.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index f4dddcee..4665a39 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -371,7 +371,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	iowrite16(MAC_RST, ioaddr + MCR1);
 	while (limit--) {
 		cmd = ioread16(ioaddr + MCR1);
-		if (cmd & 0x1)
+		if (cmd & MAC_RST)
 			break;
 	}
 	/* Reset internal state machine */
@@ -453,7 +453,7 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(MAC_RST, ioaddr + MCR1);	/* Reset RDC MAC */
 	while (limit--) {
 		cmd = ioread16(ioaddr + MCR1);
-		if (cmd & 0x1)
+		if (cmd & MAC_RST)
 			break;
 	}
 
@@ -735,7 +735,7 @@ static void r6040_mac_address(struct net_device *dev)
 	u16 *adrp;
 
 	/* MAC operation register */
-	iowrite16(0x01, ioaddr + MCR1); /* Reset MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1); /* Reset MAC */
 	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
 	iowrite16(0, ioaddr + MAC_SM);
 	mdelay(5);
-- 
1.7.5.4
