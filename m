From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/3] net: sxgbe: sxgbe_mdio_register() frees the bus
Date: Tue, 1 Apr 2014 16:38:44 +0300
Message-ID: <20140401133844.GA11536@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Girish K S <ks.giri@samsung.com>,
	Siva Reddy Kallam <siva.kallam@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25993 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaDANiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 09:38:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"err" is always zero at this point so we always unregister and free the
mdio_bus before returning success.  This seems like left over code and
I have deleted it.

Fixes: 1edb9ca69e8a ('net: sxgbe: add basic framework for Samsung 10Gb ethernet driver')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Static analysis.  Untested.

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
index b0eb0a2..01af2cb 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
@@ -219,13 +219,6 @@ int sxgbe_mdio_register(struct net_device *ndev)
 		}
 	}
 
-	if (!err) {
-		netdev_err(ndev, "PHY not found\n");
-		mdiobus_unregister(mdio_bus);
-		mdiobus_free(mdio_bus);
-		goto mdiobus_err;
-	}
-
 	priv->mii = mdio_bus;
 
 	return 0;
