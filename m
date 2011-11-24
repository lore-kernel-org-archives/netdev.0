From: Patrick Kelle <patrick.kelle81@gmail.com>
Subject: [PATCH] icplus: mdio_write(), remove unnecessary for loop
Date: Thu, 24 Nov 2011 16:39:05 +0100
Message-ID: <1322149145-32242-1-git-send-email-patrick.kelle81@gmail.com>
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw,
	Patrick Kelle <patrick.kelle81@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45729 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab1KXPl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 10:41:26 -0500
Received: by faas1 with SMTP id s1so1692536faa.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 07:41:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point the variable j is always set to 7 and the code within
the loop has to run only once anyway.

Signed-off-by: Patrick Kelle <patrick.kelle81@gmail.com>
---
 drivers/net/ethernet/icplus/ipg.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 8fd80a0..a65d747 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -371,15 +371,13 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 	}
 
 	/* The last cycle is a tri-state, so read from the PHY. */
-	for (j = 7; j < 8; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
+	for (i = 0; i < p[j].len; i++) {
+		ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
 
-			p[j].field |= ((ipg_r8(PHY_CTRL) &
-				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
+		p[j].field |= ((ipg_r8(PHY_CTRL) &
+			IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
 
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
-		}
+		ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
 	}
 }
 
-- 
1.7.7.1
