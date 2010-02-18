From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/12] tg3: Discover phy address once
Date: Wed, 17 Feb 2010 17:17:01 -0800
Message-ID: <1266455825-16150-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3248 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab0BRBR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy address will not change after it has been identified.  Move the
discovery code to a location that only gets executed once.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c38143b..3a62cc5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1035,6 +1035,17 @@ static void tg3_mdio_start(struct tg3 *tp)
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
 
+	if ((tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		tg3_mdio_config_5785(tp);
+}
+
+static int tg3_mdio_init(struct tg3 *tp)
+{
+	int i;
+	u32 reg;
+	struct phy_device *phydev;
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
 		u32 funcnum, is_serdes;
 
@@ -1054,17 +1065,6 @@ static void tg3_mdio_start(struct tg3 *tp)
 	} else
 		tp->phy_addr = TG3_PHY_MII_ADDR;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
-		tg3_mdio_config_5785(tp);
-}
-
-static int tg3_mdio_init(struct tg3 *tp)
-{
-	int i;
-	u32 reg;
-	struct phy_device *phydev;
-
 	tg3_mdio_start(tp);
 
 	if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) ||
-- 
1.6.4.4


