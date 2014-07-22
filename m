From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/6] net: bcmgenet: use kcalloc instead of kzalloc
Date: Tue, 22 Jul 2014 10:55:18 -0700
Message-ID: <1406051718-15883-7-git-send-email-f.fainelli@gmail.com>
References: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59418 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbaGVRzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:55:40 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so5210pdi.20
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:55:40 -0700 (PDT)
In-Reply-To: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two places that used kzalloc() with a multiplied sizeof(),
replace these with kcalloc as recommended by checkpatch.pl.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 11d19ab202b3..2ac4bf8a8b86 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1631,8 +1631,8 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	priv->rx_bd_assign_index = 0;
 	priv->rx_c_index = 0;
 	priv->rx_read_ptr = 0;
-	priv->rx_cbs = kzalloc(priv->num_rx_bds * sizeof(struct enet_cb),
-				GFP_KERNEL);
+	priv->rx_cbs = kcalloc(priv->num_rx_bds, sizeof(struct enet_cb),
+			       GFP_KERNEL);
 	if (!priv->rx_cbs)
 		return -ENOMEM;
 
@@ -1773,7 +1773,7 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 	/* Initialize commont TX ring structures */
 	priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
 	priv->num_tx_bds = TOTAL_DESC;
-	priv->tx_cbs = kzalloc(priv->num_tx_bds * sizeof(struct enet_cb),
+	priv->tx_cbs = kcalloc(priv->num_tx_cbs, sizeof(struct enet_cb),
 			       GFP_KERNEL);
 	if (!priv->tx_cbs) {
 		bcmgenet_fini_dma(priv);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index bdd12410fbbe..18961613d385 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -381,7 +381,7 @@ static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 priv->pdev->name, priv->pdev->id);
 
-	bus->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
 	if (!bus->irq) {
 		mdiobus_free(priv->mii_bus);
 		return -ENOMEM;
-- 
1.9.1
