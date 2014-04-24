From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 25/26] can: fix return value from can_get_bittiming()
Date: Fri, 25 Apr 2014 00:00:28 +0200
Message-ID: <1398376829-6771-26-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46161 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbaDXWAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:00:45 -0400
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>

When trying to set a data bitrate on non CAN FD devices the 'ip' tool
answers with:

	RTNETLINK answers: Unknown error 524

Rename '-ENOTSUPP' to '-EOPNOTSUPP' so that 'ip' answers correctly:

       RTNETLINK answers: Operation not supported

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index c7a2604..e318e87 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -256,7 +256,7 @@ static int can_get_bittiming(struct net_device *dev, struct can_bittiming *bt,
 
 	/* Check if the CAN device has bit-timing parameters */
 	if (!btc)
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	/*
 	 * Depending on the given can_bittiming parameter structure the CAN
-- 
1.9.0.279.gdc9e3eb
