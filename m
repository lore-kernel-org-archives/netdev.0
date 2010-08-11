From: Joe Perches <joe@perches.com>
Subject: [PATCH (for some future time)] drivers/net: Convert unbounded
 kzalloc calls to kcalloc
Date: Wed, 11 Aug 2010 10:02:48 -0700
Message-ID: <1281546168.3976.39.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These changes may be slightly safer in some instances.

There are other kzalloc calls with a multiply, but those
calls are typically "small fixed #" * sizeof(some pointer)"
and those are not converted.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cnic.c                        |    2 +-
 drivers/net/ehea/ehea_main.c              |    4 ++--
 drivers/net/mlx4/alloc.c                  |    2 +-
 drivers/net/mlx4/en_rx.c                  |    2 +-
 drivers/net/mlx4/profile.c                |    2 +-
 drivers/net/myri10ge/myri10ge.c           |    4 ++--
 drivers/net/niu.c                         |    4 ++--
 drivers/net/vxge/vxge-main.c              |   10 +++++-----
 drivers/net/wireless/airo.c               |    5 ++---
 drivers/net/wireless/b43/phy_n.c          |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c    |    6 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c    |   12 ++++++------
 drivers/net/wireless/rt2x00/rt2400pci.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c   |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    4 ++--
 drivers/net/wireless/rt2x00/rt61pci.c     |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c     |    2 +-
 drivers/net/wireless/wl12xx/wl1271_scan.c |    2 +-
 21 files changed, 37 insertions(+), 38 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 0961032..2ab6a7c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1022,7 +1022,7 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 	if (blks > cp->ethdev->ctx_tbl_len)
 		return -ENOMEM;
 
-	cp->ctx_arr = kzalloc(blks * sizeof(struct cnic_ctx), GFP_KERNEL);
+	cp->ctx_arr = kcalloc(blks, sizeof(struct cnic_ctx), GFP_KERNEL);
 	if (cp->ctx_arr == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 3beba70..455d101 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -180,7 +180,7 @@ static void ehea_update_firmware_handles(void)
 			 num_portres * EHEA_NUM_PORTRES_FW_HANDLES;
 
 	if (num_fw_handles) {
-		arr = kzalloc(num_fw_handles * sizeof(*arr), GFP_KERNEL);
+		arr = kcalloc(num_fw_handles, sizeof(*arr), GFP_KERNEL);
 		if (!arr)
 			goto out;  /* Keep the existing array */
 	} else
@@ -265,7 +265,7 @@ static void ehea_update_bcmc_registrations(void)
 		}
 
 	if (num_registrations) {
-		arr = kzalloc(num_registrations * sizeof(*arr), GFP_ATOMIC);
+		arr = kcalloc(num_registrations, sizeof(*arr), GFP_ATOMIC);
 		if (!arr)
 			goto out;  /* Keep the existing array */
 	} else
diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index 8c85156..537997f 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -188,7 +188,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
 		buf->npages      = buf->nbufs;
 		buf->page_shift  = PAGE_SHIFT;
-		buf->page_list   = kzalloc(buf->nbufs * sizeof *buf->page_list,
+		buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
 					   GFP_KERNEL);
 		if (!buf->page_list)
 			return -ENOMEM;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 8e2fcb7..efc3fad 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -322,7 +322,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	ring->lro.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 	ring->lro.max_desc = mdev->profile.num_lro;
 	ring->lro.max_aggr = MAX_SKB_FRAGS;
