From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next v7 07/12] drivers: net: xgene: Enable MDIO driver
Date: Mon, 25 Jul 2016 17:12:42 -0700
Message-ID: <1469491967-28627-8-git-send-email-isubramanian@apm.com>
References: <1469491967-28627-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469491967-28627-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch enables MDIO driver by,

- Selecting MDIO_XGENE
- Changed open and close to use phy_start and phy_stop
- Changed to use mac_ops->tx(rx)_enable and tx(rx)_disable

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/Kconfig           | 1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 8 ++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
index 19e38af..300e3b5 100644
--- a/drivers/net/ethernet/apm/xgene/Kconfig
+++ b/drivers/net/ethernet/apm/xgene/Kconfig
@@ -3,6 +3,7 @@ config NET_XGENE
 	depends on HAS_DMA
 	depends on ARCH_XGENE || COMPILE_TEST
 	select PHYLIB
+	select MDIO_XGENE
 	help
 	  This is the Ethernet driver for the on-chip ethernet interface on the
 	  APM X-Gene SoC.
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index b8b643f..27a7a1c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -794,13 +794,13 @@ static void xgene_enet_adjust_link(struct net_device *ndev)
 		if (pdata->phy_speed != phydev->speed) {
 			pdata->phy_speed = phydev->speed;
 			mac_ops->set_speed(pdata);
-			xgene_gmac_rx_enable(pdata);
-			xgene_gmac_tx_enable(pdata);
+			mac_ops->rx_enable(pdata);
+			mac_ops->tx_enable(pdata);
 			phy_print_status(phydev);
 		}
 	} else {
-		xgene_gmac_rx_disable(pdata);
-		xgene_gmac_tx_disable(pdata);
+		mac_ops->rx_disable(pdata);
+		mac_ops->tx_disable(pdata);
 		pdata->phy_speed = SPEED_UNKNOWN;
 		phy_print_status(phydev);
 	}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6398337..d1d6b5e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -739,9 +739,9 @@ static int xgene_enet_open(struct net_device *ndev)
 	if (ret)
 		return ret;
 
-	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+	if (pdata->phy_dev) {
 		phy_start(pdata->phy_dev);
-	else {
+	} else {
 		schedule_delayed_work(&pdata->link_work, PHY_POLL_LINK_OFF);
 		netif_carrier_off(ndev);
 	}
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
