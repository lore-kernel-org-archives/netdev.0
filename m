From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 10/26] rt2x00: WMM ring priority
Date: Sun, 3 Dec 2006 19:19:02 +0100
Message-ID: <200612031919.03080.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759967AbWLCSTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:32 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:31 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rt61pci and rt73usb have the WMM ring priorities
backwards. RING_AC_VO is the most important ring
while RING_AC_BK the least important ring.
Lets reorder the ring handling.
(And fix some small typos in the comments regarding
the rings)

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 12:49:55.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 13:04:38.000000000 +0100
@@ -870,7 +870,7 @@
 #define RXD_W7_RESERVED			FIELD32(0xffffffff)
 
 /*
- * TX ring index number for rt2x00_pci structure.
+ * TX ring index number for rt2x00_dev structure.
  */
 enum ring_index {
 	RING_PRIO = 0,
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-03 12:50:28.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-12-03 13:04:44.000000000 +0100
@@ -1145,7 +1145,7 @@
 #define RXD_W10_DROP			FIELD32(0x00000001)
 
 /*
- * TX ring index number for rt2x00_pci structure.
+ * TX ring index number for rt2x00_dev structure.
  */
 enum ring_index {
 	RING_PRIO = 0,
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 13:00:52.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-12-03 13:04:50.000000000 +0100
@@ -652,7 +652,7 @@
 #define RXD_W3_EIV			FIELD32(0xffffffff)
 
 /*
- * TX ring index number for rt2x00_usb structure.
+ * TX ring index number for rt2x00_dev structure.
  */
 enum ring_index {
 	RING_PRIO = 0,
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 12:48:43.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:08:21.000000000 +0100
@@ -1320,16 +1320,16 @@
 	if (rt61pci_alloc_dma_ring(rt2x00dev, RING_RX,
 		rt61pci_rxdone, RX_ENTRIES, DATA_FRAME_SIZE,
 		RXD_DESC_SIZE) ||
-	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_BK,
+	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_VO,
 		rt61pci_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_BE,
+	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_VI,
 		rt61pci_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_VI,
+	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_BE,
 		rt61pci_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_VO,
+	    rt61pci_alloc_dma_ring(rt2x00dev, RING_AC_BK,
 		rt61pci_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
 	    rt61pci_alloc_dma_ring(rt2x00dev, RING_PRIO,
@@ -1347,10 +1347,10 @@
 static void rt61pci_free_rings(struct rt2x00_dev *rt2x00dev)
 {
 	rt61pci_free_ring(rt2x00dev, RING_RX);
-	rt61pci_free_ring(rt2x00dev, RING_AC_BK);
-	rt61pci_free_ring(rt2x00dev, RING_AC_BE);
-	rt61pci_free_ring(rt2x00dev, RING_AC_VI);
 	rt61pci_free_ring(rt2x00dev, RING_AC_VO);
+	rt61pci_free_ring(rt2x00dev, RING_AC_VI);
+	rt61pci_free_ring(rt2x00dev, RING_AC_BE);
+	rt61pci_free_ring(rt2x00dev, RING_AC_BK);
 	rt61pci_free_ring(rt2x00dev, RING_PRIO);
 	rt61pci_free_ring(rt2x00dev, RING_BEACON);
 }
@@ -1429,10 +1429,10 @@
 	 * Initialize rings.
 	 */
 	rt61pci_init_rxring(rt2x00dev, RING_RX);
-	rt61pci_init_txring(rt2x00dev, RING_AC_BK);
-	rt61pci_init_txring(rt2x00dev, RING_AC_BE);
-	rt61pci_init_txring(rt2x00dev, RING_AC_VI);
 	rt61pci_init_txring(rt2x00dev, RING_AC_VO);
+	rt61pci_init_txring(rt2x00dev, RING_AC_VI);
+	rt61pci_init_txring(rt2x00dev, RING_AC_BE);
+	rt61pci_init_txring(rt2x00dev, RING_AC_BK);
 	rt61pci_init_txring(rt2x00dev, RING_PRIO);
 	rt61pci_init_txring(rt2x00dev, RING_BEACON);
 
@@ -1441,40 +1441,40 @@
 	 */
 	reg = 0;
 	rt2x00_set_field32(&reg, TX_RING_CSR0_AC0_RING_SIZE,
-		rt2x00dev->ring[RING_AC_BK].stats.limit);
+		rt2x00dev->ring[RING_AC_VO].stats.limit);
 	rt2x00_set_field32(&reg, TX_RING_CSR0_AC1_RING_SIZE,
-		rt2x00dev->ring[RING_AC_BE].stats.limit);
-	rt2x00_set_field32(&reg, TX_RING_CSR0_AC2_RING_SIZE,
 		rt2x00dev->ring[RING_AC_VI].stats.limit);
+	rt2x00_set_field32(&reg, TX_RING_CSR0_AC2_RING_SIZE,
+		rt2x00dev->ring[RING_AC_BE].stats.limit);
 	rt2x00_set_field32(&reg, TX_RING_CSR0_AC3_RING_SIZE,
-		rt2x00dev->ring[RING_AC_VO].stats.limit);
+		rt2x00dev->ring[RING_AC_BK].stats.limit);
 	rt2x00_register_write(rt2x00dev, TX_RING_CSR0, reg);
 
 	reg = 0;
 	rt2x00_set_field32(&reg, TX_RING_CSR1_MGMT_RING_SIZE,
 		rt2x00dev->ring[RING_PRIO].stats.limit);
 	rt2x00_set_field32(&reg, TX_RING_CSR1_TXD_SIZE,
-		rt2x00dev->ring[RING_AC_BK].desc_size / 4);
+		rt2x00dev->ring[RING_AC_VO].desc_size / 4);
 	rt2x00_register_write(rt2x00dev, TX_RING_CSR1, reg);
 
 	reg = 0;
 	rt2x00_set_field32(&reg, AC0_BASE_CSR_RING_REGISTER,
-		rt2x00dev->ring[RING_AC_BK].data_dma);
+		rt2x00dev->ring[RING_AC_VO].data_dma);
 	rt2x00_register_write(rt2x00dev, AC0_BASE_CSR, reg);
 
 	reg = 0;
 	rt2x00_set_field32(&reg, AC1_BASE_CSR_RING_REGISTER,
-		rt2x00dev->ring[RING_AC_BE].data_dma);
+		rt2x00dev->ring[RING_AC_VI].data_dma);
 	rt2x00_register_write(rt2x00dev, AC1_BASE_CSR, reg);
 
 	reg = 0;
 	rt2x00_set_field32(&reg, AC2_BASE_CSR_RING_REGISTER,
-		rt2x00dev->ring[RING_AC_VI].data_dma);
+		rt2x00dev->ring[RING_AC_BE].data_dma);
 	rt2x00_register_write(rt2x00dev, AC2_BASE_CSR, reg);
 
 	reg = 0;
 	rt2x00_set_field32(&reg, AC3_BASE_CSR_RING_REGISTER,
-		rt2x00dev->ring[RING_AC_VO].data_dma);
+		rt2x00dev->ring[RING_AC_BK].data_dma);
 	rt2x00_register_write(rt2x00dev, AC3_BASE_CSR, reg);
 
 	reg = 0;
