From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly initialized
Date: Tue, 26 Mar 2013 15:25:07 +0000
Message-ID: <1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
References: <y>
Cc: Fabio Estevam <fabio.estevam@freescale.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:37641 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965357Ab3CZPZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:25:20 -0400
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX Buffer in fec_enet_alloc_buffers was being initialized
with the receive register define BD_ENET_RX_INT instead of
the transmit register define BD_ENET_TX_INT

Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3eb608f..2b78a1e 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1391,7 +1391,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 		if (fep->bufdesc_ex) {
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
-			ebdp->cbd_esc = BD_ENET_RX_INT;
+			ebdp->cbd_esc = BD_ENET_TX_INT;
 		}
 
 		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
-- 
1.7.10.4
