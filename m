From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH A 02/12] net: fec: fix ethtool set_pauseparam duplex bug
Date: Tue, 08 Jul 2014 00:22:39 +0100
Message-ID: <E1X4IF5-0004wl-3p@rmk-PC.arm.linux.org.uk>
References: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:57971 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752672AbaGGXWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:22:41 -0400
In-Reply-To: <20140707232148.GG21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting the pause parameters causes a running network interface to be
restarted.  However, the restart forces the FEC into half-duplex mode,
whether or not the remote end is in half-duplex mode.  Misconfigured
duplex mode is a known source of problems on a link.

Fix this by always preserving the duplex mode on configuration changes.

Acked-by: Fugang Duan <B38611@freescale.com>
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
