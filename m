From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: netcp: Do not clobber PHY link outside of state machine
Date: Mon,  6 Feb 2017 15:55:22 -0800
Message-ID: <20170206235523.23216-4-f.fainelli@gmail.com>
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
transitions. This is an invalid behavior that is now caught as off
811a919135b9 ("phy state machine: failsafe leave invalid RUNNING state")

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index f7bb241b17ab..eece3e2eec14 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2313,7 +2313,6 @@ static int gbe_slave_open(struct gbe_intf *gbe_intf)
 		dev_dbg(priv->dev, "phy found: id is: 0x%s\n",
 			phydev_name(slave->phy));
 		phy_start(slave->phy);
-		phy_read_status(slave->phy);
 	}
 	return 0;
 }
@@ -3119,7 +3118,6 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 			dev_dbg(dev, "phy found: id is: 0x%s\n",
 				phydev_name(slave->phy));
 			phy_start(slave->phy);
-			phy_read_status(slave->phy);
 		}
 	}
 }
-- 
2.9.3
