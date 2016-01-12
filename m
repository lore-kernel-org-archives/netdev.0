From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2 -next] mdio: remove an unneed condition
Date: Tue, 12 Jan 2016 12:35:34 +0300
Message-ID: <20160112093534.GE29804@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38904 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761698AbcALJgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 04:36:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It used to be that mdio->irq was a pointer but after e7f4dc3536a4
('mdio: Move allocation of interrupts into core') it's an array inside
the mdio struct so it can never be NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index c0a8f84..86829f8 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -62,11 +62,9 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 	rc = irq_of_parse_and_map(child, 0);
 	if (rc > 0) {
 		phy->irq = rc;
-		if (mdio->irq)
-			mdio->irq[addr] = rc;
+		mdio->irq[addr] = rc;
 	} else {
-		if (mdio->irq)
-			phy->irq = mdio->irq[addr];
+		phy->irq = mdio->irq[addr];
 	}
 
 	if (of_property_read_bool(child, "broken-turn-around"))
