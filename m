From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: bcmgenet: Add MDIO_INTR in GENETv2
Date: Mon, 15 Feb 2016 17:42:13 +0900
Message-ID: <1455525733-11736-1-git-send-email-jaedon.shin@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35589 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbcBOIma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 03:42:30 -0500
Received: by mail-pa0-f43.google.com with SMTP id ho8so83458892pac.2
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 00:42:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GENETv2 chipsets has MDIO interrupt like the GENETv3+ chipsets.

The previous commit d5c3d84657db ("net: phy: Avoid polling PHY with
PHY_IGNORE_INTERRUPTS") and commit 49f7a471e4d1 ("net: bcmgenet: Properly
configure PHY to ignore interrupt") cause link-down PHY always in some
40nm generation chipsets.

Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index b15a60d787c7..8e9aa8f6390d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1904,7 +1904,7 @@ static int init_umac(struct bcmgenet_priv *priv)
 		bcmgenet_bp_mc_set(priv, reg);
 	}
 
-	/* Enable MDIO interrupts on GENET v3+ */
+	/* Enable MDIO interrupts on GENET v2+ */
 	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
 		int0_enable |= (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
 
@@ -3168,7 +3168,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.rdma_offset = 0x3000,
 		.tdma_offset = 0x4000,
 		.words_per_bd = 2,
-		.flags = GENET_HAS_EXT,
+		.flags = GENET_HAS_EXT | GENET_HAS_MDIO_INTR,
 	},
 	[GENET_V3] = {
 		.tx_queues = 4,
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 967367557309..c14bfbfbe06a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -310,7 +310,7 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_TXDMA_BDONE		(1 << 18)
 #define UMAC_IRQ_TXDMA_DONE		UMAC_IRQ_TXDMA_MBDONE
 
-/* Only valid for GENETv3+ */
+/* Only valid for GENETv2+ */
 #define UMAC_IRQ_MDIO_DONE		(1 << 23)
 #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
 
-- 
2.7.1
