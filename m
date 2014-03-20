From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: bcmgenet: add skb_tx_timestamp call
Date: Thu, 20 Mar 2014 10:53:21 -0700
Message-ID: <1395338003-17982-3-git-send-email-f.fainelli@gmail.com>
References: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:61960 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759287AbaCTRxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:53:36 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so1281470pbb.17
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:53:36 -0700 (PDT)
In-Reply-To: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCMGENET driver was not TX timestamping the SKBs it queued for
transmission, do this in bcmgenet_xmit() right before kicking the
Transmit DMA engine.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index e836c4c35399..0a9f6df819bb 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1176,6 +1176,8 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	skb_tx_timestamp(skb);
+
 	/* we kept a software copy of how much we should advance the TDMA
 	 * producer index, now write it down to the hardware
 	 */
-- 
1.8.3.2
