From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH 2/2] fec: Cleanup PHY probing
Date: Wed, 2 Jun 2010 19:17:00 +0000
Message-ID: <20100602191700.GA22351@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:41238 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932501Ab0FBTRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 15:17:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup PHY probing: use helpers from phylib

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/fec.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index edfff92..c107d8e 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -679,30 +679,24 @@ static int fec_enet_mii_probe(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct phy_device *phy_dev = NULL;
-	int phy_addr;
+	int ret;
 
 	fep->phy_dev = NULL;
 
 	/* find the first phy */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (fep->mii_bus->phy_map[phy_addr]) {
-			phy_dev = fep->mii_bus->phy_map[phy_addr];
-			break;
-		}
-	}
-
+	phy_dev = phy_find_first(fep->mii_bus);
 	if (!phy_dev) {
 		printk(KERN_ERR "%s: no PHY found\n", dev->name);
 		return -ENODEV;
 	}
 
 	/* attach the mac to the phy */
-	phy_dev = phy_connect(dev, dev_name(&phy_dev->dev),
+	ret = phy_connect_direct(dev, phy_dev,
 			     &fec_enet_adjust_link, 0,
 			     PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(phy_dev)) {
+	if (ret) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phy_dev);
+		return ret;
 	}
 
 	/* mask with MAC supported features */
