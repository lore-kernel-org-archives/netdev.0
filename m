From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next v2 11/12] drivers: net: xgene: Fix backward compatibility
Date: Fri, 12 Aug 2016 22:05:47 -0700
Message-ID: <1471064748-28033-12-git-send-email-isubramanian@apm.com>
References: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471064748-28033-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the backward compatibility on handling phy_connect(), by
iterating over the phy-handle, when new DT is used with older kernel.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 18bb955..321fb19 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -761,18 +761,18 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 	if (dev->of_node) {
 		for (i = 0 ; i < 2; i++) {
 			np = of_parse_phandle(dev->of_node, "phy-handle", i);
-			if (np)
-				break;
-		}
 
-		if (!np) {
-			netdev_dbg(ndev, "No phy-handle found in DT\n");
-			return -ENODEV;
+			if (!np)
+				continue;
+
+			phy_dev = of_phy_connect(ndev, np,
+						 &xgene_enet_adjust_link,
+						 0, pdata->phy_mode);
+			of_node_put(np);
+			if (phy_dev)
+				break;
 		}
 
-		phy_dev = of_phy_connect(ndev, np, &xgene_enet_adjust_link,
-					 0, pdata->phy_mode);
-		of_node_put(np);
 		if (!phy_dev) {
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return -ENODEV;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
