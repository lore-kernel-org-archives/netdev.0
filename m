From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 2/5] net: bcmgenet: fix phydev reference leak
Date: Thu, 24 Nov 2016 19:21:28 +0100
Message-ID: <1480011691-13278-3-git-send-email-johan@kernel.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_phy_find_device() when
initialising MOCA PHYs.

Fixes: 6ac9de5f6563 ("net: bcmgenet: Register link_update callback for
all MoCA PHYs")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 457c3bc8cfff..2e745bd51df4 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -542,8 +542,10 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	/* Make sure we initialize MoCA PHYs with a link down */
 	if (phy_mode == PHY_INTERFACE_MODE_MOCA) {
 		phydev = of_phy_find_device(dn);
-		if (phydev)
+		if (phydev) {
 			phydev->link = 0;
+			put_device(&phydev->mdio.dev);
+		}
 	}
 
 	return 0;
-- 
2.7.3
