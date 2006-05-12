From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] ethtool always report port is TP on tg3
Date: Fri, 12 May 2006 19:46:23 +0200
Message-ID: <20060512174623.GA28353@pingi.kke.suse.de>
References: <20060512100541.GA10529@pingi.kke.suse.de> <1147445994.4780.55.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:11667 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932169AbWELRqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 13:46:32 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <1147445994.4780.55.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, May 12, 2006 at 07:59:54AM -0700, Michael Chan wrote:
>
> ACK. Thanks. Please add sign-off line and send to DaveM.

This time with Signed-off line.


Even with fiber cards ethtool reports that the connected port is TP,
the patch fix this.

Signed-off-by: Karsten Keil <kkeil@suse.de>
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
