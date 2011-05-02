From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: [PATCH] can: fix SJA1000 dlc for RTR packets
Date: Mon, 2 May 2011 16:50:48 +0200
Message-ID: <20110502145048.GF338@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:33448 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab1EBOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2011 10:50:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTR frames do have a valid data length code on CAN.
The driver for SJA1000 did not handle that situation properly.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
 drivers/net/can/sja1000/sja1000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index a358ea9..f501bba 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -346,10 +346,10 @@ static void sja1000_rx(struct net_device *dev)
 		    | (priv->read_reg(priv, REG_ID2) >> 5);
 	}
 
+	cf->can_dlc = get_can_dlc(fi & 0x0F);
 	if (fi & FI_RTR) {
 		id |= CAN_RTR_FLAG;
 	} else {
-		cf->can_dlc = get_can_dlc(fi & 0x0F);
 		for (i = 0; i < cf->can_dlc; i++)
 			cf->data[i] = priv->read_reg(priv, dreg++);
 	}
