From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 03/15] via-rhine: small rhine_wait_bit() improvement.
Date: Mon, 31 Dec 2012 16:25:37 +0100
Message-ID: <1356967549-5056-4-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54114 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Precalculate actual I/O address,
make sure to remember value in helper variable,
add a logging helper line.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 928d96f..6be6566 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -505,11 +505,19 @@ static void rhine_restart_tx(struct net_device *dev);
 
 static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask, bool low)
 {
-	void __iomem *ioaddr = rp->base;
+	void __iomem *ioaddr_reg = rp->base;
 	int i;
 
+	ioaddr_reg += reg;
 	for (i = 0; i < 1024; i++) {
-		bool has_mask_bits = !!(ioread8(ioaddr + reg) & mask);
+		u8 val = ioread8(ioaddr_reg);
+		bool has_mask_bits = !!(val & mask);
+
+		if (i < 20 /* avoid log spew */) {
+			/* netif_err(rp, hw, rp->dev,
+			"wait_bit %02x val %02x mask %02x %s hmb %d\n",
+			reg, val, mask, low ? "low" : "high", has_mask_bits); */
+		}
 
 		if (low ^ has_mask_bits)
 			break;
-- 
1.7.2.5
