From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
Subject: [PATCH 2/2] gianfar: Use the same initial values as the phy layer
Date: Mon, 13 Feb 2017 13:22:09 +0100
Message-ID: <1486988529-24924-2-git-send-email-thomas.graziadei@omicronenergy.com>
References: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
To: <claudiu.manoil@freescale.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:45177 "EHLO ns.omicron.at"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751867AbdBMNIz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 08:08:55 -0500
In-Reply-To: <1486988529-24924-1-git-send-email-thomas.graziadei@omicronenergy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graziadei <thomas.graziadei@omicronenergy.com>

The phy layer sets the link status initially to 1 to also support phyless
systems, therefore we set the gianfar drivers initial link status also to
1. This prevents the gfar_update_link_state() method to be called when the
driver and phy have just been initialized but no link state change was
detected yet.

Signed-off-by: Thomas Graziadei <thomas.graziadei@omicronenergy.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index b3b5c43..be0d23e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1705,7 +1705,7 @@ static int gfar_restore(struct device *dev)
 
 	gfar_start(priv);
 
-	priv->oldlink = 0;
+	priv->oldlink = 1;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
@@ -1791,7 +1791,7 @@ static int init_phy(struct net_device *dev)
 	phy_interface_t interface;
 	struct phy_device *phydev;
 
-	priv->oldlink = 0;
+	priv->oldlink = 1;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
@@ -2212,7 +2212,7 @@ int startup_gfar(struct net_device *ndev)
 	gfar_start(priv);
 
 	/* force link state update after mac reset */
-	priv->oldlink = 0;
+	priv->oldlink = 1;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-- 
2.7.4