@@ -2317,10 +2317,10 @@
 	 * to start scanning.
 	 */
 	if (rt2x00dev->scan &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BK]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BK]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
 		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 }
@@ -2374,7 +2374,7 @@
 	 */
 	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_TXDONE))
 		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->ring[RING_AC_BK].irq_work);
+			&rt2x00dev->ring[RING_AC_VO].irq_work);
 
 	return IRQ_HANDLED;
 }
@@ -2827,17 +2827,17 @@
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA0],
-		&rt2x00dev->ring[RING_AC_BK].stats,
-		sizeof(rt2x00dev->ring[RING_AC_BK].stats));
+		&rt2x00dev->ring[RING_AC_VO].stats,
+		sizeof(rt2x00dev->ring[RING_AC_VO].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA1],
-		&rt2x00dev->ring[RING_AC_BE].stats,
-		sizeof(rt2x00dev->ring[RING_AC_BE].stats));
-	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA2],
 		&rt2x00dev->ring[RING_AC_VI].stats,
 		sizeof(rt2x00dev->ring[RING_AC_VI].stats));
+	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA2],
+		&rt2x00dev->ring[RING_AC_BE].stats,
+		sizeof(rt2x00dev->ring[RING_AC_BE].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA3],
-		&rt2x00dev->ring[RING_AC_VO].stats,
-		sizeof(rt2x00dev->ring[RING_AC_VO].stats));
+		&rt2x00dev->ring[RING_AC_BK].stats,
+		sizeof(rt2x00dev->ring[RING_AC_BK].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA4],
 		&rt2x00dev->ring[RING_PRIO].stats,
 		sizeof(rt2x00dev->ring[RING_PRIO].stats));
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 12:51:17.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-12-03 13:04:29.000000000 +0100
@@ -1309,13 +1309,13 @@
 #define RXD_W15_RESERVED		FIELD32(0xffffffff)
 
 /*
- * TX ring index number for rt2x00_pci structure.
+ * TX ring index number for rt2x00_dev structure.
  */
 enum ring_index {
-	RING_AC_BK = 0,
-	RING_AC_BE = 1,
-	RING_AC_VI = 2,
-	RING_AC_VO = 3,
+	RING_AC_VO = 0,
+	RING_AC_VI = 1,
+	RING_AC_BE = 2,
+	RING_AC_BK = 3,
 	RING_PRIO = 4,
 	RING_BEACON = 5,
 	RING_RX = 6,
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 12:48:57.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:10:11.000000000 +0100
@@ -1186,16 +1186,16 @@
 	if (rt73usb_alloc_dma_ring(rt2x00dev, RING_RX,
 		rt73usb_rxdone, RX_ENTRIES, DATA_FRAME_SIZE,
 		RXD_DESC_SIZE) ||
-	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_BK,
+	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_VO,
 		rt73usb_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_BE,
+	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_VI,
 		rt73usb_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_VI,
+	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_BE,
 		rt73usb_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
-	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_VO,
+	    rt73usb_alloc_dma_ring(rt2x00dev, RING_AC_BK,
 		rt73usb_txdone, TX_ENTRIES, DATA_FRAME_SIZE,
 		TXD_DESC_SIZE) ||
 	    rt73usb_alloc_dma_ring(rt2x00dev, RING_PRIO,
@@ -1213,10 +1213,10 @@
 static void rt73usb_free_rings(struct rt2x00_dev *rt2x00dev)
 {
 	rt73usb_free_ring(rt2x00dev, RING_RX);
-	rt73usb_free_ring(rt2x00dev, RING_AC_BK);
-	rt73usb_free_ring(rt2x00dev, RING_AC_BE);
-	rt73usb_free_ring(rt2x00dev, RING_AC_VI);
 	rt73usb_free_ring(rt2x00dev, RING_AC_VO);
+	rt73usb_free_ring(rt2x00dev, RING_AC_VI);
+	rt73usb_free_ring(rt2x00dev, RING_AC_BE);
+	rt73usb_free_ring(rt2x00dev, RING_AC_BK);
 	rt73usb_free_ring(rt2x00dev, RING_PRIO);
 	rt73usb_free_ring(rt2x00dev, RING_BEACON);
 }
@@ -1273,10 +1273,10 @@
 static int rt73usb_init_rings(struct rt2x00_dev *rt2x00dev)
 {
 	rt73usb_init_rxring(rt2x00dev, RING_RX);
-	rt73usb_init_txring(rt2x00dev, RING_AC_BK);
-	rt73usb_init_txring(rt2x00dev, RING_AC_BE);
-	rt73usb_init_txring(rt2x00dev, RING_AC_VI);
 	rt73usb_init_txring(rt2x00dev, RING_AC_VO);
+	rt73usb_init_txring(rt2x00dev, RING_AC_VI);
+	rt73usb_init_txring(rt2x00dev, RING_AC_BE);
+	rt73usb_init_txring(rt2x00dev, RING_AC_BK);
 	rt73usb_init_txring(rt2x00dev, RING_PRIO);
 	rt73usb_init_txring(rt2x00dev, RING_BEACON);
 
@@ -1620,19 +1620,19 @@
 	for (i = 0; i < ring->stats.limit; i++)
 		usb_kill_urb(rt2x00_urb(&ring->entry[i]));
 
-	ring = &rt2x00dev->ring[RING_AC_BK];
+	ring = &rt2x00dev->ring[RING_AC_VO];
 	for (i = 0; i < ring->stats.limit; i++)
 		usb_kill_urb(rt2x00_urb(&ring->entry[i]));
 
-	ring = &rt2x00dev->ring[RING_AC_BE];
+	ring = &rt2x00dev->ring[RING_AC_VI];
 	for (i = 0; i < ring->stats.limit; i++)
 		usb_kill_urb(rt2x00_urb(&ring->entry[i]));
 
-	ring = &rt2x00dev->ring[RING_AC_VI];
+	ring = &rt2x00dev->ring[RING_AC_BE];
 	for (i = 0; i < ring->stats.limit; i++)
 		usb_kill_urb(rt2x00_urb(&ring->entry[i]));
 
-	ring = &rt2x00dev->ring[RING_AC_VO];
+	ring = &rt2x00dev->ring[RING_AC_BK];
 	for (i = 0; i < ring->stats.limit; i++)
 		usb_kill_urb(rt2x00_urb(&ring->entry[i]));
 
@@ -2035,10 +2035,10 @@
 	 * to start scanning.
 	 */
 	if (rt2x00dev->scan &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BK]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BK]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
 		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
@@ -2524,17 +2524,17 @@
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA0],
-		&rt2x00dev->ring[RING_AC_BK].stats,
-		sizeof(rt2x00dev->ring[RING_AC_BK].stats));
+		&rt2x00dev->ring[RING_AC_VO].stats,
+		sizeof(rt2x00dev->ring[RING_AC_VO].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA1],
-		&rt2x00dev->ring[RING_AC_BE].stats,
-		sizeof(rt2x00dev->ring[RING_AC_BE].stats));
-	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA2],
 		&rt2x00dev->ring[RING_AC_VI].stats,
 		sizeof(rt2x00dev->ring[RING_AC_VI].stats));
