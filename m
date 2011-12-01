From: Patrick Kelle <patrick.kelle81@gmail.com>
Subject: [PATCH v2] icplus: mdio_write(), remove unnecessary for loop
Date: Thu,  1 Dec 2011 14:26:56 +0100
Message-ID: <1322746016-2835-1-git-send-email-patrick.kelle81@gmail.com>
Cc: davem@davemloft.net, romieu@fr.zoreil.com, sorbica@icplus.com.tw,
	Patrick Kelle <patrick.kelle81@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49701 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086Ab1LAN3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 08:29:35 -0500
Received: by eaak14 with SMTP id k14so2128952eaa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 05:29:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point the variable j is always set to 7 and the code within
the loop has to run only once anyway.

As suggested by David Miller:
"You can simply this even further since p[7] is what is used here,
and this means len is one, the inner loop therefore executes only
once, and the p[7].field value is not used (it's zero in the table)
and the write to it is completely thrown away."

Signed-off-by: Patrick Kelle <patrick.kelle81@gmail.com>
---
 drivers/net/ethernet/icplus/ipg.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 8fd80a0..075451d 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -371,16 +371,9 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 	}
 
 	/* The last cycle is a tri-state, so read from the PHY. */
-	for (j = 7; j < 8; j++) {
-		for (i = 0; i < p[j].len; i++) {
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
-
-			p[j].field |= ((ipg_r8(PHY_CTRL) &
-				IPG_PC_MGMTDATA) >> 1) << (p[j].len - 1 - i);
-
-			ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
-		}
-	}
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
+	ipg_r8(PHY_CTRL);
+	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);
 }
 
 static void ipg_set_led_mode(struct net_device *dev)
-- 
1.7.7.1
