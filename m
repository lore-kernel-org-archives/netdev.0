From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next v2 01/12] drivers: net: xgene: Fix compiler warnings
Date: Fri, 12 Aug 2016 22:05:37 -0700
Message-ID: <1471064748-28033-2-git-send-email-isubramanian@apm.com>
References: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471064748-28033-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fixed compiler warnings reported with -Wmaybe-uninitialized W=1,

      /drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function ‘xgene_enet_rx_frame’:
      ../drivers/net/ethernet/apm/xgene/xgene_enet_main.c:455:27: warning: variable ‘pdata’ set but not used [-Wunused-but-set-variable]
      struct xgene_enet_pdata *pdata;
      ^
      ../drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function ‘xgene_enet_remove’:
      ../drivers/net/ethernet/apm/xgene/xgene_enet_main.c:1691:30: warning: variable ‘mac_ops’ set but not used [-Wunused-but-set-variable]
      const struct xgene_mac_ops *mac_ops;
				                                   ^

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index d1d6b5e..ceeb3f4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -452,7 +452,6 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 			       struct xgene_enet_raw_desc *raw_desc)
 {
 	struct net_device *ndev;
-	struct xgene_enet_pdata *pdata;
 	struct device *dev;
 	struct xgene_enet_desc_ring *buf_pool;
 	u32 datalen, skb_index;
@@ -461,7 +460,6 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	int ret = 0;
 
 	ndev = rx_ring->ndev;
-	pdata = netdev_priv(ndev);
 	dev = ndev_to_dev(rx_ring->ndev);
 	buf_pool = rx_ring->buf_pool;
 
@@ -1688,11 +1686,9 @@ err:
 static int xgene_enet_remove(struct platform_device *pdev)
 {
 	struct xgene_enet_pdata *pdata;
-	const struct xgene_mac_ops *mac_ops;
 	struct net_device *ndev;
 
 	pdata = platform_get_drvdata(pdev);
-	mac_ops = pdata->mac_ops;
 	ndev = pdata->ndev;
 
 	rtnl_lock();
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
