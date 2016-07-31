From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: s2io: simplify logical constraint
Date: Sun, 31 Jul 2016 11:53:57 +0200
Message-ID: <1469958837-1044-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:54070 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbcGaJyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 05:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(!A || (A && B)) is equivalent to (!A || B)

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/neterion/s2io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 2874dff..eaa37c0 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7412,7 +7412,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) &&
 	    ((!ring_data->lro) ||
-	     (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
+	     (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG))) &&
 	    (dev->features & NETIF_F_RXCSUM)) {
 		l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
 		l4_csum = RXD_GET_L4_CKSUM(rxdp->Control_1);
-- 
2.8.1
