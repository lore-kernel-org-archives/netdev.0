From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/11] net: dsa: bcm_sf2: remove unneeded supported flags
Date: Mon, 31 Jul 2017 18:17:14 -0400
Message-ID: <20170731221719.16695-7-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33608 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdGaWUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 18:20:19 -0400
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SF2 driver is masking the supported bitfield of its private copy of
the ports' ethtool_eee structures. It is used nowhere, thus remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 648f91b58d1e..aef475f1ce06 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -327,12 +327,8 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
 			    struct phy_device *phy)
 {
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	int ret;
 
-	p->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full);
-
 	ret = phy_init_eee(phy, 0);
 	if (ret)
 		return 0;
-- 
2.13.3
