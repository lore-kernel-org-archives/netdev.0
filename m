From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc3] sundance: include MII address 0 in PHY probe
Date: Wed, 19 Oct 2005 08:07:34 -0400
Message-ID: <10192005080734.15936@bilbo.tuxdriver.com>
References: <20051019120022.GA15438@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750840AbVJSMHp@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20051019120022.GA15438@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include MII address 0 at the end of the PHY scan.  This covers the
entire range of possible MII addresses.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/sundance.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -608,16 +608,17 @@ static int __devinit sundance_probe1 (st
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
-	for (phy = 1; phy < 32 && phy_idx < MII_CNT; phy++) {
+	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
 		int mii_status = mdio_read(dev, phy, MII_BMSR);
+		int phyx = phy & 0x1f;
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
-			np->phys[phy_idx++] = phy;
-			np->mii_if.advertising = mdio_read(dev, phy, MII_ADVERTISE);
+			np->phys[phy_idx++] = phyx;
+			np->mii_if.advertising = mdio_read(dev, phyx, MII_ADVERTISE);
 			if ((mii_status & 0x0040) == 0)
 				np->mii_preamble_required++;
 			printk(KERN_INFO "%s: MII PHY found at address %d, status "
 				   "0x%4.4x advertising %4.4x.\n",
-				   dev->name, phy, mii_status, np->mii_if.advertising);
+				   dev->name, phyx, mii_status, np->mii_if.advertising);
 		}
 	}
 	np->mii_preamble_required--;
