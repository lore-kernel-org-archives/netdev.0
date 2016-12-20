From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH v2 1/3] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >= num_of_ports
Date: Tue, 20 Dec 2016 09:51:36 +0100
Message-ID: <20161220085138.3998-2-romain.perier@free-electrons.com>
References: <20161220085138.3998-1-romain.perier@free-electrons.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Romain Perier <romain.perier@free-electrons.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:32848 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753990AbcLTIwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 03:52:20 -0500
In-Reply-To: <20161220085138.3998-1-romain.perier@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Marvell ethernet switches have internal ethernet transceivers with
hardcoded phy addresses. These addresses can be greater than the number
of ports or its value might be different than the associated port number.
This is for example the case for MV88E6341 that has 6 ports and internal
Port 1 to Port4 PHYs mapped at SMI addresses from 0x11 to 0x14.

This commits fixes the issue by removing the condition in MDIO callbacks.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---

Changes in v2:
 - Added tag "Reviewed-by" by Andrew
 - Fixed typo in the commit log

 drivers/net/dsa/mv88e6xxx/chip.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b5f0e1e..76d944e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2881,9 +2881,6 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	u16 val;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_phy_read(chip, phy, reg, &val);
 	mutex_unlock(&chip->reg_lock);
@@ -2896,9 +2893,6 @@ static int mv88e6xxx_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	struct mv88e6xxx_chip *chip = bus->priv;
 	int err;
 
-	if (phy >= mv88e6xxx_num_ports(chip))
-		return 0xffff;
-
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_phy_write(chip, phy, reg, val);
 	mutex_unlock(&chip->reg_lock);
-- 
2.9.3
