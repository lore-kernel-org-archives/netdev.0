From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/8] net: bcmgenet: remove PHY_BRCM_100MBPS_WAR
Date: Fri, 19 Sep 2014 13:07:52 -0700
Message-ID: <1411157276-18260-5-git-send-email-f.fainelli@gmail.com>
References: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:42854 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330AbaISUIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:08:18 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so575420pdb.10
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:08:17 -0700 (PDT)
In-Reply-To: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have removed the need for the PHY_BRCM_100MBPS_WAR flag, we
can remove it from the GENET driver and the broadcom shared header file.
The PHY driver checks the PHY supported bitmask instead.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 10 ----------
 include/linux/brcmphy.h                      |  1 -
 2 files changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index c88f7ae99636..71f2ef7d33a9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -296,7 +296,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct phy_device *phydev;
-	unsigned int phy_flags;
 	int ret;
 
 	if (priv->phydev) {
@@ -338,15 +337,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 		return ret;
 	}
 
-	phy_flags = PHY_BRCM_100MBPS_WAR;
-
-	/* workarounds are only needed for 100Mpbs PHYs, and
-	 * never on GENET V1 hardware
-	 */
-	if ((phydev->supported & PHY_GBIT_FEATURES) || GENET_IS_V1(priv))
-		phy_flags = 0;
-
-	phydev->dev_flags |= phy_flags;
 	phydev->advertising = phydev->supported;
 
 	/* The internal PHY has its link interrupts routed to the
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index e4ee9c6679e8..3f626fe48c9a 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -40,7 +40,6 @@
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
 /* Broadcom BCM7xxx specific workarounds */
-#define PHY_BRCM_100MBPS_WAR		0x00010000
 #define PHY_BRCM_7XXX_REV(x)		(((x) >> 8) & 0xff)
 #define PHY_BRCM_7XXX_PATCH(x)		((x) & 0xff)
 #define PHY_BCM_FLAGS_VALID		0x80000000
-- 
1.9.1
