From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 4/4] net: dsa: bcm_sf2: Remove special handling of "internal" phy-mode
Date: Fri, 23 Jun 2017 10:31:35 -0700
Message-ID: <20170623173135.22912-5-f.fainelli@gmail.com>
References: <20170623173135.22912-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel@vger.kernel.org (open list),
        david.wu@rock-chips.com, opendmb@gmail.com
To: netdev@ver.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34335 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbdFWRca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:32:30 -0400
In-Reply-To: <20170623173135.22912-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library now supports an "internal" phy-mode, thus making our
custom parsing code now unnecessary.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 76e98e8ed315..648f91b58d1e 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -498,10 +498,8 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 				   struct device_node *dn)
 {
 	struct device_node *port;
-	const char *phy_mode_str;
 	int mode;
 	unsigned int port_num;
-	int ret;
 
 	priv->moca_port = -1;
 
@@ -515,15 +513,11 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 		 * time
 		 */
 		mode = of_get_phy_mode(port);
-		if (mode < 0) {
-			ret = of_property_read_string(port, "phy-mode",
-						      &phy_mode_str);
-			if (ret < 0)
-				continue;
-
-			if (!strcasecmp(phy_mode_str, "internal"))
-				priv->int_phy_mask |= 1 << port_num;
-		}
+		if (mode < 0)
+			continue;
+
+		if (mode == PHY_INTERFACE_MODE_INTERNAL)
+			priv->int_phy_mask |= 1 << port_num;
 
 		if (mode == PHY_INTERFACE_MODE_MOCA)
 			priv->moca_port = port_num;
-- 
2.9.3
