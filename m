From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] phylib: phy_mii_ioctl() fixes
Date: Thu, 18 Sep 2008 15:06:52 +0200
Message-ID: <20080918130652.GA10552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:45876 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbYIRNGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 09:06:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the SIOCGMIIPHY case fall through properly (it is supposed
to not only return the ID of the default PHY but also to read from
that PHY), and make phy_mii_ioctl() return the same error code as
generic_mii_ioctl() in case of an unsupported operation.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6/drivers/net/phy/phy.c
===================================================================
--- linux-2.6.orig/drivers/net/phy/phy.c
+++ linux-2.6/drivers/net/phy/phy.c
@@ -411,7 +411,8 @@ int phy_mii_ioctl(struct phy_device *phy
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		mii_data->phy_id = phydev->addr;
-		break;
+		/* fall through */
+
 	case SIOCGMIIREG:
 		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
 		break;
@@ -458,7 +459,7 @@ int phy_mii_ioctl(struct phy_device *phy
 		break;
 
 	default:
-		return -ENOTTY;
+		return -EOPNOTSUPP;
 	}
 
 	return 0;
