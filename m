From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] of/mdio: fix fixed link bus name
Date: Mon, 27 Feb 2012 14:48:46 +0200
Message-ID: <8ebe6a3f11343c392a7353581d5f648980206e8e.1330346765.git.baruch@tkos.co.il>
Cc: devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Baruch Siach <baruch@tkos.co.il>
To: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:47897 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab2B0MuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 07:50:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 9e6c643b (phy/fixed: use an unique MDIO bus name) the name of the fixed
PHY bus is "fixed-0". Teach of_phy_connect_fixed_link() the new name.

Tested on a P1020RDB PowerPC system.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/of/of_mdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 980c079..483c0ad 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -182,7 +182,7 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 	if (!phy_id || sz < sizeof(*phy_id))
 		return NULL;
 
-	sprintf(bus_id, PHY_ID_FMT, "0", be32_to_cpu(phy_id[0]));
+	sprintf(bus_id, PHY_ID_FMT, "fixed-0", be32_to_cpu(phy_id[0]));
 
 	phy = phy_connect(dev, bus_id, hndlr, 0, iface);
 	return IS_ERR(phy) ? NULL : phy;
-- 
1.7.9
