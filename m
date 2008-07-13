From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 08/10] r6040: change the default waiting time
Date: Sun, 13 Jul 2008 14:35:00 +0200
Message-ID: <200807131435.00602.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:50582 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbYGMMf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:35:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the default waiting time of a packet, which
along with our previous r6040_rx path, was causing huge delays
with another host (160 to 230 ms).

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 973f1e8..b68781d 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -388,8 +388,8 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
 
 	/* Set interrupt waiting time and packet numbers */
-	iowrite16(0x0F06, ioaddr + MT_ICR);
-	iowrite16(0x0F06, ioaddr + MR_ICR);
+	iowrite16(0, ioaddr + MT_ICR);
+	iowrite16(0, ioaddr + MR_ICR);
 
 	/* Enable interrupts */
 	iowrite16(INT_MASK, ioaddr + MIER);
