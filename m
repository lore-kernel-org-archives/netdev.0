From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 6/7] smsc75xx: declare smsc75xx's MII as GMII capable
Date: Mon, 30 Apr 2012 18:56:55 +0100
Message-ID: <1335808616-22513-7-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab2D3R5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:15 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also explicitly set the phy to advertise 1000 speeds

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 4941782..ae23d85 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -652,6 +652,7 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 	dev->mii.mdio_write = smsc75xx_mdio_write;
 	dev->mii.phy_id_mask = 0x1f;
 	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.supports_gmii = 1;
 	dev->mii.phy_id = SMSC75XX_INTERNAL_PHY_ID;
 
 	/* reset phy and wait for reset to complete */
@@ -672,6 +673,8 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
 		ADVERTISE_PAUSE_ASYM);
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
+		ADVERTISE_1000FULL);
 
 	/* read and write to clear phy interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-- 
1.7.9.5
