From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/5] net: bcmgenet: add missing braces to some if statements
Date: Wed, 23 Jul 2014 10:42:14 -0700
Message-ID: <1406137335-1671-5-git-send-email-f.fainelli@gmail.com>
References: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51654 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740AbaGWRnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:43:42 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2158613pab.16
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:43:41 -0700 (PDT)
In-Reply-To: <1406137335-1671-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch.pl flagged two locations that did not comply to "CHECK:
braces {} should be used on all arms of this statement", fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 25aa42b6cd34..6ebc1b979c01 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1100,8 +1100,9 @@ static int bcmgenet_put_tx_csum(struct net_device *dev, struct sk_buff *skb)
 			tx_csum_info |= STATUS_TX_CSUM_LV;
 			if (ip_proto == IPPROTO_UDP && ip_ver == ETH_P_IP)
 				tx_csum_info |= STATUS_TX_CSUM_PROTO_UDP;
-		} else
+		} else {
 			tx_csum_info = 0;
+		}
 
 		status->tx_csum_info = tx_csum_info;
 	}
@@ -1529,11 +1530,11 @@ static int init_umac(struct bcmgenet_priv *priv)
 	dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
 
 	/* Monitor cable plug/unpluged event for internal PHY */
-	if (phy_is_internal(priv->phydev))
+	if (phy_is_internal(priv->phydev)) {
 		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
-	else if (priv->ext_phy)
+	} else if (priv->ext_phy) {
 		cpu_mask_clear |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
-	else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
+	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
 		reg = bcmgenet_bp_mc_get(priv);
 		reg |= BIT(priv->hw_params->bp_in_en_shift);
 
-- 
1.9.1
