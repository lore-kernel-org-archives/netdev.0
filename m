From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: mv643xx_eth: Do not clobber PHY link outside of state machine
Date: Mon,  6 Feb 2017 15:55:20 -0800
Message-ID: <20170206235523.23216-2-f.fainelli@gmail.com>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
Cc: zefir.kurtisi@neratec.com, Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206235523.23216-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling phy_read_status() means that we may call into
genphy_read_status() which in turn will use genphy_update_link() which
can make changes to phydev->link outside of the state machine's state
transitions. This is an invalid behavior that is now caught as of
811a919135b9 ("phy state machine: failsafe leave invalid RUNNING state")

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 20cb7f0de601..25642dee49d3 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1504,9 +1504,7 @@ mv643xx_eth_get_link_ksettings_phy(struct mv643xx_eth_private *mp,
 	int err;
 	u32 supported, advertising;
 
-	err = phy_read_status(dev->phydev);
-	if (err == 0)
-		err = phy_ethtool_ksettings_get(dev->phydev, cmd);
+	err = phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
-- 
2.9.3
