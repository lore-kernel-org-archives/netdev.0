From: David Miller <davem@davemloft.net>
Subject: [PATCH] Revert "drivers/net/phy/mdio-bitbang.c: Call
 mdiobus_unregister before mdiobus_free"
Date: Wed, 14 Nov 2012 22:34:56 -0500 (EST)
Message-ID: <20121114.223456.1921953379594013768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992461Ab2KODfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 22:35:02 -0500
Received: from localhost (cpe-66-108-117-132.nyc.res.rr.com [66.108.117.132])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BD0F258AB9E
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 19:34:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e.

As pointed out by Ben Hutchings, this change is not correct.

mdiobus_unregister() can't be called if the bus isn't registered yet,
however this change can result in situations which cause that to
happen.

Part of the confusion here revolves around the fact that the
callers of this module control registration/unregistration,
rather than the module itself.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/mdio-bitbang.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 6428fcb..daec9b0 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -234,7 +234,6 @@ void free_mdio_bitbang(struct mii_bus *bus)
 	struct mdiobb_ctrl *ctrl = bus->priv;
 
 	module_put(ctrl->ops->owner);
-	mdiobus_unregister(bus);
 	mdiobus_free(bus);
 }
 EXPORT_SYMBOL(free_mdio_bitbang);
-- 
1.7.11.7
