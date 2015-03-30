From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 4/5] net: bcmgenet: add UMAC_IRQ_LINK_EVENT
Date: Mon, 30 Mar 2015 00:29:24 -0700 (PDT)
Message-ID: <20150330072924.5AF68220215@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:34344 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbbC3Hf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:35:57 -0400
Received: by qcrw7 with SMTP id w7so2085032qcr.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:35:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define UMAC_IRQ_LINK_EVENT to simplify link event handling code.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 11 +++++------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5238b33..bf1a871 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1730,9 +1730,9 @@ static int init_umac(struct bcmgenet_priv *priv)
 
 	/* Monitor cable plug/unplugged event for internal PHY */
 	if (phy_is_internal(priv->phydev)) {
-		int0_enable |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
+		int0_enable |= UMAC_IRQ_LINK_EVENT;
 	} else if (priv->ext_phy) {
-		int0_enable |= (UMAC_IRQ_LINK_DOWN | UMAC_IRQ_LINK_UP);
+		int0_enable |= UMAC_IRQ_LINK_EVENT;
 	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
 		reg = bcmgenet_bp_mc_get(priv);
 		reg |= BIT(priv->hw_params->bp_in_en_shift);
@@ -2271,10 +2271,10 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	/* Link UP/DOWN event */
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
-	    (priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
+	    (priv->irq0_stat & UMAC_IRQ_LINK_EVENT)) {
 		phy_mac_interrupt(priv->phydev,
 				  priv->irq0_stat & UMAC_IRQ_LINK_UP);
-		priv->irq0_stat &= ~(UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN);
+		priv->irq0_stat &= ~UMAC_IRQ_LINK_EVENT;
 	}
 }
 
@@ -2364,8 +2364,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 
 	if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
 				UMAC_IRQ_PHY_DET_F |
-				UMAC_IRQ_LINK_UP |
-				UMAC_IRQ_LINK_DOWN |
+				UMAC_IRQ_LINK_EVENT |
 				UMAC_IRQ_HFB_SM |
 				UMAC_IRQ_HFB_MM |
 				UMAC_IRQ_MPD_R)) {
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index f86d635..ddaa40c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -293,6 +293,7 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_PHY_DET_F		(1 << 3)
 #define UMAC_IRQ_LINK_UP		(1 << 4)
 #define UMAC_IRQ_LINK_DOWN		(1 << 5)
+#define UMAC_IRQ_LINK_EVENT		(UMAC_IRQ_LINK_UP | UMAC_IRQ_LINK_DOWN)
 #define UMAC_IRQ_UMAC			(1 << 6)
 #define UMAC_IRQ_UMAC_TSV		(1 << 7)
 #define UMAC_IRQ_TBUF_UNDERRUN		(1 << 8)
-- 
2.2.0.rc0.207.ga3a616c
