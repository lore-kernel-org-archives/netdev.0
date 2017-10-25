From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 1/9] net: bcmgenet: correct bad merge
Date: Wed, 25 Oct 2017 15:04:11 -0700
Message-ID: <20171025220419.24951-2-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:44253 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932211AbdJYWFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:05:07 -0400
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted in the net-next submission for GENETv5 support [1], there
were merge conflicts with an earlier net submission [2] that had not
yet found its way to the net-next repository.

Unfortunately, when the branches were merged the conflicts were not
correctly resolved.  This commit attempts to correct that.

[1] https://lkml.org/lkml/2017/3/13/1145
[2] https://lkml.org/lkml/2017/3/9/890

Fixes: 101c431492d2 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9cebca896913..f6e8e01be1c8 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2602,12 +2602,6 @@ static void bcmgenet_irq_task(struct work_struct *work)
 	priv->irq0_stat = 0;
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	if (status & UMAC_IRQ_MPD_R) {
-		netif_dbg(priv, wol, priv->dev,
-			  "magic packet detected, waking up\n");
-		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
-	}
-
 	/* Link UP/DOWN event */
 	if (status & UMAC_IRQ_LINK_EVENT)
 		phy_mac_interrupt(priv->phydev,
@@ -2698,23 +2692,13 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		}
 	}
 
-	if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
-				UMAC_IRQ_PHY_DET_F |
-				UMAC_IRQ_LINK_EVENT |
-				UMAC_IRQ_HFB_SM |
-				UMAC_IRQ_HFB_MM)) {
-		/* all other interested interrupts handled in bottom half */
-		schedule_work(&priv->bcmgenet_irq_work);
-	}
-
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
 		status & (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR)) {
 		wake_up(&priv->wq);
 	}
 
 	/* all other interested interrupts handled in bottom half */
-	status &= (UMAC_IRQ_LINK_EVENT |
-		   UMAC_IRQ_MPD_R);
+	status &= UMAC_IRQ_LINK_EVENT;
 	if (status) {
 		/* Save irq status for bottom-half processing. */
 		spin_lock_irqsave(&priv->lock, flags);
-- 
2.14.1
