From: Sylvain Lemieux <slemieux.tyco@gmail.com>
Subject: [PATCH] net: dsa: mv88e6xxx: fix mdio bus name when using devicetree
Date: Mon,  1 May 2017 10:54:04 -0400
Message-ID: <20170501145404.18581-1-slemieux.tyco@gmail.com>
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35729 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035402AbdEAOyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:54:17 -0400
Received: by mail-io0-f195.google.com with SMTP id d203so22507493iof.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 07:54:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liam Beguin <lbeguin@tycoint.com>

mv88e6xxx_mdio_register automatically generates mdio buses for each switch
discovered in the devicetree. When switch nodes are embedded in other nodes,
this can cause sysfs naming collisions since full_name may be truncated.

Only use devicetree node name instead of the full devicetree path
as the mdio bus name.

Signed-off-by: Liam Beguin <lbeguin@tycoint.com>
Signed-off-by: Alexandre Messier <amessier@tycoint.com>
Signed-off-by: Sylvain Lemieux <slemieux@tycoint.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 3354f99df378..80b4387d573e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2688,8 +2688,8 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 	mdio_bus->external = external;
 
 	if (np) {
-		bus->name = np->full_name;
-		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
+		bus->name = np->name;
+		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->name);
 	} else {
 		bus->name = "mv88e6xxx SMI";
 		snprintf(bus->id, MII_BUS_ID_SIZE, "mv88e6xxx-%d", index++);
-- 
2.11.0
