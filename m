From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: driver-core tree build failure
Date: Sun, 22 Mar 2009 23:22:37 +1100
Message-ID: <20090322232237.1db2e976.sfr@canb.auug.org.au>
References: <20090316204703.f2f354f9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090316204703.f2f354f9.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg, Dave,

On Mon, 16 Mar 2009 20:47:03 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Dave, this could apply to net-current (or net after you merge
> net-current) or Greg could put it in driver-core after net-current gets
> merged into Linus' tree.

The dnet driver is now upstream, so can one of you add this to your tree,
please?  Apologies if I missed it.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 16 Mar 2009 20:37:10 +1100
Subject: [PATCH] net: update dnet.c for bus_id removal

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/dnet.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 5c347f7..1b40632 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -280,11 +280,11 @@ static int dnet_mii_probe(struct net_device *dev)
 
 	/* attach the mac to the phy */
 	if (bp->capabilities & DNET_HAS_RMII) {
-		phydev = phy_connect(dev, phydev->dev.bus_id,
+		phydev = phy_connect(dev, dev_name(&phydev->dev),
 				     &dnet_handle_link_change, 0,
 				     PHY_INTERFACE_MODE_RMII);
 	} else {
-		phydev = phy_connect(dev, phydev->dev.bus_id,
+		phydev = phy_connect(dev, dev_name(&phydev->dev),
 				     &dnet_handle_link_change, 0,
 				     PHY_INTERFACE_MODE_MII);
 	}
@@ -927,7 +927,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 	phydev = bp->phy_dev;
 	dev_info(&pdev->dev, "attached PHY driver [%s] "
 	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+	       phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
 
 	return 0;
 
-- 
1.6.2



-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