-	ring->lro.lro_arr = kzalloc(mdev->profile.num_lro *
+	ring->lro.lro_arr = kcalloc(mdev->profile.num_lro,
 				    sizeof(struct net_lro_desc),
 				    GFP_KERNEL);
 	if (!ring->lro.lro_arr) {
diff --git a/drivers/net/mlx4/profile.c b/drivers/net/mlx4/profile.c
index 5caf011..e749f82 100644
--- a/drivers/net/mlx4/profile.c
+++ b/drivers/net/mlx4/profile.c
@@ -85,7 +85,7 @@ u64 mlx4_make_profile(struct mlx4_dev *dev,
 	struct mlx4_resource tmp;
 	int i, j;
 
-	profile = kzalloc(MLX4_RES_NUM * sizeof *profile, GFP_KERNEL);
+	profile = kcalloc(MLX4_RES_NUM, sizeof(*profile), GFP_KERNEL);
 	if (!profile)
 		return -ENOMEM;
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d771d16..323fbc1 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3729,8 +3729,8 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 	 * slices. We give up on MSI-X if we can only get a single
 	 * vector. */
 
-	mgp->msix_vectors = kzalloc(mgp->num_slices *
-				    sizeof(*mgp->msix_vectors), GFP_KERNEL);
+	mgp->msix_vectors = kcalloc(mgp->num_slices, sizeof(*mgp->msix_vectors),
+				    GFP_KERNEL);
 	if (mgp->msix_vectors == NULL)
 		goto disable_msix;
 	for (i = 0; i < mgp->num_slices; i++) {
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index b9b9508..fc58f9c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4507,7 +4507,7 @@ static int niu_alloc_channels(struct niu *np)
 
 	np->dev->real_num_tx_queues = np->num_tx_rings;
 
-	np->rx_rings = kzalloc(np->num_rx_rings * sizeof(struct rx_ring_info),
+	np->rx_rings = kcalloc(np->num_rx_rings, sizeof(struct rx_ring_info),
 			       GFP_KERNEL);
 	err = -ENOMEM;
 	if (!np->rx_rings)
@@ -4541,7 +4541,7 @@ static int niu_alloc_channels(struct niu *np)
 			return err;
 	}
 
-	np->tx_rings = kzalloc(np->num_tx_rings * sizeof(struct tx_ring_info),
+	np->tx_rings = kcalloc(np->num_tx_rings, sizeof(struct tx_ring_info),
 			       GFP_KERNEL);
 	err = -ENOMEM;
 	if (!np->tx_rings)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index c7c5605..f5334b2 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2159,8 +2159,8 @@ start:
 	/* Alarm MSIX Vectors count */
 	vdev->intr_cnt++;
 
-	vdev->entries = kzalloc(vdev->intr_cnt * sizeof(struct msix_entry),
-						GFP_KERNEL);
+	vdev->entries = kcalloc(vdev->intr_cnt, sizeof(struct msix_entry),
+				GFP_KERNEL);
 	if (!vdev->entries) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: memory allocation failed",
@@ -2169,9 +2169,9 @@ start:
 		goto alloc_entries_failed;
 	}
 
-	vdev->vxge_entries =
-		kzalloc(vdev->intr_cnt * sizeof(struct vxge_msix_entry),
-				GFP_KERNEL);
+	vdev->vxge_entries = kcalloc(vdev->intr_cnt,
+				     sizeof(struct vxge_msix_entry),
+				     GFP_KERNEL);
 	if (!vdev->vxge_entries) {
 		vxge_debug_init(VXGE_ERR, "%s: memory allocation failed",
 			VXGE_DRIVER_NAME);
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 1d05445..7d26506 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2723,9 +2723,8 @@ static int airo_networks_allocate(struct airo_info *ai)
 	if (ai->networks)
 		return 0;
 
-	ai->networks =
-	    kzalloc(AIRO_MAX_NETWORK_COUNT * sizeof(BSSListElement),
-		    GFP_KERNEL);
+	ai->networks = kcalloc(AIRO_MAX_NETWORK_COUNT, sizeof(BSSListElement),
+			       GFP_KERNEL);
 	if (!ai->networks) {
 		airo_print_warn("", "Out of memory allocating beacons");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/phy_n.c
index 5a72570..e288c55 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -1182,7 +1182,7 @@ static u16 b43_nphy_gen_load_samples(struct b43_wldev *dev, u32 freq, u16 max,
 		len = bw << 1;
 	}
 
-	samples = kzalloc(len * sizeof(struct b43_c32), GFP_KERNEL);
+	samples = kcalloc(len, sizeof(struct b43_c32), GFP_KERNEL);
 	if (!samples) {
 		b43err(dev->wl, "allocation for samples generation failed\n");
 		return 0;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index c24c5ef..2e07f1e 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1921,9 +1921,9 @@ static int ipw2100_net_init(struct net_device *dev)
 
 		bg_band->band = IEEE80211_BAND_2GHZ;
 		bg_band->n_channels = geo->bg_channels;
-		bg_band->channels =
-			kzalloc(geo->bg_channels *
-				sizeof(struct ieee80211_channel), GFP_KERNEL);
+		bg_band->channels = kcalloc(geo->bg_channels,
+					    sizeof(struct ieee80211_channel),
+					    GFP_KERNEL);
 		/* translate geo->bg to bg_band.channels */
 		for (i = 0; i < geo->bg_channels; i++) {
 			bg_band->channels[i].band = IEEE80211_BAND_2GHZ;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index cb2552a..0f25083 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11467,9 +11467,9 @@ static int ipw_net_init(struct net_device *dev)
 
 		bg_band->band = IEEE80211_BAND_2GHZ;
 		bg_band->n_channels = geo->bg_channels;
-		bg_band->channels =
-			kzalloc(geo->bg_channels *
-				sizeof(struct ieee80211_channel), GFP_KERNEL);
+		bg_band->channels = kcalloc(geo->bg_channels,
+					    sizeof(struct ieee80211_channel),
+					    GFP_KERNEL);
 		/* translate geo->bg to bg_band.channels */
 		for (i = 0; i < geo->bg_channels; i++) {
 			bg_band->channels[i].band = IEEE80211_BAND_2GHZ;
@@ -11502,9 +11502,9 @@ static int ipw_net_init(struct net_device *dev)
 
 		a_band->band = IEEE80211_BAND_5GHZ;
 		a_band->n_channels = geo->a_channels;
-		a_band->channels =
-			kzalloc(geo->a_channels *
-				sizeof(struct ieee80211_channel), GFP_KERNEL);
+		a_band->channels = kcalloc(geo->a_channels,
+					   sizeof(struct ieee80211_channel),
+					   GFP_KERNEL);
 		/* translate geo->bg to a_band.channels */
 		for (i = 0; i < geo->a_channels; i++) {
 			a_band->channels[i].band = IEEE80211_BAND_2GHZ;
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 5063e01..8e3fbdf 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1481,7 +1481,7 @@ static int rt2400pci_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index c2a555d..1d174e4 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1795,7 +1795,7 @@ static int rt2500pci_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index cdaf93f..8ddaae4 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1698,7 +1698,7 @@ static int rt2500usb_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index b66e0fd..8c00fbd 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2865,7 +2865,7 @@ int rt2800_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index b0498e7..2d018ce 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -333,7 +333,7 @@ static ssize_t rt2x00debug_read_queue_stats(struct file *file,
 	if (*offset)
 		return 0;
 
-	data = kzalloc(lines * MAX_LINE_LENGTH, GFP_KERNEL);
+	data = kcalloc(lines, MAX_LINE_LENGTH, GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index a3401d3..9c609be 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -755,7 +755,7 @@ static int rt2x00queue_alloc_entries(struct data_queue *queue,
 	 * Allocate all queue entries.
 	 */
 	entry_size = sizeof(*entries) + qdesc->priv_size;
-	entries = kzalloc(queue->limit * entry_size, GFP_KERNEL);
+	entries = kcalloc(queue->limit, entry_size, GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
 
@@ -891,7 +891,7 @@ int rt2x00queue_allocate(struct rt2x00_dev *rt2x00dev)
 	 */
 	rt2x00dev->data_queues = 2 + rt2x00dev->ops->tx_queues + req_atim;
 
-	queue = kzalloc(rt2x00dev->data_queues * sizeof(*queue), GFP_KERNEL);
+	queue = kcalloc(rt2x00dev->data_queues, sizeof(*queue), GFP_KERNEL);
 	if (!queue) {
 		ERROR(rt2x00dev, "Queue allocation failed.\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index e539c6c..f226582 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2654,7 +2654,7 @@ static int rt61pci_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index aa9de18..99985a2 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2084,7 +2084,7 @@ static int rt73usb_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Create channel information array
 	 */
-	info = kzalloc(spec->num_channels * sizeof(*info), GFP_KERNEL);
+	info = kcalloc(spec->num_channels, sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/wl12xx/wl1271_scan.c b/drivers/net/wireless/wl12xx/wl1271_scan.c
index fec43ee..30dc100 100644
--- a/drivers/net/wireless/wl12xx/wl1271_scan.c
+++ b/drivers/net/wireless/wl12xx/wl1271_scan.c
@@ -248,7 +248,7 @@ int wl1271_scan(struct wl1271 *wl, const u8 *ssid, size_t ssid_len,
 
 	wl->scan.req = req;
 
-	wl->scan.scanned_ch = kzalloc(req->n_channels *
+	wl->scan.scanned_ch = kcalloc(req->n_channels,
 				      sizeof(*wl->scan.scanned_ch),
 				      GFP_KERNEL);
 	wl1271_scan_stm(wl);
