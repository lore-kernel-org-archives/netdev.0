From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] drivers/net/wireless/b43: Rename b43_debug to b43_debugging
Date: Sat, 19 Jun 2010 16:30:11 -0700
Message-ID: <daca32d8b2d06e7bee157d1c1a8f7059c8a9b00a.1276988388.git.joe@perches.com>
References: <cover.1276988387.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1200 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388Ab0FSXaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jun 2010 19:30:24 -0400
In-Reply-To: <cover.1276988387.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid using <foo>_debug function name because that is most commonly
used to emit logging messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43/debugfs.c |    2 +-
 drivers/net/wireless/b43/debugfs.h |    4 ++--
 drivers/net/wireless/b43/dma.c     |   10 +++++-----
 drivers/net/wireless/b43/lo.c      |    6 +++---
 drivers/net/wireless/b43/main.c    |   16 ++++++++--------
 drivers/net/wireless/b43/phy_g.c   |    8 ++++----
 6 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 307802c..a9f8d48 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -645,7 +645,7 @@ B43_DEBUGFS_FOPS(restart, NULL, restart_write_file);
 B43_DEBUGFS_FOPS(loctls, loctls_read_file, NULL);
 
 
-bool b43_debug(struct b43_wldev *dev, enum b43_dyndbg feature)
+bool b43_debugging(struct b43_wldev *dev, enum b43_dyndbg feature)
 {
 	bool enabled;
 
diff --git a/drivers/net/wireless/b43/debugfs.h b/drivers/net/wireless/b43/debugfs.h
index 822aad8..f34da88 100644
--- a/drivers/net/wireless/b43/debugfs.h
+++ b/drivers/net/wireless/b43/debugfs.h
@@ -73,7 +73,7 @@ struct b43_dfsentry {
 	struct dentry *dyn_debug_dentries[__B43_NR_DYNDBG];
 };
 
-bool b43_debug(struct b43_wldev *dev, enum b43_dyndbg feature);
+bool b43_debugging(struct b43_wldev *dev, enum b43_dyndbg feature);
 
 void b43_debugfs_init(void);
 void b43_debugfs_exit(void);
@@ -84,7 +84,7 @@ void b43_debugfs_log_txstat(struct b43_wldev *dev,
 
 #else /* CONFIG_B43_DEBUG */
 
-static inline bool b43_debug(struct b43_wldev *dev, enum b43_dyndbg feature)
+static inline bool b43_debugging(struct b43_wldev *dev, enum b43_dyndbg feature)
 {
 	return 0;
 }
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index a6d15c4..6343378 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -265,7 +265,7 @@ static void update_max_used_slots(struct b43_dmaring *ring,
 	if (current_used_slots <= ring->max_used_slots)
 		return;
 	ring->max_used_slots = current_used_slots;
-	if (b43_debug(ring->dev, B43_DBG_DMAVERBOSE)) {
+	if (b43_debugging(ring->dev, B43_DBG_DMAVERBOSE)) {
 		b43_dbg(ring->dev->wl,
 			"max_used_slots increased to %d on %s ring %d\n",
 			ring->max_used_slots,
@@ -1264,7 +1264,7 @@ out_unmap_hdr:
 static inline int should_inject_overflow(struct b43_dmaring *ring)
 {
 #ifdef CONFIG_B43_DEBUG
-	if (unlikely(b43_debug(ring->dev, B43_DBG_DMAOVERFLOW))) {
+	if (unlikely(b43_debugging(ring->dev, B43_DBG_DMAOVERFLOW))) {
 		/* Check if we should inject another ringbuffer overflow
 		 * to test handling of this situation in the stack. */
 		unsigned long next_overflow;
@@ -1340,7 +1340,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		 * Because of a race, one packet may be queued after
 		 * the queue is stopped, thus we got called when we shouldn't.
 		 * For now, just refuse the transmit. */
-		if (b43_debug(dev, B43_DBG_DMAVERBOSE))
+		if (b43_debugging(dev, B43_DBG_DMAVERBOSE))
 			b43_err(dev->wl, "Packet after queue stopped\n");
 		err = -ENOSPC;
 		goto out;
@@ -1376,7 +1376,7 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 		/* This TX ring is full. */
 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
 		ring->stopped = 1;
-		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
+		if (b43_debugging(dev, B43_DBG_DMAVERBOSE)) {
 			b43_dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
 		}
 	}
@@ -1494,7 +1494,7 @@ void b43_dma_handle_txstatus(struct b43_wldev *dev,
 		B43_WARN_ON(free_slots(ring) < TX_SLOTS_PER_FRAME);
 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
 		ring->stopped = 0;
-		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
+		if (b43_debugging(dev, B43_DBG_DMAVERBOSE)) {
 			b43_dbg(dev->wl, "Woke up TX ring %d\n", ring->index);
 		}
 	}
diff --git a/drivers/net/wireless/b43/lo.c b/drivers/net/wireless/b43/lo.c
index c16c35c..b047edd 100644
--- a/drivers/net/wireless/b43/lo.c
+++ b/drivers/net/wireless/b43/lo.c
@@ -774,7 +774,7 @@ struct b43_lo_calib *b43_calibrate_lo_setting(struct b43_wldev *dev,
 	lo_measure_restore(dev, &saved_regs);
 	b43_mac_enable(dev);
 
-	if (b43_debug(dev, B43_DBG_LO)) {
+	if (b43_debugging(dev, B43_DBG_LO)) {
 		b43_dbg(dev->wl, "LO: Calibrated for BB(%u), RF(%u,%u) "
 			"=> I=%d Q=%d\n",
 			bbatt->att, rfatt->att, rfatt->with_padmix,
@@ -971,7 +971,7 @@ void b43_lo_g_maintanance_work(struct b43_wldev *dev)
 			B43_WARN_ON(current_item_expired);
 			current_item_expired = 1;
 		}
-		if (b43_debug(dev, B43_DBG_LO)) {
+		if (b43_debugging(dev, B43_DBG_LO)) {
 			b43_dbg(dev->wl, "LO: Item BB(%u), RF(%u,%u), "
 				"I=%d, Q=%d expired\n",
 				cal->bbatt.att, cal->rfatt.att,
@@ -983,7 +983,7 @@ void b43_lo_g_maintanance_work(struct b43_wldev *dev)
 	}
 	if (current_item_expired || unlikely(list_empty(&lo->calib_list))) {
 		/* Recalibrate currently used LO setting. */
-		if (b43_debug(dev, B43_DBG_LO))
+		if (b43_debugging(dev, B43_DBG_LO))
 			b43_dbg(dev->wl, "LO: Recalibrating current LO setting\n");
 		cal = b43_calibrate_lo_setting(dev, &gphy->bbatt, &gphy->rfatt);
 		if (cal) {
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 6343873..3d2c655 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -839,9 +839,9 @@ static void rx_tkip_phase1_write(struct b43_wldev *dev, u8 index, u32 iv32,
 	index -= pairwise_keys_start;
 	B43_WARN_ON(index >= B43_NR_PAIRWISE_KEYS);
 
-	if (b43_debug(dev, B43_DBG_KEYS)) {
+	if (b43_debugging(dev, B43_DBG_KEYS)) {
 		b43_dbg(dev->wl, "rx_tkip_phase1_write : idx 0x%x, iv32 0x%x\n",
-				index, iv32);
+			index, iv32);
 	}
 	/* Write the key to the  RX tkip shared mem */
 	offset = B43_SHM_SH_TKIPTSCTTAK + index * (10 + 4);
@@ -1014,7 +1014,7 @@ static void b43_dump_keymemory(struct b43_wldev *dev)
 	u64 hf;
 	struct b43_key *key;
 
-	if (!b43_debug(dev, B43_DBG_KEYS))
+	if (!b43_debugging(dev, B43_DBG_KEYS))
 		return;
 
 	hf = b43_hf_read(dev);
@@ -1857,7 +1857,7 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 	b43_write32(dev, B43_MMIO_GEN_IRQ_MASK, dev->irq_mask);
 
 #if B43_DEBUG
-	if (b43_debug(dev, B43_DBG_VERBOSESTATS)) {
+	if (b43_debugging(dev, B43_DBG_VERBOSESTATS)) {
 		dev->irq_count++;
 		for (i = 0; i < ARRAY_SIZE(dev->irq_bit_count); i++) {
 			if (reason & (1 << i))
@@ -2587,7 +2587,7 @@ static void b43_gpio_cleanup(struct b43_wldev *dev)
 /* http://bcm-specs.sipsolutions.net/EnableMac */
 void b43_mac_enable(struct b43_wldev *dev)
 {
-	if (b43_debug(dev, B43_DBG_FIRMWARE)) {
+	if (b43_debugging(dev, B43_DBG_FIRMWARE)) {
 		u16 fwstate;
 
 		fwstate = b43_shm_read16(dev, B43_SHM_SHARED,
@@ -2944,7 +2944,7 @@ static void b43_periodic_every15sec(struct b43_wldev *dev)
 	wmb();
 
 #if B43_DEBUG
-	if (b43_debug(dev, B43_DBG_VERBOSESTATS)) {
+	if (b43_debugging(dev, B43_DBG_VERBOSESTATS)) {
 		unsigned int i;
 
 		b43_dbg(dev->wl, "Stats: %7u IRQs/sec, %7u TX/sec, %7u RX/sec\n",
@@ -2993,14 +2993,14 @@ static void b43_periodic_work_handler(struct work_struct *work)
 
 	if (unlikely(b43_status(dev) != B43_STAT_STARTED))
 		goto out;
-	if (b43_debug(dev, B43_DBG_PWORK_STOP))
+	if (b43_debugging(dev, B43_DBG_PWORK_STOP))
 		goto out_requeue;
 
 	do_periodic_work(dev);
 
 	dev->periodic_state++;
 out_requeue:
-	if (b43_debug(dev, B43_DBG_PWORK_FAST))
+	if (b43_debugging(dev, B43_DBG_PWORK_FAST))
 		delay = msecs_to_jiffies(50);
 	else
 		delay = round_jiffies_relative(HZ * 15);
diff --git a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/b43/phy_g.c
index acadae6..ef539a5 100644
--- a/drivers/net/wireless/b43/phy_g.c
+++ b/drivers/net/wireless/b43/phy_g.c
@@ -236,7 +236,7 @@ static void b43_set_txpower_g(struct b43_wldev *dev,
 	gphy->rfatt.with_padmix = !!(tx_control & B43_TXCTL_TXMIX);
 	memmove(&gphy->bbatt, bbatt, sizeof(*bbatt));
 
-	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
+	if (b43_debugging(dev, B43_DBG_XMITPOWER)) {
 		b43_dbg(dev->wl, "Tuning TX-power to bbatt(%u), "
 			"rfatt(%u), tx_control(0x%02X), "
 			"tx_bias(0x%02X), tx_magn(0x%02X)\n",
@@ -2862,7 +2862,7 @@ static void b43_gphy_op_adjust_txpower(struct b43_wldev *dev)
 	gphy->rfatt.att = rfatt;
 	gphy->bbatt.att = bbatt;
 
-	if (b43_debug(dev, B43_DBG_XMITPOWER))
+	if (b43_debugging(dev, B43_DBG_XMITPOWER))
 		b43_dbg(dev->wl, "Adjusting TX power\n");
 
 	/* Adjust the hardware */
@@ -2929,7 +2929,7 @@ static enum b43_txpwr_result b43_gphy_op_recalc_txpower(struct b43_wldev *dev,
 		desired_pwr = INT_TO_Q52(phy->desired_txpower);
 	/* And limit it. max_pwr already is Q5.2 */
 	desired_pwr = clamp_val(desired_pwr, 0, max_pwr);
-	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
+	if (b43_debugging(dev, B43_DBG_XMITPOWER)) {
 		b43_dbg(dev->wl,
 			"[TX power]  current = " Q52_FMT
 			" dBm,  desired = " Q52_FMT
@@ -2958,7 +2958,7 @@ static enum b43_txpwr_result b43_gphy_op_recalc_txpower(struct b43_wldev *dev,
 	bbatt_delta -= 4 * rfatt_delta;
 
 #if B43_DEBUG
-	if (b43_debug(dev, B43_DBG_XMITPOWER)) {
+	if (b43_debugging(dev, B43_DBG_XMITPOWER)) {
 		int dbm = pwr_adjust < 0 ? -pwr_adjust : pwr_adjust;
 		b43_dbg(dev->wl,
 			"[TX power deltas]  %s" Q52_FMT " dBm   =>   "
-- 
1.7.1.337.g6068.dirty

