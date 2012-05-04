From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/3] smsc75xx: replace 0xffff with PHY_INT_SRC_CLEAR_ALL
Date: Fri,  4 May 2012 11:57:11 +0100
Message-ID: <1336129033-15826-2-git-send-email-steve.glendinning@shawell.net>
References: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:55616 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab2EDK5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 06:57:20 -0400
In-Reply-To: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines PHY_INT_SRC_CLEAR_ALL to replace the value 0xffff
in order to be more self-documenting.

This patch should make no functional change, it is purely cosmetic.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    3 ++-
 drivers/net/usb/smsc75xx.h |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 00103a8..ecab87b 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -511,7 +511,8 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 	/* read and write to clear phy interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
 	check_warn_return(ret, "Error reading PHY_INT_SRC");
-	smsc75xx_mdio_write(dev->net, mii->phy_id, PHY_INT_SRC, 0xffff);
+	smsc75xx_mdio_write(dev->net, mii->phy_id, PHY_INT_SRC,
+		PHY_INT_SRC_CLEAR_ALL);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	check_warn_return(ret, "Error writing INT_STS");
diff --git a/drivers/net/usb/smsc75xx.h b/drivers/net/usb/smsc75xx.h
index 16e98c7..67eba39 100644
--- a/drivers/net/usb/smsc75xx.h
+++ b/drivers/net/usb/smsc75xx.h
@@ -388,6 +388,7 @@
 #define PHY_INT_SRC_ANEG_COMP		((u16)0x0040)
 #define PHY_INT_SRC_REMOTE_FAULT	((u16)0x0020)
 #define PHY_INT_SRC_LINK_DOWN		((u16)0x0010)
+#define PHY_INT_SRC_CLEAR_ALL		((u16)0xffff)
 
 #define PHY_INT_MASK			(30)
 #define PHY_INT_MASK_ENERGY_ON		((u16)0x0080)
-- 
1.7.9.5
