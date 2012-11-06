From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc95xx: set MII_BUSY bit to read/write PHY regs
Date: Tue,  6 Nov 2012 10:08:53 +0000
Message-ID: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:50632 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab2KFKI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 05:08:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device datasheet specifies the BUSY bit must be set when reading
or writing phy registers.  This patch ensures we do that.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 34f2e78..69efe66 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -167,7 +167,7 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	/* set the address, index & direction (read from PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
-	addr = (phy_id << 11) | (idx << 6) | MII_READ_;
+	addr = (phy_id << 11) | (idx << 6) | MII_READ_ | MII_BUSY_;
 	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
 	check_warn_goto_done(ret, "Error writing MII_ADDR");
 
@@ -204,7 +204,7 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	/* set the address, index & direction (write to PHY) */
 	phy_id &= dev->mii.phy_id_mask;
 	idx &= dev->mii.reg_num_mask;
-	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_;
+	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_ | MII_BUSY_;
 	ret = smsc95xx_write_reg(dev, MII_ADDR, addr);
 	check_warn_goto_done(ret, "Error writing MII_ADDR");
 
-- 
1.7.10.4
