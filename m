From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 07/11] net: bcmgenet: handle GENET_POWER_WOL_MAGIC
Date: Thu, 10 Jul 2014 15:46:20 -0700
Message-ID: <1405032384-24006-8-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:51714 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbaGJWqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:35 -0400
Received: by mail-ig0-f170.google.com with SMTP id h15so3600297igd.3
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:34 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update bcmgenet_power_{up,down} to handle the case where the adapter has
been suspend respectively resumed from Wake-on-LAN using MagicPackets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d913139bf5f3..b010637ee69f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -743,6 +743,10 @@ static void bcmgenet_power_down(struct bcmgenet_priv *priv,
 		phy_detach(priv->phydev);
 		break;
 
+	case GENET_POWER_WOL_MAGIC:
+		bcmgenet_wol_power_down_cfg(priv, mode);
+		break;
+
 	case GENET_POWER_PASSIVE:
 		/* Power down LED */
 		bcmgenet_mii_reset(priv->dev);
@@ -777,6 +781,9 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 		/* enable APD */
 		reg |= EXT_PWR_DN_EN_LD;
 		break;
+	case GENET_POWER_WOL_MAGIC:
+		bcmgenet_wol_power_up_cfg(priv, mode);
+		return;
 	default:
 		break;
 	}
-- 
1.9.1