+	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA2],
+		&rt2x00dev->ring[RING_AC_BE].stats,
+		sizeof(rt2x00dev->ring[RING_AC_BE].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA3],
-		&rt2x00dev->ring[RING_AC_VO].stats,
-		sizeof(rt2x00dev->ring[RING_AC_VO].stats));
+		&rt2x00dev->ring[RING_AC_BK].stats,
+		sizeof(rt2x00dev->ring[RING_AC_BK].stats));
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA4],
 		&rt2x00dev->ring[RING_PRIO].stats,
 		sizeof(rt2x00dev->ring[RING_PRIO].stats));
diff -rU3 wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-usbeeprom/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 13:01:47.000000000 +0100
+++ wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-12-03 13:04:31.000000000 +0100
@@ -891,13 +891,13 @@
 #define RXD_W5_RESERVED			FIELD32(0xffffffff)
 
 /*
- * TX ring index number for rt2x00_usb structure.
+ * TX ring index number for rt2x00_dev structure.
  */
 enum ring_index {
-	RING_AC_BK = 0,
-	RING_AC_BE = 1,
-	RING_AC_VI = 2,
-	RING_AC_VO = 3,
+	RING_AC_VO = 0,
+	RING_AC_VI = 1,
+	RING_AC_BE = 2,
+	RING_AC_BK = 3,
 	RING_PRIO = 4,
 	RING_BEACON = 5,
 	RING_RX = 6,
