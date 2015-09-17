From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH][RESEND] ARCNET: fix hard_header_len limit
Date: Thu, 17 Sep 2015 15:18:34 +0200
Message-ID: <1442495914-26823-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55914 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbbIQNSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 09:18:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For arcnet the bare minimum header only contains the 4 bytes to
specify source, dest and offset (1, 1 and 2 bytes respectively).
The corresponding struct is struct arc_hardware.

The struct archdr contains additionally a union of possible soft
headers. When doing $insertusecasehere packets might well
include short (or even no?) soft headers.

For this reason only use arc_hardware instead of archdr to
determine the hard_header_len for an arcnet device.

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
2.5.0
