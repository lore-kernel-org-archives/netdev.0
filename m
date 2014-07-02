From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: systemport: use kcalloc instead of kzalloc
Date: Wed,  2 Jul 2014 10:54:59 -0700
Message-ID: <1404323699-12342-3-git-send-email-f.fainelli@gmail.com>
References: <1404323699-12342-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38893 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075AbaGBRzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 13:55:21 -0400
Received: by mail-ig0-f171.google.com with SMTP id h18so6965635igc.10
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 10:55:20 -0700 (PDT)
In-Reply-To: <1404323699-12342-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged two uses of kzalloc() for allocating and zeroing
arrays, use kcalloc() instead as recommended.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 089366b1321a..b292f54a4428 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1009,7 +1009,7 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 		return -ENOMEM;
 	}
 
-	ring->cbs = kzalloc(sizeof(struct bcm_sysport_cb) * size, GFP_KERNEL);
+	ring->cbs = kcalloc(size, sizeof(struct bcm_sysport_cb), GFP_KERNEL);
 	if (!ring->cbs) {
 		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
 		return -ENOMEM;
@@ -1152,8 +1152,8 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
 	priv->rx_bd_assign_index = 0;
 	priv->rx_c_index = 0;
 	priv->rx_read_ptr = 0;
-	priv->rx_cbs = kzalloc(priv->num_rx_bds *
-				sizeof(struct bcm_sysport_cb), GFP_KERNEL);
+	priv->rx_cbs = kcalloc(priv->num_rx_bds, sizeof(struct bcm_sysport_cb),
+				GFP_KERNEL);
 	if (!priv->rx_cbs) {
 		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
 		return -ENOMEM;
-- 
1.9.1
