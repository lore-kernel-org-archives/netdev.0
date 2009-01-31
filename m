From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] cassini: limit reaches -1
Date: Sat, 31 Jan 2009 16:08:55 +0100
Message-ID: <49846987.5050300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:49037 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbZAaPI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 10:08:58 -0500
Received: by nf-out-0910.google.com with SMTP id d3so141461nfc.21
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2009 07:08:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a postfix decrement limit reaches -1, but on 0
the function already returns false.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 840b3d1..bbbc3bb 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -806,7 +806,7 @@ static int cas_reset_mii_phy(struct cas *cp)
 
 	cas_phy_write(cp, MII_BMCR, BMCR_RESET);
 	udelay(100);
-	while (limit--) {
+	while (--limit) {
 		val = cas_phy_read(cp, MII_BMCR);
 		if ((val & BMCR_RESET) == 0)
 			break;
@@ -979,7 +979,7 @@ static void cas_phy_init(struct cas *cp)
 		writel(val, cp->regs + REG_PCS_MII_CTRL);
 
 		limit = STOP_TRIES;
-		while (limit-- > 0) {
+		while (--limit > 0) {
 			udelay(10);
 			if ((readl(cp->regs + REG_PCS_MII_CTRL) &
 			     PCS_MII_RESET) == 0)
