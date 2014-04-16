From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH net-next RESEND 2/2] net: phy: at803x: use genphy_config_init()
Date: Wed, 16 Apr 2014 17:19:13 +0200
Message-ID: <1397661553-22117-2-git-send-email-zonque@gmail.com>
References: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, ujhelyi.m@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:53367 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161706AbaDPPTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 11:19:36 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so8973588eek.36
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 08:19:35 -0700 (PDT)
In-Reply-To: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the generic bits from genphy_config_init() instead of implementing
the same functionality again.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
Resending this after 3.15-rc1 has been released, assuming that the
net-next tree is now open again.

 drivers/net/phy/at803x.c | 36 +++---------------------------------
 1 file changed, 3 insertions(+), 33 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index bc71947..850171f 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -141,41 +141,11 @@ static int at803x_resume(struct phy_device *phydev)
 
 static int at803x_config_init(struct phy_device *phydev)
 {
-	int val;
 	int ret;
-	u32 features;
-
-	features = SUPPORTED_TP | SUPPORTED_MII | SUPPORTED_AUI |
-		   SUPPORTED_FIBRE | SUPPORTED_BNC;
-
-	val = phy_read(phydev, MII_BMSR);
-	if (val < 0)
-		return val;
-
-	if (val & BMSR_ANEGCAPABLE)
-		features |= SUPPORTED_Autoneg;
-	if (val & BMSR_100FULL)
-		features |= SUPPORTED_100baseT_Full;
-	if (val & BMSR_100HALF)
-		features |= SUPPORTED_100baseT_Half;
-	if (val & BMSR_10FULL)
-		features |= SUPPORTED_10baseT_Full;
-	if (val & BMSR_10HALF)
-		features |= SUPPORTED_10baseT_Half;
-
-	if (val & BMSR_ESTATEN) {
-		val = phy_read(phydev, MII_ESTATUS);
-		if (val < 0)
-			return val;
-
-		if (val & ESTATUS_1000_TFULL)
-			features |= SUPPORTED_1000baseT_Full;
-		if (val & ESTATUS_1000_THALF)
-			features |= SUPPORTED_1000baseT_Half;
-	}
 
-	phydev->supported = features;
-	phydev->advertising = features;
+	ret = genphy_config_init(phydev);
+	if (ret < 0)
+		return ret;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
 		ret = phy_write(phydev, AT803X_DEBUG_ADDR,
-- 
1.9.0
