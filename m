From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 02/21] ARCNET: fix hard_header_len limit
Date: Fri, 24 Apr 2015 19:20:36 +0200
Message-ID: <1429896055-31680-3-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44255 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031399AbbDXRWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:18 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit <9c7077622dd9> ("packet: make packet_snd fail on len smaller
than l2 header") adds the check for minimum packet length of the used l2.
For arcnet the hardware header length is not the complete archdr which
includes hard + soft header. This patch changes the length to
sizeof(arc_hardware).

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 10f71c73..816d0e9 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -326,7 +326,7 @@ static void arcdev_setup(struct net_device *dev)
 	dev->type = ARPHRD_ARCNET;
 	dev->netdev_ops = &arcnet_netdev_ops;
 	dev->header_ops = &arcnet_header_ops;
-	dev->hard_header_len = sizeof(struct archdr);
+	dev->hard_header_len = sizeof(struct arc_hardware);
 	dev->mtu = choose_mtu();
 
 	dev->addr_len = ARCNET_ALEN;
-- 
2.1.4
