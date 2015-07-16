From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/6] net: bcmgenet: Power on integrated GPHY in bcmgenet_power_up()
Date: Thu, 16 Jul 2015 15:51:16 -0700
Message-ID: <1437087079-21678-4-git-send-email-f.fainelli@gmail.com>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35501 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbGPWxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:53:22 -0400
Received: by pdrg1 with SMTP id g1so51151110pdr.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:53:22 -0700 (PDT)
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently disabling the GPHY interface during bcmgenet_close(),
and attempting to power it back on during bcmgenet_open(). This works
fine for the first time, because we called bcmgenet_mii_config() which
took care of enabling the interface, however, bcmgenet_power_up() really
needs to power on the GPHY for correctness.

This will be particularly important as we want to move
bcmgenet_mii_probe() down to bcmgenet_open() to avoid seeing the "PHY
already attached" message.

Fixes: a642c4f7906f36 ("net: bcmgenet: power up and down integrated GPHY when unused")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c634ddbbd21d..2efe72f94869 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -907,6 +907,8 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 	}
 
 	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	if (mode == GENET_POWER_PASSIVE)
+		bcmgenet_phy_power_set(priv->dev, true);
 }
 
 /* ioctl handle special commands that are not present in ethtool. */
-- 
2.1.0
