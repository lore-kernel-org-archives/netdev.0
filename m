From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 1/2] phy: fix blackfin build failure
Date: Fri,  8 Jan 2016 16:58:14 +0530
Message-ID: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The build of blackfin defconfig is failing with the error:
error: 'struct mii_bus' has no member named 'phy_map'

A new API mdiobus_get_phy() was introduced and phy_map was removed but
it was not changed here.

Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus.")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

build log of next-20160108 is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/101006125

 drivers/net/ethernet/adi/bfin_mac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 6286274..6f3432a 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -398,7 +398,8 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 
 	/* search for connected PHY device */
 	for (i = 0; i < PHY_MAX_ADDR; ++i) {
-		struct phy_device *const tmp_phydev = lp->mii_bus->phy_map[i];
+		struct phy_device *const tmp_phydev =
+			mdiobus_get_phy(lp->mii_bus, i);
 
 		if (!tmp_phydev)
 			continue; /* no PHY here... */
-- 
1.9.1
