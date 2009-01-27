From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: do not use memcpy on physical addresses
Date: Tue, 27 Jan 2009 11:39:59 +0100
Message-ID: <1233052804-31228-5-git-send-email-s.hauer@pengutronix.de>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-2-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-3-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-4-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	frederic rodo <fred.rodo@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45684 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbZA0KkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:40:25 -0500
In-Reply-To: <1233052804-31228-4-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index a44b4ee..1087c4d 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -341,7 +341,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bdp->cbd_bufaddr & 0x3) {
 		unsigned int index;
 		index = bdp - fep->tx_bd_base;
-		memcpy(fep->tx_bounce[index], (void *) bdp->cbd_bufaddr, bdp->cbd_datlen);
+		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
 		bdp->cbd_bufaddr = __pa(fep->tx_bounce[index]);
 	}
 
-- 
1.5.6.5

