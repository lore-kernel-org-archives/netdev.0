From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: gianfar: Fix use-after-of_node_put() in
 gfar_of_init().
Date: Sun, 29 Mar 2009 03:18:40 -0700 (PDT)
Message-ID: <20090329.031840.226764148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754378AbZC2KSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:18:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9A82AC8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:18:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can't put 'mdio' until after we've used it in the
fsl_pq_mdio_bus_name() call.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6a38800..65f5587 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -289,9 +289,9 @@ static int gfar_of_init(struct net_device *dev)
 		id = of_get_property(phy, "reg", NULL);
 
 		of_node_put(phy);
-		of_node_put(mdio);
 
 		fsl_pq_mdio_bus_name(bus_name, mdio);
+		of_node_put(mdio);
 		snprintf(priv->phy_bus_id, sizeof(priv->phy_bus_id), "%s:%02x",
 				bus_name, *id);
 	}
-- 
1.6.2.1.222.g570cc

