From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] ravb: fix software timestamping
Date: Sun, 27 Mar 2016 12:22:02 +0200
Message-ID: <1459074122-6964-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:56184 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbcC0KW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Mar 2016 06:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ravb_start_xmit dont call skb_tx_timestamp only when hardware
timestamping is requested: in the latter case software timestamps are
suppressed and thus the call of skb_tx_timestamp does not have any effect.

Instead call skb_tx_timestamp unconditionally in ravb_start_xmit, since
the function checks itself if software timestamping is required or should
be skipped due to hardware timestamping.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/renesas/ravb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

 Sergei, please note that this is only compile tested, since I dont have access
 to the concerning hardware.

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 4e1a7db..087e14a 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1377,11 +1377,11 @@ static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 		/* TAG and timestamp required flag */
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		skb_tx_timestamp(skb);
 		desc->tagh_tsr = (ts_skb->tag >> 4) | TX_TSR;
 		desc->ds_tagl |= le16_to_cpu(ts_skb->tag << 12);
 	}
 
+	skb_tx_timestamp(skb);
 	/* Descriptor type must be set after all the above writes */
 	dma_wmb();
 	desc->die_dt = DT_FEND;
-- 
1.9.1
