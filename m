From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH 1/4] net: dsa: mv88e6xxx: Allow mv88e6xxx_smi_init() to be used at address 0x1
Date: Mon, 19 Dec 2016 15:16:06 +0100
Message-ID: <20161219141610.30934-2-romain.perier@free-electrons.com>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
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
Received: from mail.free-electrons.com ([62.4.15.54]:45042 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755498AbcLSOQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 09:16:18 -0500
In-Reply-To: <20161219141610.30934-1-romain.perier@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the function mv88e6xxx_smi_init() returns -EINVAL if the bit
zero of sw_addr is 0x1. However, on some platforms, ethernet switches
are configured in Multi chip addressing mode and available at MDIO
address 0x1.

Signed-off-by: Romain Perier <romain.perier@free-electrons.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f7222dc..b5f0e1e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4240,10 +4240,6 @@ static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
-	/* ADDR[0] pin is unavailable externally and considered zero */
-	if (sw_addr & 0x1)
-		return -EINVAL;
-
 	if (sw_addr == 0)
 		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
 	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_MULTI_CHIP))
-- 
2.9.3
