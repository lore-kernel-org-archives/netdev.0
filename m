From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/7] smsc75xx: fix mdio reads and writes
Date: Mon, 30 Apr 2012 18:56:51 +0100
Message-ID: <1335808616-22513-3-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab2D3R5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:12 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc75xx needs MII_ACCESS_BUSY to be set to correctly trigger mdio I/O.  Note smsc75xx is different from smsc95xx in this regard.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index b1b4649..f97207a 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -171,7 +171,7 @@ static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	idx &= dev->mii.reg_num_mask;
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
-		| MII_ACCESS_READ;
+		| MII_ACCESS_READ | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
@@ -210,7 +210,7 @@ static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	idx &= dev->mii.reg_num_mask;
 	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
 		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
-		| MII_ACCESS_WRITE;
+		| MII_ACCESS_WRITE | MII_ACCESS_BUSY;
 	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
 	check_warn_goto_done(ret, "Error writing MII_ACCESS");
 
-- 
1.7.9.5
