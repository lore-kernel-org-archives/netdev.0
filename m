From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 4/9] can: sja1000: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:12 +0100
Message-ID: <1293296117-27624-5-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57432 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab0LYQzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 11:55:23 -0500
In-Reply-To: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/sja1000.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 0a8de01..bb4bfe3 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -346,13 +346,12 @@ static void sja1000_rx(struct net_device *dev)
 		    | (priv->read_reg(priv, REG_ID2) >> 5);
 	}
 
-	if (fi & FI_RTR) {
+	cf->can_dlc = get_can_dlc(fi & 0x0F);
+	if (fi & FI_RTR)
 		id |= CAN_RTR_FLAG;
-	} else {
-		cf->can_dlc = get_can_dlc(fi & 0x0F);
+	else
 		for (i = 0; i < cf->can_dlc; i++)
 			cf->data[i] = priv->read_reg(priv, dreg++);
-	}
 
 	cf->can_id = id;
 
-- 
1.7.2.3

