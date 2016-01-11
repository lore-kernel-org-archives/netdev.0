From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 11 Jan 2016 13:46:15 +1100
Message-ID: <20160111134615.60c08c54@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>,
	Roosen Henri <Henri.Roosen@ginzinger.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

drivers/net/phy/micrel.c: In function 'ksz9031_config_init':
drivers/net/phy/micrel.c:492:22: error: 'struct phy_device' has no member named 'dev'
  dev_walker = &phydev->dev;
                      ^

Caused by commit

  e5a03bfd873c ("phy: Add an mdio_device structure")

interacting with commit

  b4c19f71252e ("phy: micrel: Fix finding PHY properties in MAC node for KSZ9031.")

from the net tree.

I applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 11 Jan 2016 13:25:09 +1100
Subject: [PATCH] phy: micrel: fix up for "phy: Add an mdio_device structure"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/phy/micrel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 41b598548f2e..03833dbfca67 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -489,7 +489,7 @@ static int ksz9031_config_init(struct phy_device *phydev)
 	 * properties in the MAC node. Walk up the tree of devices to
 	 * find a device with an OF node.
 	 */
-	dev_walker = &phydev->dev;
+	dev_walker = &phydev->mdio.dev;
 	do {
 		of_node = dev_walker->of_node;
 		dev_walker = dev_walker->parent;
-- 
2.6.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
