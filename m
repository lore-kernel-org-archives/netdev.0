From: Roger Luethi <rl@hellgate.ch>
Subject: [2/3] via-rhine: de-isolate PHY
Date: Sun, 8 Aug 2004 16:02:59 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040808140259.GA8575@k3.hellgate.ch>
References: <20040808140216.GA8181@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265772AbUHHQRY@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040808140216.GA8181@k3.hellgate.ch>
List-Id: netdev.vger.kernel.org

PHYs may come up isolated. Make sure we can send data to them. This code
section needs a clean-up, but I prefer to merge this fix in isolation.

Report and suggested fix by Tam, Ming Dat (Tommy).

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- linux-2.6.8-rc3-mm1/drivers/net/via-rhine.c.01	2004-08-08 12:36:03.440855262 +0200
+++ linux-2.6.8-rc3-mm1/drivers/net/via-rhine.c	2004-08-08 13:15:24.527527919 +0200
@@ -896,7 +896,10 @@ static int __devinit rhine_init_one(stru
 	pci_set_drvdata(pdev, dev);
 
 	{
+		u16 mii_cmd;
 		int mii_status = mdio_read(dev, phy_id, 1);
+		mii_cmd = mdio_read(dev, phy_id, MII_BMCR) & ~BMCR_ISOLATE;
+		mdio_write(dev, phy_id, MII_BMCR, mii_cmd);
 		if (mii_status != 0xffff && mii_status != 0x0000) {
 			rp->mii_if.advertising = mdio_read(dev, phy_id, 4);
 			printk(KERN_INFO "%s: MII PHY found at address "
