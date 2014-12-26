From: Fred Chou <fred.chou.nd@gmail.com>
Subject: [PATCH] net: wireless: rt2x00: use helper to check capability/requirement
Date: Fri, 26 Dec 2014 16:19:18 +0800
Message-ID: <1419581958-5927-1-git-send-email-fred.chou.nd@gmail.com>
Cc: Fred Chou <fred.chou.nd@gmail.com>
To: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33462 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbaLZIQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 03:16:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fred Chou <fred.chou.nd@gmail.com>

Use rt2x00_has_cap_flag macro to check rt2x00dev->cap_flags. 

Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>
---
 drivers/net/wireless/rt2x00/rt2x00config.c   |  4 ++--
 drivers/net/wireless/rt2x00/rt2x00dev.c      | 18 +++++++++---------
 drivers/net/wireless/rt2x00/rt2x00firmware.c |  2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |  2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c    | 18 +++++++++---------
 drivers/net/wireless/rt2x00/rt2x00usb.c      |  8 ++++----
 6 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index 1122dc4..48a2cad 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -240,7 +240,7 @@ void rt2x00lib_config(struct rt2x00_dev *rt2x00dev,
 		rt2x00dev->rf_channel = libconf.rf.channel;
 	}
 
-	if (test_bit(REQUIRE_PS_AUTOWAKE, &rt2x00dev->cap_flags) &&
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_PS_AUTOWAKE) &&
 	    (ieee80211_flags & IEEE80211_CONF_CHANGE_PS))
 		cancel_delayed_work_sync(&rt2x00dev->autowakeup_work);
 
@@ -257,7 +257,7 @@ void rt2x00lib_config(struct rt2x00_dev *rt2x00dev,
 		rt2x00link_reset_tuner(rt2x00dev, false);
 
 	if (test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags) &&
-	    test_bit(REQUIRE_PS_AUTOWAKE, &rt2x00dev->cap_flags) &&
+	    rt2x00_has_cap_flag(rt2x00dev, REQUIRE_PS_AUTOWAKE) &&
 	    (ieee80211_flags & IEEE80211_CONF_CHANGE_PS) &&
 	    (conf->flags & IEEE80211_CONF_PS)) {
 		beacon_diff = (long)jiffies - (long)rt2x00dev->last_beacon;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 9967a1d..5639ed8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -351,7 +351,7 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	/*
 	 * Remove L2 padding which was added during
 	 */
-	if (test_bit(REQUIRE_L2PAD, &rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_L2PAD))
 		rt2x00queue_remove_l2pad(entry->skb, header_length);
 
 	/*
@@ -460,7 +460,7 @@ void rt2x00lib_txdone(struct queue_entry *entry,
 	 * send the status report back.
 	 */
 	if (!(skbdesc_flags & SKBDESC_NOT_MAC80211)) {
-		if (test_bit(REQUIRE_TASKLET_CONTEXT, &rt2x00dev->cap_flags))
+		if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_TASKLET_CONTEXT))
 			ieee80211_tx_status(rt2x00dev->hw, entry->skb);
 		else
 			ieee80211_tx_status_ni(rt2x00dev->hw, entry->skb);
@@ -1056,9 +1056,9 @@ static int rt2x00lib_probe_hw(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Take TX headroom required for alignment into account.
 	 */
-	if (test_bit(REQUIRE_L2PAD, &rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_L2PAD))
 		rt2x00dev->hw->extra_tx_headroom += RT2X00_L2PAD_SIZE;
-	else if (test_bit(REQUIRE_DMA, &rt2x00dev->cap_flags))
+	else if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DMA))
 		rt2x00dev->hw->extra_tx_headroom += RT2X00_ALIGN_SIZE;
 
 	/*
@@ -1069,7 +1069,7 @@ static int rt2x00lib_probe_hw(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Allocate tx status FIFO for driver use.
 	 */
-	if (test_bit(REQUIRE_TXSTATUS_FIFO, &rt2x00dev->cap_flags)) {
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_TXSTATUS_FIFO)) {
 		/*
 		 * Allocate the txstatus fifo. In the worst case the tx
 		 * status fifo has to hold the tx status of all entries
@@ -1131,7 +1131,7 @@ static void rt2x00lib_uninitialize(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Stop rfkill polling.
 	 */
-	if (test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DELAYED_RFKILL))
 		rt2x00rfkill_unregister(rt2x00dev);
 
 	/*
@@ -1173,7 +1173,7 @@ static int rt2x00lib_initialize(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Start rfkill polling.
 	 */
