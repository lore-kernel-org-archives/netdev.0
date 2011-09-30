From: David Daney <david.daney@cavium.com>
Subject: [PATCH] netdev/phy/icplus: Use mdiobus_write() and mdiobus_read() for proper locking.
Date: Fri, 30 Sep 2011 15:17:48 -0700
Message-ID: <1317421068-27278-1-git-send-email-david.daney@cavium.com>
Cc: linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	"Uwe Kleine-Konig" <u.kleine-koenig@pengutronix.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19162 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758111Ab1I3WSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 18:18:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually you have to take the bus lock.  Why not here too?

I saw this when working on something else.  Not even compile tested.

Signed-off-by: David Daney <david.daney@cavium.com>
Cc: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Cc: "Uwe Kleine-Konig" <u.kleine-koenig@pengutronix.de>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d4cbc29..bd4c740 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -42,36 +42,36 @@ static int ip175c_config_init(struct phy_device *phydev)
 	if (full_reset_performed == 0) {
 
 		/* master reset */
-		err = phydev->bus->write(phydev->bus, 30, 0, 0x175c);
+		err = mdiobus_write(phydev->bus, 30, 0, 0x175c);
 		if (err < 0)
 			return err;
 
 		/* ensure no bus delays overlap reset period */
-		err = phydev->bus->read(phydev->bus, 30, 0);
+		err = mdiobus_read(phydev->bus, 30, 0);
 
 		/* data sheet specifies reset period is 2 msec */
 		mdelay(2);
 
 		/* enable IP175C mode */
-		err = phydev->bus->write(phydev->bus, 29, 31, 0x175c);
+		err = mdiobus_write(phydev->bus, 29, 31, 0x175c);
 		if (err < 0)
 			return err;
 
 		/* Set MII0 speed and duplex (in PHY mode) */
-		err = phydev->bus->write(phydev->bus, 29, 22, 0x420);
+		err = mdiobus_write(phydev->bus, 29, 22, 0x420);
 		if (err < 0)
 			return err;
 
 		/* reset switch ports */
 		for (i = 0; i < 5; i++) {
-			err = phydev->bus->write(phydev->bus, i,
-						 MII_BMCR, BMCR_RESET);
+			err = mdiobus_write(phydev->bus, i,
+					    MII_BMCR, BMCR_RESET);
 			if (err < 0)
 				return err;
 		}
 
 		for (i = 0; i < 5; i++)
-			err = phydev->bus->read(phydev->bus, i, MII_BMCR);
+			err = mdiobus_read(phydev->bus, i, MII_BMCR);
 
 		mdelay(2);
 
-- 
1.7.2.3
