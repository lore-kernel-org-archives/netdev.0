From: Akshay Sarode <akshaysarode21@gmail.com>
Subject: [PATCH 1/1] Checkpatch: coding style errors in Nvidia ethernet driver
Date: Fri, 10 Oct 2014 13:31:42 +0530
Message-ID: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
Cc: Akshay Sarode <akshaysarode21@gmail.com>
To: John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ERROR: "foo* bar" should be "foo *bar"
ERROR: do not initialise statics to 0 or NULL
CHECK: spinlock_t definition without comment
Signed-off-by: Akshay Sarode <akshaysarode21@gmail.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index f39cae6..dd03d1a 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -748,7 +748,7 @@ struct nv_skb_map {
 
 /* in dev: base, irq */
 struct fe_priv {
-	spinlock_t lock;
+	spinlock_t lock; /* spinlock for SMA lock handling */
 
 	struct net_device *dev;
 	struct napi_struct napi;
@@ -893,6 +893,7 @@ enum {
 	NV_MSI_INT_DISABLED,
 	NV_MSI_INT_ENABLED
 };
+
 static int msi = NV_MSI_INT_ENABLED;
 
 /*
@@ -902,6 +903,7 @@ enum {
 	NV_MSIX_INT_DISABLED,
 	NV_MSIX_INT_ENABLED
 };
+
 static int msix = NV_MSIX_INT_ENABLED;
 
 /*
@@ -911,12 +913,18 @@ enum {
 	NV_DMA_64BIT_DISABLED,
 	NV_DMA_64BIT_ENABLED
 };
+
 static int dma_64bit = NV_DMA_64BIT_ENABLED;
 
 /*
  * Debug output control for tx_timeout
  */
-static bool debug_tx_timeout = false;
+enum {
+	NV_DEBUG_TX_TIMEOUT_DISABLED,
+	NV_DEBUG_TX_TIMEOUT_ENABLED
+};
+
+static bool debug_tx_timeout = NV_DEBUG_TX_TIMEOUT_DISABLED;
 
 /*
  * Crossover Detection
@@ -926,6 +934,7 @@ enum {
 	NV_CROSSOVER_DETECTION_DISABLED,
 	NV_CROSSOVER_DETECTION_ENABLED
 };
+
 static int phy_cross = NV_CROSSOVER_DETECTION_DISABLED;
 
 /*
@@ -4562,7 +4571,8 @@ static int nv_nway_reset(struct net_device *dev)
 	return ret;
 }
 
-static void nv_get_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+static void nv_get_ringparam(struct net_device *dev,
+			     struct ethtool_ringparam *ring)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
@@ -4573,7 +4583,8 @@ static void nv_get_ringparam(struct net_device *dev, struct ethtool_ringparam* r
 	ring->tx_pending = np->tx_ring_size;
 }
 
-static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ring)
+static int nv_set_ringparam(struct net_device *dev,
+			    struct ethtool_ringparam *ring)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
@@ -4685,7 +4696,8 @@ exit:
 	return -ENOMEM;
 }
 
-static void nv_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam* pause)
+static void nv_get_pauseparam(struct net_device *dev,
+			      struct ethtool_pauseparam *pause)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
@@ -4694,7 +4706,8 @@ static void nv_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam*
 	pause->tx_pause = (np->pause_flags & NV_PAUSEFRAME_TX_ENABLE) != 0;
 }
 
-static int nv_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam* pause)
+static int nv_set_pauseparam(struct net_device *dev,
+			     struct ethtool_pauseparam *pause)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int adv, bmcr;
-- 
1.9.1
