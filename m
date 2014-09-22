From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next v3] fec: Remove fec_enet_select_queue()
Date: Mon, 22 Sep 2014 17:55:29 -0300
Message-ID: <1411419329-11957-1-git-send-email-festevam@gmail.com>
Cc: Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:61971 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbaIVUzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:55:52 -0400
Received: by mail-yh0-f49.google.com with SMTP id z6so835900yhz.22
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:55:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Sparse complains about fec_enet_select_queue() not being static.

Feedback from David Miller [1] was to remove this function instead of making it
static:

"Please just delete this function.

It's overriding code which does exactly the same thing.

Actually, more precisely, this code is duplicating code in a way that
bypasses many core facilitites of the networking.  For example, this
override means that socket based flow steering, XPS, etc. are all
not happening on these devices.

Without ->ndo_select_queue(), the flow dissector does __netdev_pick_tx
which is exactly what you want to happen."

[1] http://www.spinics.net/lists/netdev/msg297653.html

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v2:
- Remove fec_enet_select_queue() instead of making it static.

 drivers/net/ethernet/freescale/fec_main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 09d7f5f..33a7410 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2851,17 +2851,10 @@ static int fec_set_features(struct net_device *netdev,
 	return 0;
 }
 
-u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
-			  void *accel_priv, select_queue_fallback_t fallback)
-{
-	return skb_tx_hash(ndev, skb);
-}
-
 static const struct net_device_ops fec_netdev_ops = {
 	.ndo_open		= fec_enet_open,
 	.ndo_stop		= fec_enet_close,
 	.ndo_start_xmit		= fec_enet_start_xmit,
-	.ndo_select_queue       = fec_enet_select_queue,
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.9.1
