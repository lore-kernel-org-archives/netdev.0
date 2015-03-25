From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 1/7] net: bcmgenet: remove priv->int0_mask and priv->int1_mask
Date: Wed, 25 Mar 2015 12:35:09 -0700 (PDT)
Message-ID: <20150325193509.D65552201FC@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:34483 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbCYUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 16:02:49 -0400
Received: by ykq142 with SMTP id 142so2168189ykq.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 13:02:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused priv->int0_mask and priv->int1_mask.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 --
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c38d542..030249d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -985,7 +985,6 @@ static inline void bcmgenet_tx_ring_int_enable(struct bcmgenet_priv *priv,
 {
 	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
 				 INTRL2_CPU_MASK_CLEAR);
-	priv->int1_mask &= ~(1 << ring->index);
 }
 
 static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
@@ -993,7 +992,6 @@ static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
 {
 	bcmgenet_intrl2_1_writel(priv, (1 << ring->index),
 				 INTRL2_CPU_MASK_SET);
-	priv->int1_mask |= (1 << ring->index);
 }
 
 /* Unlocked version of the reclaim routine */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 7a59879..a9e1612 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -558,8 +558,6 @@ struct bcmgenet_priv {
 	void __iomem *base;
 	enum bcmgenet_version version;
 	struct net_device *dev;
-	u32 int0_mask;
-	u32 int1_mask;
 
 	/* NAPI for descriptor based rx */
 	struct napi_struct napi ____cacheline_aligned;
-- 
2.2.0.rc0.207.ga3a616c
