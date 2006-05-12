From: Karsten Keil <kkeil@suse.de>
Subject: [PATCH] ethtool always report port is TP on tg3
Date: Fri, 12 May 2006 12:05:41 +0200
Message-ID: <20060512100541.GA10529@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44512 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751106AbWELKFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 06:05:52 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Even with fiber cards ethtool reports that the connected port is TP,
the patch fix this.

---

 drivers/net/tg3.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

5ed8e79c778ee803e44a325a1e15c0cb3f52d0ff
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index beeb612..0b5bc93 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7653,21 +7653,23 @@ static int tg3_get_settings(struct net_d
 		cmd->supported |= (SUPPORTED_1000baseT_Half |
 				   SUPPORTED_1000baseT_Full);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
+	if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)) {
 		cmd->supported |= (SUPPORTED_100baseT_Half |
 				  SUPPORTED_100baseT_Full |
 				  SUPPORTED_10baseT_Half |
 				  SUPPORTED_10baseT_Full |
 				  SUPPORTED_MII);
-	else
+		cmd->port = PORT_TP;
+	} else {
 		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->port = PORT_FIBRE;
+	}
   
 	cmd->advertising = tp->link_config.advertising;
 	if (netif_running(dev)) {
 		cmd->speed = tp->link_config.active_speed;
 		cmd->duplex = tp->link_config.active_duplex;
 	}
-	cmd->port = 0;
 	cmd->phy_address = PHY_ADDR;
 	cmd->transceiver = 0;
 	cmd->autoneg = tp->link_config.autoneg;
-- 
Karsten Keil
SuSE Labs
ISDN development
