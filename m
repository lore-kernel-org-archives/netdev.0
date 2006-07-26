From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 19/24] RT2x00: Simplify *_reset() functions
Date: Wed, 26 Jul 2006 19:05:45 +0200
Message-ID: <200607261905.45466.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030331AbWGZRHq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:46 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:46 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

The reset function can be greatly simplified.
when a reset is required the best thing to do,
is to switch the radio off and on again.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-25 23:27:17.000000000 +0200
+++ wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 10:41:21.000000000 +0200
@@ -1905,42 +1905,9 @@
 static int rt2400pci_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-	u32 reg;
-
-	/*
-	 * Cancel RX and TX.
-	 */
-	rt2x00_register_read(rt2x00dev, TXCSR0, &reg);
-	rt2x00_set_field32(&reg, TXCSR0_ABORT, 1);
-	rt2x00_register_write(rt2x00dev, TXCSR0, reg);
-
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
-	/*
-	 * Clear interrupts.
-	 */
-	rt2x00_register_read(rt2x00dev, CSR7, &reg);
-	rt2x00_register_write(rt2x00dev, CSR7, reg);
 
-	/*
-	 * Clear all rings, and reinitialize.
-	 */
-	rt2400pci_init_rxdesc(rt2x00dev, &rt2x00dev->ring[RING_RX]);
-	rt2400pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_TX]);
-	rt2400pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_ATIM]);
-	rt2400pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_PRIO]);
-	rt2400pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_BEACON]);
-
-	/*
-	 * Enable RX again.
-	 */
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
-	return 0;
+	rt2400pci_disable_radio(rt2x00dev);
+	return rt2400pci_enable_radio(rt2x00dev);
 }
 
 static int rt2400pci_add_interface(struct net_device *net_dev,
diff -rU3 wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-25 23:27:54.000000000 +0200
+++ wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 10:41:32.000000000 +0200
@@ -2040,42 +2040,9 @@
 static int rt2500pci_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-	u32 reg;
-
-	/*
-	 * Cancel RX and TX.
-	 */
-	rt2x00_register_read(rt2x00dev, TXCSR0, &reg);
-	rt2x00_set_field32(&reg, TXCSR0_ABORT, 1);
-	rt2x00_register_write(rt2x00dev, TXCSR0, reg);
-
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
-	/*
-	 * Clear interrupts.
-	 */
-	rt2x00_register_read(rt2x00dev, CSR7, &reg);
-	rt2x00_register_write(rt2x00dev, CSR7, reg);
 
-	/*
-	 * Clear all rings, and reinitialize.
-	 */
-	rt2500pci_init_rxdesc(rt2x00dev, &rt2x00dev->ring[RING_RX]);
-	rt2500pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_TX]);
-	rt2500pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_ATIM]);
-	rt2500pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_PRIO]);
-	rt2500pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_BEACON]);
-
-	/*
-	 * Enable RX again.
-	 */
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
-	return 0;
+	rt2500pci_disable_radio(rt2x00dev);
+	return rt2500pci_enable_radio(rt2x00dev);
 }
 
 static int rt2500pci_add_interface(struct net_device *net_dev,
diff -rU3 wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-25 23:28:54.000000000 +0200
+++ wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 10:42:02.000000000 +0200
@@ -1738,28 +1738,12 @@
 	return NETDEV_TX_OK;
 }
 
-static inline void rt2500usb_reset_ring(struct data_ring *ring)
-{
-	unsigned int i;
-
-	for (i = 0; i < ring->stats.limit; i++)
-		usb_kill_urb(ring->entry[i].urb);
-}
-
 static int rt2500usb_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
-	rt2500usb_reset_ring(&rt2x00dev->ring[RING_RX]);
-	rt2500usb_reset_ring(&rt2x00dev->ring[RING_TX]);
-	rt2500usb_reset_ring(&rt2x00dev->ring[RING_ATIM]);
-	rt2500usb_reset_ring(&rt2x00dev->ring[RING_PRIO]);
-	rt2500usb_reset_ring(&rt2x00dev->ring[RING_BEACON]);
-
-	/*
-	 * Reinitialize rings.
-	 */
-	return rt2500usb_init_rings(rt2x00dev);
+	rt2500usb_disable_radio(rt2x00dev);
+	return rt2500usb_enable_radio(rt2x00dev);
 }
 
 static int rt2500usb_add_interface(struct net_device *net_dev,
diff -rU3 wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-25 23:29:39.000000000 +0200
+++ wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 
10:41:48.000000000 +0200
@@ -2555,51 +2555,9 @@
 static int rt61pci_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-	u32 reg;
-
-	/*
-	 * Cancel RX and TX.
-	 */
-	rt2x00_register_read(rt2x00dev, TX_CNTL_CSR, &reg);
-	rt2x00_set_field32(&reg, TX_CNTL_CSR_ABORT_TX_AC0, 1);
-	rt2x00_set_field32(&reg, TX_CNTL_CSR_ABORT_TX_AC1, 1);
-	rt2x00_set_field32(&reg, TX_CNTL_CSR_ABORT_TX_AC2, 1);
-	rt2x00_set_field32(&reg, TX_CNTL_CSR_ABORT_TX_AC3, 1);
-	rt2x00_set_field32(&reg, TX_CNTL_CSR_ABORT_TX_MGMT, 1);
-	rt2x00_register_write(rt2x00dev, TX_CNTL_CSR, reg);
-
-	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-	rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 1);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-
-	/*
-	 * Clear interrupts.
-	 */
-	rt2x00_register_read(rt2x00dev, MCU_INT_SOURCE_CSR, &reg);
-	rt2x00_register_write(rt2x00dev, MCU_INT_SOURCE_CSR, reg);
-
-	rt2x00_register_read(rt2x00dev, INT_SOURCE_CSR, &reg);
-	rt2x00_register_write(rt2x00dev, INT_SOURCE_CSR, reg);
 
-	/*
-	 * Clear all rings, and reinitialize.
-	 */
-	rt61pci_init_rxdesc(rt2x00dev, &rt2x00dev->ring[RING_RX]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_AC_BK]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_AC_BE]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_AC_VI]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_AC_VO]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_PRIO]);
-	rt61pci_init_txdesc(rt2x00dev, &rt2x00dev->ring[RING_BEACON]);
-
-	/*
-	 * Enable RX again.
-	 */
-	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-	rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-
-	return 0;
+	rt61pci_disable_radio(rt2x00dev);
+	return rt61pci_enable_radio(rt2x00dev);
 }
 
 static int rt61pci_add_interface(struct net_device *net_dev,
diff -rU3 wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-suspend/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-25 23:30:19.000000000 +0200
+++ wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 
10:42:19.000000000 +0200
@@ -2053,30 +2053,11 @@
 	return NETDEV_TX_OK;
 }
 
-static inline void rt73usb_reset_ring(struct data_ring *ring)
-{
-	unsigned int i;
-
-	for (i = 0; i < ring->stats.limit; i++)
-		usb_kill_urb(ring->entry[i].urb);
-}
-
 static int rt73usb_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_RX]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_AC_BK]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_AC_BE]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_AC_VI]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_AC_VO]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_PRIO]);
-	rt73usb_reset_ring(&rt2x00dev->ring[RING_BEACON]);
-
-	/*
-	 * Reinitialize rings.
-	 */
-	return rt73usb_init_rings(rt2x00dev);
+	rt73usb_disable_radio(rt2x00dev);
+	return rt73usb_enable_radio(rt2x00dev);
 }
 
 static int rt73usb_add_interface(struct net_device *net_dev,
