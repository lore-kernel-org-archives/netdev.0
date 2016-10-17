From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 10/15] ethernet/neterion: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:12 -0400
Message-ID: <20161017195417.48259-11-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Jon Mason <jdmason@kudzu.us>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s2io: min_mtu 46, max_mtu 9600

vxge: min_mtu 68, max_mtu 9600

CC: netdev@vger.kernel.org
CC: Jon Mason <jdmason@kudzu.us>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/neterion/s2io.c             | 9 ++++-----
 drivers/net/ethernet/neterion/vxge/vxge-config.h | 2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c   | 9 ++++-----
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index eaa37c0..564f682 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -6678,11 +6678,6 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 	struct s2io_nic *sp = netdev_priv(dev);
 	int ret = 0;
 
-	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
-		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n", dev->name);
-		return -EPERM;
-	}
-
 	dev->mtu = new_mtu;
 	if (netif_running(dev)) {
 		s2io_stop_all_tx_queue(sp);
@@ -8019,6 +8014,10 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		config->mc_start_offset = S2IO_HERC_MC_ADDR_START_OFFSET;
 	}
 
+	/* MTU range: 46 - 9600 */
+	dev->min_mtu = MIN_MTU;
+	dev->max_mtu = S2IO_JUMBO_SIZE;
+
 	/* store mac addresses from CAM to s2io_nic structure */
 	do_s2io_store_unicast_mc(sp);
 
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.h b/drivers/net/ethernet/neterion/vxge/vxge-config.h
index 6ce4412..cfa9704 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.h
@@ -27,7 +27,7 @@
 	(((size) - (((u64)adrs) & ((size)-1))) & ((size)-1))
 #endif
 
-#define VXGE_HW_MIN_MTU				68
+#define VXGE_HW_MIN_MTU				ETH_MIN_MTU
 #define VXGE_HW_MAX_MTU				9600
 #define VXGE_HW_DEFAULT_MTU			1500
 
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index e0993eb..e07b936 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3074,11 +3074,6 @@ static int vxge_change_mtu(struct net_device *dev, int new_mtu)
 
 	vxge_debug_entryexit(vdev->level_trace,
 		"%s:%d", __func__, __LINE__);
-	if ((new_mtu < VXGE_HW_MIN_MTU) || (new_mtu > VXGE_HW_MAX_MTU)) {
-		vxge_debug_init(vdev->level_err,
-			"%s: mtu size is invalid", dev->name);
-		return -EPERM;
-	}
 
 	/* check if device is down already */
 	if (unlikely(!is_vxge_card_up(vdev))) {
@@ -3462,6 +3457,10 @@ static int vxge_device_register(struct __vxge_hw_device *hldev,
 			"%s : using High DMA", __func__);
 	}
 
+	/* MTU range: 68 - 9600 */
+	ndev->min_mtu = VXGE_HW_MIN_MTU;
+	ndev->max_mtu = VXGE_HW_MAX_MTU;
+
 	ret = register_netdev(ndev);
 	if (ret) {
 		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
-- 
2.10.0
