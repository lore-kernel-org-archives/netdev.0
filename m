From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/3] smsc75xx: eliminate unnecessary phy register read
Date: Fri,  4 May 2012 11:57:12 +0100
Message-ID: <1336129033-15826-3-git-send-email-steve.glendinning@shawell.net>
References: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:55616 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522Ab2EDK5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 06:57:20 -0400
In-Reply-To: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only a write is necessary to clear the interrupt status, and we
don't use the value from the preceding read operation.  This
patch eliminates the unnecessary read.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index ecab87b..72b62b5 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -508,9 +508,7 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 	u16 lcladv, rmtadv;
 	int ret;
 
-	/* read and write to clear phy interrupt status */
-	ret = smsc75xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
-	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	/* write to clear phy interrupt status */
 	smsc75xx_mdio_write(dev->net, mii->phy_id, PHY_INT_SRC,
 		PHY_INT_SRC_CLEAR_ALL);
 
-- 
1.7.9.5
