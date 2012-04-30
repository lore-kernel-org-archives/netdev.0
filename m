From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 4/7] smsc75xx: fix phy init reset loop
Date: Mon, 30 Apr 2012 18:56:53 +0100
Message-ID: <1335808616-22513-5-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab2D3R5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:14 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix bug in phy_init loop that was ignoring BMCR reset bit, akin to smsc95xx's d946092000698fd204d82a9d239103c656fb63bf

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1de7785..cc23a58 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -661,7 +661,7 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 		bmcr = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
 		check_warn_return(bmcr, "Error reading MII_BMCR");
 		timeout++;
-	} while ((bmcr & MII_BMCR) && (timeout < 100));
+	} while ((bmcr & BMCR_RESET) && (timeout < 100));
 
 	if (timeout >= 100) {
 		netdev_warn(dev->net, "timeout on PHY Reset");
-- 
1.7.9.5
