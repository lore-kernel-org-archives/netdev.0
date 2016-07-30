From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next 01/10] drivers: net: xgene: Fix kbuild warning
Date: Fri, 29 Jul 2016 17:33:54 -0700
Message-ID: <1469838843-19943-2-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the following kbuild warning, when ACPI was not enabled.

>> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:878:23: warning: 'phy_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
     phy_dev->advertising = phy_dev->supported;

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 7714b7d..b6bc6fa 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -776,15 +776,11 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return -ENODEV;
 		}
-
-		pdata->phy_dev = phy_dev;
 	} else {
 #ifdef CONFIG_ACPI
 		struct acpi_device *adev = acpi_phy_find_device(dev);
 		if (adev)
-			pdata->phy_dev =  adev->driver_data;
-
-		phy_dev = pdata->phy_dev;
+			phy_dev =  adev->driver_data;
 
 		if (!phy_dev ||
 		    phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
@@ -795,6 +791,7 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 #endif
 	}
 
+	pdata->phy_dev = phy_dev;
 	pdata->phy_speed = SPEED_UNKNOWN;
 	phy_dev->supported &= ~SUPPORTED_10baseT_Half &
 			      ~SUPPORTED_100baseT_Half &
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
