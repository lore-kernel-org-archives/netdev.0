From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 03/30] net: fec: fix ethtool set_pauseparam duplex bug
Date: Fri, 20 Jun 2014 13:11:58 +0100
Message-ID: <E1Wxxfi-0005X1-GZ@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36323 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966820AbaFTMMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:12:00 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting the pause parameters causes a running network interface to be
restarted.  However, the restart forces the FEC into half-duplex mode,
whether or not the remote end is in half-duplex mode.  Misconfigured
duplex mode is a known source of problems on a link.

Fix this by always preserving the duplex mode on configuration changes.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a91fe68030e6..045ea71f2b59 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1897,7 +1897,7 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 		phy_start_aneg(fep->phy_dev);
 	}
 	if (netif_running(ndev))
-		fec_restart(ndev, 0);
+		fec_restart(ndev, fep->full_duplex);
 
 	return 0;
 }
-- 
1.8.3.1
