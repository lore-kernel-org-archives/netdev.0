From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/7] net: bcmgenet: fix GPHY power-up sequence
Date: Mon, 23 Mar 2015 15:09:54 -0700
Message-ID: <1427148597-28337-5-git-send-email-f.fainelli@gmail.com>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36648 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbbCWWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:11:23 -0400
Received: by pdbcz9 with SMTP id cz9so200315697pdb.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:11:23 -0700 (PDT)
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were missing a number of extra steps and delays to power-up the GPHY, update
the sequence to reflect the proper procedure here.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 3fdbf57208a3..c26c0757d755 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -179,14 +179,18 @@ static void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 
 	if (enable) {
 		reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
-		reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_CK25_DIS);
+		reg &= ~EXT_CK25_DIS;
+		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+		mdelay(1);
+
+		reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
 		reg |= EXT_GPHY_RESET;
 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-		mdelay(2);
+		mdelay(1);
 
 		reg &= ~EXT_GPHY_RESET;
 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-		udelay(20);
+		udelay(60);
 	}
 }
 
-- 
2.1.0