-	if (test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DELAYED_RFKILL))
 		rt2x00rfkill_register(rt2x00dev);
 
 	return 0;
@@ -1389,7 +1389,7 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Start rfkill polling.
 	 */
-	if (!test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+	if (!rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DELAYED_RFKILL))
 		rt2x00rfkill_register(rt2x00dev);
 
 	return 0;
@@ -1408,7 +1408,7 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Stop rfkill polling.
 	 */
-	if (!test_bit(REQUIRE_DELAYED_RFKILL, &rt2x00dev->cap_flags))
+	if (!rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DELAYED_RFKILL))
 		rt2x00rfkill_unregister(rt2x00dev);
 
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/rt2x00/rt2x00firmware.c
index fbae279..5813300 100644
--- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
+++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
@@ -96,7 +96,7 @@ int rt2x00lib_load_firmware(struct rt2x00_dev *rt2x00dev)
 {
 	int retval;
 
-	if (!test_bit(REQUIRE_FIRMWARE, &rt2x00dev->cap_flags))
+	if (!rt2x00_has_cap_flag(rt2x00dev, REQUIRE_FIRMWARE))
 		return 0;
 
 	if (!rt2x00dev->fw) {
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index cb40245..300876d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -119,7 +119,7 @@ void rt2x00mac_tx(struct ieee80211_hw *hw,
 	 * Use the ATIM queue if appropriate and present.
 	 */
 	if (tx_info->flags & IEEE80211_TX_CTL_SEND_AFTER_DTIM &&
-	    test_bit(REQUIRE_ATIM_QUEUE, &rt2x00dev->cap_flags))
+	    rt2x00_has_cap_flag(rt2x00dev, REQUIRE_ATIM_QUEUE))
 		qid = QID_ATIM;
 
 	queue = rt2x00queue_get_tx_queue(rt2x00dev, qid);
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 66ff364..68b620b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -85,7 +85,7 @@ struct sk_buff *rt2x00queue_alloc_rxskb(struct queue_entry *entry, gfp_t gfp)
 	memset(skbdesc, 0, sizeof(*skbdesc));
 	skbdesc->entry = entry;
 
-	if (test_bit(REQUIRE_DMA, &rt2x00dev->cap_flags)) {
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DMA)) {
 		dma_addr_t skb_dma;
 
 		skb_dma = dma_map_single(rt2x00dev->dev, skb->data, skb->len,
@@ -198,7 +198,7 @@ static void rt2x00queue_create_tx_descriptor_seq(struct rt2x00_dev *rt2x00dev,
 
 	__set_bit(ENTRY_TXD_GENERATE_SEQ, &txdesc->flags);
 
-	if (!test_bit(REQUIRE_SW_SEQNO, &rt2x00dev->cap_flags)) {
+	if (!rt2x00_has_cap_flag(rt2x00dev, REQUIRE_SW_SEQNO)) {
 		/*
 		 * rt2800 has a H/W (or F/W) bug, device incorrectly increase
 		 * seqno on retransmited data (non-QOS) frames. To workaround
@@ -484,7 +484,7 @@ static void rt2x00queue_create_tx_descriptor(struct rt2x00_dev *rt2x00dev,
 	rt2x00crypto_create_tx_descriptor(rt2x00dev, skb, txdesc);
 	rt2x00queue_create_tx_descriptor_seq(rt2x00dev, skb, txdesc);
 
-	if (test_bit(REQUIRE_HT_TX_DESC, &rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_HT_TX_DESC))
 		rt2x00queue_create_tx_descriptor_ht(rt2x00dev, skb, txdesc,
 						   sta, hwrate);
 	else
@@ -526,7 +526,7 @@ static int rt2x00queue_write_tx_data(struct queue_entry *entry,
 	/*
 	 * Map the skb to DMA.
 	 */
-	if (test_bit(REQUIRE_DMA, &rt2x00dev->cap_flags) &&
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_DMA) &&
 	    rt2x00queue_map_txskb(entry))
 		return -ENOMEM;
 
@@ -646,7 +646,7 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb,
 	 */
 	if (test_bit(ENTRY_TXD_ENCRYPT, &txdesc.flags) &&
 	    !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc.flags)) {
-		if (test_bit(REQUIRE_COPY_IV, &queue->rt2x00dev->cap_flags))
+		if (rt2x00_has_cap_flag(queue->rt2x00dev, REQUIRE_COPY_IV))
 			rt2x00crypto_tx_copy_iv(skb, &txdesc);
 		else
 			rt2x00crypto_tx_remove_iv(skb, &txdesc);
@@ -660,9 +660,9 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb,
 	 * PCI and USB devices, while header alignment only is valid
 	 * for PCI devices.
 	 */
-	if (test_bit(REQUIRE_L2PAD, &queue->rt2x00dev->cap_flags))
+	if (rt2x00_has_cap_flag(queue->rt2x00dev, REQUIRE_L2PAD))
 		rt2x00queue_insert_l2pad(skb, txdesc.header_length);
-	else if (test_bit(REQUIRE_DMA, &queue->rt2x00dev->cap_flags))
+	else if (rt2x00_has_cap_flag(queue->rt2x00dev, REQUIRE_DMA))
 		rt2x00queue_align_frame(skb);
 
 	/*
@@ -1178,7 +1178,7 @@ int rt2x00queue_initialize(struct rt2x00_dev *rt2x00dev)
 	if (status)
 		goto exit;
 
-	if (test_bit(REQUIRE_ATIM_QUEUE, &rt2x00dev->cap_flags)) {
+	if (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_ATIM_QUEUE)) {
 		status = rt2x00queue_alloc_entries(rt2x00dev->atim);
 		if (status)
 			goto exit;
@@ -1234,7 +1234,7 @@ int rt2x00queue_allocate(struct rt2x00_dev *rt2x00dev)
 	struct data_queue *queue;
 	enum data_queue_qid qid;
 	unsigned int req_atim =
-	    !!test_bit(REQUIRE_ATIM_QUEUE, &rt2x00dev->cap_flags);
+	    rt2x00_has_cap_flag(rt2x00dev, REQUIRE_ATIM_QUEUE);
 
 	/*
 	 * We need the following queues:
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 892270d..7627af6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -274,7 +274,7 @@ static void rt2x00usb_interrupt_txdone(struct urb *urb)
 	 * Schedule the delayed work for reading the TX status
 	 * from the device.
 	 */
-	if (!test_bit(REQUIRE_TXSTATUS_FIFO, &rt2x00dev->cap_flags) ||
+	if (!rt2x00_has_cap_flag(rt2x00dev, REQUIRE_TXSTATUS_FIFO) ||
 	    !kfifo_is_empty(&rt2x00dev->txstatus_fifo))
 		queue_work(rt2x00dev->workqueue, &rt2x00dev->txdone_work);
 }
@@ -456,7 +456,7 @@ static bool rt2x00usb_flush_entry(struct queue_entry *entry, void *data)
 	 * Kill guardian urb (if required by driver).
 	 */
 	if ((entry->queue->qid == QID_BEACON) &&
-	    (test_bit(REQUIRE_BEACON_GUARD, &rt2x00dev->cap_flags)))
+	    (rt2x00_has_cap_flag(rt2x00dev, REQUIRE_BEACON_GUARD)))
 		usb_kill_urb(bcn_priv->guardian_urb);
 
 	return false;
@@ -655,7 +655,7 @@ static int rt2x00usb_alloc_entries(struct data_queue *queue)
 	 * then we are done.
 	 */
 	if (queue->qid != QID_BEACON ||
-	    !test_bit(REQUIRE_BEACON_GUARD, &rt2x00dev->cap_flags))
+	    !rt2x00_has_cap_flag(rt2x00dev, REQUIRE_BEACON_GUARD))
 		return 0;
 
 	for (i = 0; i < queue->limit; i++) {
@@ -690,7 +690,7 @@ static void rt2x00usb_free_entries(struct data_queue *queue)
 	 * then we are done.
 	 */
 	if (queue->qid != QID_BEACON ||
-	    !test_bit(REQUIRE_BEACON_GUARD, &rt2x00dev->cap_flags))
+	    !rt2x00_has_cap_flag(rt2x00dev, REQUIRE_BEACON_GUARD))
 		return;
 
 	for (i = 0; i < queue->limit; i++) {
-- 
1.9.1
