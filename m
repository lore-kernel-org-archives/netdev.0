From: Matei Pavaluca <matei.pavaluca@freescale.com>
Subject: [PATCH net-next 1/3] gianfar: Add flow control support flags
Date: Thu, 23 Oct 2014 10:57:55 +0300
Message-ID: <1414051077-4330-1-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Pavaluca Matei <matei.pavaluca@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0141.outbound.protection.outlook.com ([207.46.100.141]:29685
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752216AbaJWIbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2014 04:31:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavaluca Matei <matei.pavaluca@freescale.com>

The phy device supports 802.3x flow control, but the specific flags are not set
in the phy initialisation code. Flow control flags need to be added to the
supported capabilities of the phydev by the driver.

This is needed in order for ethtool to work ('ethtool -A' code checks for these
flags)

Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 3 +++
 drivers/net/ethernet/freescale/gianfar.h | 4 +---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4fdf0aa..2485b74 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1687,6 +1687,9 @@ static int init_phy(struct net_device *dev)
 	priv->phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
 	priv->phydev->advertising = priv->phydev->supported;
 
+	/* Add support for flow control, but don't advertise it by default */
+	priv->phydev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 2805cfb..6b00868 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -145,9 +145,7 @@ extern const char gfar_driver_version[];
 		| SUPPORTED_Autoneg \
 		| SUPPORTED_MII)
 
-#define GFAR_SUPPORTED_GBIT (SUPPORTED_1000baseT_Full \
-		| SUPPORTED_Pause \
-		| SUPPORTED_Asym_Pause)
+#define GFAR_SUPPORTED_GBIT SUPPORTED_1000baseT_Full
 
 /* TBI register addresses */
 #define MII_TBICON		0x11
-- 
1.7.11.7
