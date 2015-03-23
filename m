From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/7] net: bcmgenet: update bcmgenet_ephy_power_up to clear CK25_DIS bit
Date: Mon, 23 Mar 2015 15:09:52 -0700
Message-ID: <1427148597-28337-3-git-send-email-f.fainelli@gmail.com>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34883 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbbCWWLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:11:21 -0400
Received: by pdbop1 with SMTP id op1so200397800pdb.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:11:20 -0700 (PDT)
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CK25_DIS bit controls whether a 25Mhz clock is fed to the GPHY or
not, in preparation for powering down the integrated GPHY when relevant,
make sure we clear that bit.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 1ea838946318..a27ef777cc81 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -354,6 +354,7 @@ struct bcmgenet_mib_counters {
 #define EXT_GPHY_CTRL			0x1C
 #define  EXT_CFG_IDDQ_BIAS		(1 << 0)
 #define  EXT_CFG_PWR_DOWN		(1 << 1)
+#define  EXT_CK25_DIS			(1 << 4)
 #define  EXT_GPHY_RESET			(1 << 5)
 
 /* DMA rings size */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 446889cc3c6a..f7d9d2753141 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -178,7 +178,7 @@ static void bcmgenet_ephy_power_up(struct net_device *dev)
 		return;
 
 	reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
-	reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
+	reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_CK25_DIS);
 	reg |= EXT_GPHY_RESET;
 	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
 	mdelay(2);
-- 
2.1.0
