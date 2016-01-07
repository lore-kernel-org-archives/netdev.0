From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: ethernet-rgmii.c: Fix breakage from moving phdev bus
Date: Thu,  7 Jan 2016 21:55:52 +0100
Message-ID: <1452200152-15793-3-git-send-email-andrew@lunn.ch>
References: <1452200152-15793-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43512 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbcAGU4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 15:56:21 -0500
In-Reply-To: <1452200152-15793-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mdio device patches moved the bus member in phy_device into a
substructure. This driver got missed. Fix it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/staging/octeon/ethernet-rgmii.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index 613344b886e1..1055ee14b66a 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -78,7 +78,7 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 		 */
 		spin_lock_irqsave(&global_register_lock, flags);
 	} else {
-		mutex_lock(&priv->phydev->bus->mdio_lock);
+		mutex_lock(&priv->phydev->mdio.bus->mdio_lock);
 	}
 
 	link_info = cvmx_helper_link_get(priv->port);
@@ -113,7 +113,7 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 		if (use_global_register_lock)
 			spin_unlock_irqrestore(&global_register_lock, flags);
 		else
-			mutex_unlock(&priv->phydev->bus->mdio_lock);
+			mutex_unlock(&priv->phydev->mdio.bus->mdio_lock);
 		return;
 	}
 
@@ -132,7 +132,7 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 	if (use_global_register_lock)
 		spin_unlock_irqrestore(&global_register_lock, flags);
 	else
-		mutex_unlock(&priv->phydev->bus->mdio_lock);
+		mutex_unlock(&priv->phydev->mdio.bus->mdio_lock);
 
 	if (priv->phydev == NULL) {
 		/* Tell core. */
-- 
2.6.4
