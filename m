From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2 v2] net: systemport: use kcalloc instead of kzalloc
Date: Wed,  9 Jul 2014 17:36:47 -0700
Message-ID: <1404952607-10412-3-git-send-email-f.fainelli@gmail.com>
References: <1404952607-10412-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:56973 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835AbaGJAhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 20:37:36 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so9898877pde.3
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 17:37:36 -0700 (PDT)
In-Reply-To: <1404952607-10412-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged two uses of kzalloc() for allocating and zeroing
arrays, use kcalloc() instead as recommended.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index b6e4c7b418be..31b5340c685e 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1095,7 +1095,7 @@ static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
 		return -ENOMEM;
 	}
 
-	ring->cbs = kzalloc(sizeof(struct bcm_sysport_cb) * size, GFP_KERNEL);
+	ring->cbs = kcalloc(size, sizeof(struct bcm_sysport_cb), GFP_KERNEL);
 	if (!ring->cbs) {
 		netif_err(priv, hw, priv->netdev, "CB allocation failed\n");
 		return -ENOMEM;
@@ -1238,8 +1238,8 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
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
