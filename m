From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: mv643xx_eth: potential NULL dereference in probe()
Date: Wed, 13 Nov 2013 10:52:47 +0300
Message-ID: <20131113075247.GI25541@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We assume that "mp->phy" can be NULL a couple lines before the
dereference.

Fixes: 1cce16d37d0f ('net: mv643xx_eth: Add missing phy_addr_set in DT mode')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 00cd36e..e7905d9 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2890,7 +2890,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 					 PHY_INTERFACE_MODE_GMII);
 		if (!mp->phy)
 			err = -ENODEV;
-		phy_addr_set(mp, mp->phy->addr);
+		else
+			phy_addr_set(mp, mp->phy->addr);
 	} else if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
 		mp->phy = phy_scan(mp, pd->phy_addr);
 
