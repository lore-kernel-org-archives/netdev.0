From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix check against MCRO_HASHEN bit in r6040_multicast_list
Date: Wed, 16 Nov 2011 17:00:08 +0100
Message-ID: <1321459208-28463-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45775 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670Ab1KPQIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 11:08:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are checking whether the MCR0_HASHEN bit is set using a logical and
instead of bitwise and, fix that.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1fc01ca..4bf68cf 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -940,7 +940,7 @@ static void r6040_multicast_list(struct net_device *dev)
 	iowrite16(lp->mcr0, ioaddr + MCR0);
 
 	/* Fill the MAC hash tables with their values */
-	if (lp->mcr0 && MCR0_HASH_EN) {
+	if (lp->mcr0 & MCR0_HASH_EN) {
 		iowrite16(hash_table[0], ioaddr + MAR0);
 		iowrite16(hash_table[1], ioaddr + MAR1);
 		iowrite16(hash_table[2], ioaddr + MAR2);
-- 
1.7.5.4
