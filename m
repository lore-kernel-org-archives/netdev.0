From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 12/13] phylink: add in-band autonegotiation support for
 10GBase-KR mode.
Date: Tue, 25 Jul 2017 15:03:34 +0100
Message-ID: <E1da0Qw-0007MI-20@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50918 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752324AbdGYODh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:03:37 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add in-band autonegotation support for 10GBase-KR mode.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phylink.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index dc0f4d7b7dd2..32917bdd1432 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -266,6 +266,23 @@ static int phylink_parse_mode(struct phylink *pl, struct device_node *np)
 			pl->link_an_mode = MLO_AN_8023Z;
 			break;
 
+		case PHY_INTERFACE_MODE_10GKR:
+			phylink_set(pl->supported, 10baseT_Half);
+			phylink_set(pl->supported, 10baseT_Full);
+			phylink_set(pl->supported, 100baseT_Half);
+			phylink_set(pl->supported, 100baseT_Full);
+			phylink_set(pl->supported, 1000baseT_Half);
+			phylink_set(pl->supported, 1000baseT_Full);
+			phylink_set(pl->supported, 1000baseX_Full);
+			phylink_set(pl->supported, 10000baseKR_Full);
+			phylink_set(pl->supported, 10000baseCR_Full);
+			phylink_set(pl->supported, 10000baseSR_Full);
+			phylink_set(pl->supported, 10000baseLR_Full);
+			phylink_set(pl->supported, 10000baseLRM_Full);
+			phylink_set(pl->supported, 10000baseER_Full);
+			pl->link_an_mode = MLO_AN_SGMII;
+			break;
+
 		default:
 			netdev_err(pl->netdev,
 				   "incorrect link mode %s for in-band status\n",
-- 
2.7.4
