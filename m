From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Mark carrier-off before starting PHY
Date: Wed, 25 Jun 2008 11:41:01 +0900 (JST)
Message-ID: <20080625.114101.102912128.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Call netif_carrier_off() before starting PHY device.  This is a
behavior before converting to generic PHY layer.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 10e4e85..dccea52 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1394,6 +1394,7 @@ tc35815_open(struct net_device *dev)
 	tc35815_chip_init(dev);
 	spin_unlock_irq(&lp->lock);
 
+	netif_carrier_off(dev);
 	/* schedule a link state check */
 	phy_start(lp->phy_dev);
 
@@ -2453,6 +2454,7 @@ static int tc35815_resume(struct pci_dev *pdev)
 		return 0;
 	pci_set_power_state(pdev, PCI_D0);
 	tc35815_restart(dev);
+	netif_carrier_off(dev);
 	if (lp->phy_dev)
 		phy_start(lp->phy_dev);
 	netif_device_attach(dev);
