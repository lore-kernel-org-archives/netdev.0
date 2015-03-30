From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 5/5] net: bcmgenet: fix the call to phy_mac_interrupt()
Date: Mon, 30 Mar 2015 00:29:35 -0700 (PDT)
Message-ID: <20150330072935.5EA00220215@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33637 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbbC3Hfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:35:43 -0400
Received: by qgdz60 with SMTP id z60so2088035qgd.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:35:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On phy_mac_interrupt() call, the new_link parameter should be 0 or 1.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index bf1a871..f7855a6 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2273,7 +2273,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
 	    (priv->irq0_stat & UMAC_IRQ_LINK_EVENT)) {
 		phy_mac_interrupt(priv->phydev,
-				  priv->irq0_stat & UMAC_IRQ_LINK_UP);
+				  !!(priv->irq0_stat & UMAC_IRQ_LINK_UP));
 		priv->irq0_stat &= ~UMAC_IRQ_LINK_EVENT;
 	}
 }
-- 
2.2.0.rc0.207.ga3a616c
