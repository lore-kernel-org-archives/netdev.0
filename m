From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next] rt2x00: Use more current logging styles,
 shrink object size
Date: Fri, 19 Apr 2013 01:33:26 -0700
Message-ID: <1366360406.3901.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce object size ~2% using more current logging styles.

Neaten and simplify logging macros.
Use wiphy_<level> where appropriate.
Coalesce formats.

Convert ERROR/WARNING/INFO macros and uses to rt2x00_<level>
Convert EEPROM to rt2x00_eeprom_dbg
Convert PROBE_ERROR to rt2x00_probe_err

$ size drivers/net/wireless/rt2x00/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 245537	  71696	  69584	 386817	  5e701	drivers/net/wireless/rt2x00/built-in.o.new
 240609	  70096	  68944	 379649	  5cb01	drivers/net/wireless/rt2x00/built-in.o.new.no_dyn_debug
 240609	  70096	  68944	 379649	  5cb01	drivers/net/wireless/rt2x00/built-in.o.new.no_rt2x00_debug
 249198	  70096	  70352	 389646	  5f20e	drivers/net/wireless/rt2x00/built-in.o.old
 249198	  70096	  70352	 389646	  5f20e	drivers/net/wireless/rt2x00/built-in.o.old.no_dyn_debug
 244222	  70096	  69712	 384030	  5dc1e	drivers/net/wireless/rt2x00/built-in.o.old.no_rt2x00_debug

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rt2x00/rt2400pci.c      | 14 +++---
 drivers/net/wireless/rt2x00/rt2500pci.c      | 19 ++++----
 drivers/net/wireless/rt2x00/rt2500usb.c      | 35 +++++++-------
 drivers/net/wireless/rt2x00/rt2800lib.c      | 35 +++++++-------
 drivers/net/wireless/rt2x00/rt2800pci.c      | 26 +++++-----
 drivers/net/wireless/rt2x00/rt2800usb.c      | 41 ++++++++--------
 drivers/net/wireless/rt2x00/rt2x00.h         | 72 +++++++++++++---------------
 drivers/net/wireless/rt2x00/rt2x00debug.c    |  8 ++--
 drivers/net/wireless/rt2x00/rt2x00dev.c      | 24 +++++-----
 drivers/net/wireless/rt2x00/rt2x00firmware.c | 25 +++++-----
 drivers/net/wireless/rt2x00/rt2x00leds.c     |  2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      | 17 +++----
 drivers/net/wireless/rt2x00/rt2x00mmio.c     |  4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c      | 14 +++---
 drivers/net/wireless/rt2x00/rt2x00queue.c    | 41 ++++++++--------
 drivers/net/wireless/rt2x00/rt2x00soc.c      |  4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c      | 24 +++++-----
 drivers/net/wireless/rt2x00/rt61pci.c        | 33 +++++++------
 drivers/net/wireless/rt2x00/rt73usb.c        | 30 ++++++------
 19 files changed, 230 insertions(+), 238 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index d1b10d4..f714373 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -920,7 +920,7 @@ static int rt2400pci_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -1093,8 +1093,8 @@ static int rt2400pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -1188,7 +1188,7 @@ static void rt2400pci_write_beacon(struct queue_entry *entry,
 	rt2x00mmio_register_write(rt2x00dev, CSR14, reg);
 
 	if (rt2x00queue_map_txskb(entry)) {
-		ERROR(rt2x00dev, "Fail to map beacon, aborting\n");
+		rt2x00_err(rt2x00dev, "Fail to map beacon, aborting\n");
 		goto out;
 	}
 	/*
@@ -1464,12 +1464,12 @@ static int rt2400pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
 	if (word == 0xffff) {
-		ERROR(rt2x00dev, "Invalid EEPROM data detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid EEPROM data detected\n");
 		return -EINVAL;
 	}
 
@@ -1496,7 +1496,7 @@ static int rt2400pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 			rt2x00_get_field32(reg, CSR0_REVISION));
 
 	if (!rt2x00_rf(rt2x00dev, RF2420) && !rt2x00_rf(rt2x00dev, RF2421)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RF chipset detected\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 9ba1457..77e45b2 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1058,7 +1058,7 @@ static int rt2500pci_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -1246,8 +1246,8 @@ static int rt2500pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -1340,7 +1340,7 @@ static void rt2500pci_write_beacon(struct queue_entry *entry,
 	rt2x00mmio_register_write(rt2x00dev, CSR14, reg);
 
 	if (rt2x00queue_map_txskb(entry)) {
-		ERROR(rt2x00dev, "Fail to map beacon, aborting\n");
+		rt2x00_err(rt2x00dev, "Fail to map beacon, aborting\n");
 		goto out;
 	}
 
@@ -1590,7 +1590,7 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
@@ -1606,7 +1606,7 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_HARDWARE_RADIO, 0);
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_RF_TYPE, RF2522);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_ANTENNA, word);
-		EEPROM(rt2x00dev, "Antenna: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Antenna: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &word);
@@ -1615,7 +1615,7 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_NIC_DYN_BBP_TUNE, 0);
 		rt2x00_set_field16(&word, EEPROM_NIC_CCK_TX_POWER, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC, word);
-		EEPROM(rt2x00dev, "NIC: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "NIC: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_CALIBRATE_OFFSET, &word);
@@ -1623,7 +1623,8 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_CALIBRATE_OFFSET_RSSI,
 				   DEFAULT_RSSI_OFFSET);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_CALIBRATE_OFFSET, word);
-		EEPROM(rt2x00dev, "Calibrate offset: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Calibrate offset: 0x%04x\n",
+				  word);
 	}
 
 	return 0;
@@ -1654,7 +1655,7 @@ static int rt2500pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	    !rt2x00_rf(rt2x00dev, RF2525) &&
 	    !rt2x00_rf(rt2x00dev, RF2525E) &&
 	    !rt2x00_rf(rt2x00dev, RF5222)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RF chipset detected\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 6b2e1e43..a7f7b36 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -134,8 +134,8 @@ static int rt2500usb_regbusy_read(struct rt2x00_dev *rt2x00dev,
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=0x%.08x, value=0x%.08x\n", offset, *reg);
+	rt2x00_err(rt2x00dev, "Indirect register access failed: offset=0x%.08x, value=0x%.08x\n",
+		   offset, *reg);
 	*reg = ~0;
 
 	return 0;
@@ -916,7 +916,7 @@ static int rt2500usb_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -1069,8 +1069,8 @@ static int rt2500usb_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -1353,7 +1353,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
@@ -1369,7 +1369,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_HARDWARE_RADIO, 0);
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_RF_TYPE, RF2522);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_ANTENNA, word);
-		EEPROM(rt2x00dev, "Antenna: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Antenna: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &word);
@@ -1378,7 +1378,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_NIC_DYN_BBP_TUNE, 0);
 		rt2x00_set_field16(&word, EEPROM_NIC_CCK_TX_POWER, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC, word);
-		EEPROM(rt2x00dev, "NIC: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "NIC: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_CALIBRATE_OFFSET, &word);
@@ -1386,14 +1386,15 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_CALIBRATE_OFFSET_RSSI,
 				   DEFAULT_RSSI_OFFSET);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_CALIBRATE_OFFSET, word);
-		EEPROM(rt2x00dev, "Calibrate offset: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Calibrate offset: 0x%04x\n",
+				  word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE, &word);
 	if (word == 0xffff) {
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_THRESHOLD, 45);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE, word);
-		EEPROM(rt2x00dev, "BBPtune: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune: 0x%04x\n", word);
 	}
 
 	/*
@@ -1408,7 +1409,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCUPPER, 0x40);
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCLOWER, bbp);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_VGC, word);
-		EEPROM(rt2x00dev, "BBPtune vgc: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune vgc: 0x%04x\n", word);
 	} else {
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_VGCLOWER, bbp);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_VGC, word);
@@ -1419,7 +1420,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R17_LOW, 0x48);
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R17_HIGH, 0x41);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_R17, word);
-		EEPROM(rt2x00dev, "BBPtune r17: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune r17: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE_R24, &word);
@@ -1427,7 +1428,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R24_LOW, 0x40);
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R24_HIGH, 0x80);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_R24, word);
-		EEPROM(rt2x00dev, "BBPtune r24: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune r24: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE_R25, &word);
@@ -1435,7 +1436,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R25_LOW, 0x40);
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R25_HIGH, 0x50);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_R25, word);
-		EEPROM(rt2x00dev, "BBPtune r25: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune r25: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_BBPTUNE_R61, &word);
@@ -1443,7 +1444,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R61_LOW, 0x60);
 		rt2x00_set_field16(&word, EEPROM_BBPTUNE_R61_HIGH, 0x6d);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_BBPTUNE_R61, word);
-		EEPROM(rt2x00dev, "BBPtune r61: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "BBPtune r61: 0x%04x\n", word);
 	}
 
 	return 0;
@@ -1468,7 +1469,7 @@ static int rt2500usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_chip(rt2x00dev, RT2570, value, reg);
 
 	if (((reg & 0xfff0) != 0) || ((reg & 0x0000000f) == 0)) {
-		ERROR(rt2x00dev, "Invalid RT chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RT chipset detected\n");
 		return -ENODEV;
 	}
 
@@ -1478,7 +1479,7 @@ static int rt2500usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	    !rt2x00_rf(rt2x00dev, RF2525) &&
 	    !rt2x00_rf(rt2x00dev, RF2525E) &&
 	    !rt2x00_rf(rt2x00dev, RF5222)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RF chipset detected\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 72bbb96..958c837 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -80,7 +80,7 @@ static inline bool rt2800_is_305x_soc(struct rt2x00_dev *rt2x00dev)
 	    rt2x00_rf(rt2x00dev, RF3022))
 		return true;
 
-	WARNING(rt2x00dev, "Unknown RF chipset on rt305x\n");
+	rt2x00_warn(rt2x00dev, "Unknown RF chipset on rt305x\n");
 	return false;
 }
 
@@ -328,7 +328,7 @@ int rt2800_wait_csr_ready(struct rt2x00_dev *rt2x00dev)
 		msleep(1);
 	}
 
-	ERROR(rt2x00dev, "Unstable hardware.\n");
+	rt2x00_err(rt2x00dev, "Unstable hardware\n");
 	return -EBUSY;
 }
 EXPORT_SYMBOL_GPL(rt2800_wait_csr_ready);
@@ -351,7 +351,7 @@ int rt2800_wait_wpdma_ready(struct rt2x00_dev *rt2x00dev)
 		msleep(10);
 	}
 
-	ERROR(rt2x00dev, "WPDMA TX/RX busy [0x%08x].\n", reg);
+	rt2x00_err(rt2x00dev, "WPDMA TX/RX busy [0x%08x]\n", reg);
 	return -EACCES;
 }
 EXPORT_SYMBOL_GPL(rt2800_wait_wpdma_ready);
@@ -512,7 +512,7 @@ int rt2800_load_firmware(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (i == REGISTER_BUSY_COUNT) {
-		ERROR(rt2x00dev, "PBF system register not ready.\n");
+		rt2x00_err(rt2x00dev, "PBF system register not ready\n");
 		return -EBUSY;
 	}
 
@@ -803,7 +803,7 @@ void rt2800_write_beacon(struct queue_entry *entry, struct txentry_desc *txdesc)
 	 */
 	padding_len = roundup(entry->skb->len, 4) - entry->skb->len;
 	if (padding_len && skb_pad(entry->skb, padding_len)) {
-		ERROR(rt2x00dev, "Failure padding beacon, aborting\n");
+		rt2x00_err(rt2x00dev, "Failure padding beacon, aborting\n");
 		/* skb freed by skb_pad() on failure */
 		entry->skb = NULL;
 		rt2800_register_write(rt2x00dev, BCN_TIME_CFG, orig_reg);
@@ -3860,7 +3860,7 @@ static int rt2800_wait_bbp_rf_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP/RF register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP/RF register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -3884,7 +3884,7 @@ static int rt2800_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -5312,7 +5312,7 @@ static int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC_CONF0, &word);
@@ -5321,7 +5321,7 @@ static int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_NIC_CONF0_TXPATH, 1);
 		rt2x00_set_field16(&word, EEPROM_NIC_CONF0_RF_TYPE, RF2820);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC_CONF0, word);
-		EEPROM(rt2x00dev, "Antenna: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Antenna: 0x%04x\n", word);
 	} else if (rt2x00_rt(rt2x00dev, RT2860) ||
 		   rt2x00_rt(rt2x00dev, RT2872)) {
 		/*
@@ -5350,14 +5350,14 @@ static int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_NIC_CONF1_BT_COEXIST, 0);
 		rt2x00_set_field16(&word, EEPROM_NIC_CONF1_DAC_TEST, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC_CONF1, word);
-		EEPROM(rt2x00dev, "NIC: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "NIC: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_FREQ, &word);
 	if ((word & 0x00ff) == 0x00ff) {
 		rt2x00_set_field16(&word, EEPROM_FREQ_OFFSET, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_FREQ, word);
-		EEPROM(rt2x00dev, "Freq: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Freq: 0x%04x\n", word);
 	}
 	if ((word & 0xff00) == 0xff00) {
 		rt2x00_set_field16(&word, EEPROM_FREQ_LED_MODE,
@@ -5367,7 +5367,7 @@ static int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_LED_AG_CONF, 0x5555);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_LED_ACT_CONF, 0x2221);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_LED_POLARITY, 0xa9f8);
-		EEPROM(rt2x00dev, "Led Mode: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Led Mode: 0x%04x\n", word);
 	}
 
 	/*
@@ -5473,7 +5473,8 @@ static int rt2800_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	case RF5592:
 		break;
 	default:
-		ERROR(rt2x00dev, "Invalid RF chipset 0x%04x detected.\n", rf);
+		rt2x00_err(rt2x00dev, "Invalid RF chipset 0x%04x detected\n",
+			   rf);
 		return -ENODEV;
 	}
 
@@ -6062,9 +6063,8 @@ static int rt2800_probe_rt(struct rt2x00_dev *rt2x00dev)
 	case RT5592:
 		break;
 	default:
-		ERROR(rt2x00dev,
-		      "Invalid RT chipset 0x%04x, rev %04x detected.\n",
-		      rt, rev);
+		rt2x00_err(rt2x00dev, "Invalid RT chipset 0x%04x, rev %04x detected\n",
+			   rt, rev);
 		return -ENODEV;
 	}
 
@@ -6323,7 +6323,8 @@ int rt2800_ampdu_action(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
 		break;
 	default:
-		WARNING((struct rt2x00_dev *)hw->priv, "Unknown AMPDU action\n");
+		rt2x00_warn((struct rt2x00_dev *)hw->priv,
+			    "Unknown AMPDU action\n");
 	}
 
 	return ret;
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index def357e..274adb2 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -84,7 +84,7 @@ static void rt2800pci_mcu_status(struct rt2x00_dev *rt2x00dev, const u8 token)
 	}
 
 	if (i == 200)
-		ERROR(rt2x00dev, "MCU request failed, no response from hardware\n");
+		rt2x00_err(rt2x00dev, "MCU request failed, no response from hardware\n");
 
 	rt2x00mmio_register_write(rt2x00dev, H2M_MAILBOX_STATUS, ~0);
 	rt2x00mmio_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
@@ -616,8 +616,8 @@ static int rt2800pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -848,8 +848,8 @@ static bool rt2800pci_txdone(struct rt2x00_dev *rt2x00dev)
 			 * Unknown queue, this shouldn't happen. Just drop
 			 * this tx status.
 			 */
-			WARNING(rt2x00dev, "Got TX status report with "
-					   "unexpected pid %u, dropping\n", qid);
+			rt2x00_warn(rt2x00dev, "Got TX status report with unexpected pid %u, dropping\n",
+				    qid);
 			break;
 		}
 
@@ -859,8 +859,8 @@ static bool rt2800pci_txdone(struct rt2x00_dev *rt2x00dev)
 			 * The queue is NULL, this shouldn't happen. Stop
 			 * processing here and drop the tx status
 			 */
-			WARNING(rt2x00dev, "Got TX status for an unavailable "
-					   "queue %u, dropping\n", qid);
+			rt2x00_warn(rt2x00dev, "Got TX status for an unavailable queue %u, dropping\n",
+				    qid);
 			break;
 		}
 
@@ -869,8 +869,8 @@ static bool rt2800pci_txdone(struct rt2x00_dev *rt2x00dev)
 			 * The queue is empty. Stop processing here
 			 * and drop the tx status.
 			 */
-			WARNING(rt2x00dev, "Got TX status for an empty "
-					   "queue %u, dropping\n", qid);
+			rt2x00_warn(rt2x00dev, "Got TX status for an empty queue %u, dropping\n",
+				    qid);
 			break;
 		}
 
@@ -888,9 +888,8 @@ static bool rt2800pci_txdone(struct rt2x00_dev *rt2x00dev)
 			if (!rt2x00queue_for_each_entry(queue, Q_INDEX_DONE,
 							Q_INDEX, &status,
 							rt2800pci_txdone_match_first)) {
-				WARNING(rt2x00dev, "No frame found for TX "
-						   "status on queue %u, dropping\n",
-						   qid);
+				rt2x00_warn(rt2x00dev, "No frame found for TX status on queue %u, dropping\n",
+					    qid);
 				break;
 			}
 		}
@@ -1027,8 +1026,7 @@ static void rt2800pci_txstatus_interrupt(struct rt2x00_dev *rt2x00dev)
 			break;
 
 		if (!kfifo_put(&rt2x00dev->txstatus_fifo, &status)) {
-			WARNING(rt2x00dev, "TX status FIFO overrun,"
-				"drop tx status report.\n");
+			rt2x00_warn(rt2x00dev, "TX status FIFO overrun, drop tx status report\n");
 			break;
 		}
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index f322820..20a2678 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -128,9 +128,9 @@ static inline bool rt2800usb_entry_txstatus_timeout(struct queue_entry *entry)
 
 	tout = time_after(jiffies, entry->last_action + msecs_to_jiffies(100));
 	if (unlikely(tout))
-		WARNING(entry->queue->rt2x00dev,
-			"TX status timeout for entry %d in queue %d\n",
-			entry->entry_idx, entry->queue->qid);
+		rt2x00_warn(entry->queue->rt2x00dev,
+			    "TX status timeout for entry %d in queue %d\n",
+			    entry->entry_idx, entry->queue->qid);
 	return tout;
 
 }
@@ -154,7 +154,8 @@ static bool rt2800usb_tx_sta_fifo_read_completed(struct rt2x00_dev *rt2x00dev,
 	bool valid;
 
 	if (urb_status) {
-		WARNING(rt2x00dev, "TX status read failed %d\n", urb_status);
+		rt2x00_warn(rt2x00dev, "TX status read failed %d\n",
+			    urb_status);
 
 		goto stop_reading;
 	}
@@ -162,7 +163,7 @@ static bool rt2800usb_tx_sta_fifo_read_completed(struct rt2x00_dev *rt2x00dev,
 	valid = rt2x00_get_field32(tx_status, TX_STA_FIFO_VALID);
 	if (valid) {
 		if (!kfifo_put(&rt2x00dev->txstatus_fifo, &tx_status))
-			WARNING(rt2x00dev, "TX status FIFO overrun\n");
+			rt2x00_warn(rt2x00dev, "TX status FIFO overrun\n");
 
 		queue_work(rt2x00dev->workqueue, &rt2x00dev->txdone_work);
 
@@ -269,7 +270,7 @@ static int rt2800usb_write_firmware(struct rt2x00_dev *rt2x00dev,
 					     0, USB_MODE_FIRMWARE,
 					     REGISTER_TIMEOUT_FIRMWARE);
 	if (status < 0) {
-		ERROR(rt2x00dev, "Failed to write Firmware to device.\n");
+		rt2x00_err(rt2x00dev, "Failed to write Firmware to device\n");
 		return status;
 	}
 
@@ -392,8 +393,8 @@ static int rt2800usb_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -408,8 +409,7 @@ static void rt2800usb_watchdog(struct rt2x00_dev *rt2x00dev)
 
 	rt2x00usb_register_read(rt2x00dev, TXRXQ_PCNT, &reg);
 	if (rt2x00_get_field32(reg, TXRXQ_PCNT_TX0Q)) {
-		WARNING(rt2x00dev, "TX HW queue 0 timed out,"
-			" invoke forced kick\n");
+		rt2x00_warn(rt2x00dev, "TX HW queue 0 timed out, invoke forced kick\n");
 
 		rt2x00usb_register_write(rt2x00dev, PBF_CFG, 0xf40012);
 
@@ -424,8 +424,7 @@ static void rt2800usb_watchdog(struct rt2x00_dev *rt2x00dev)
 
 	rt2x00usb_register_read(rt2x00dev, TXRXQ_PCNT, &reg);
 	if (rt2x00_get_field32(reg, TXRXQ_PCNT_TX1Q)) {
-		WARNING(rt2x00dev, "TX HW queue 1 timed out,"
-			" invoke forced kick\n");
+		rt2x00_warn(rt2x00dev, "TX HW queue 1 timed out, invoke forced kick\n");
 
 		rt2x00usb_register_write(rt2x00dev, PBF_CFG, 0xf4000a);
 
@@ -540,9 +539,9 @@ rt2800usb_txdone_entry_check(struct queue_entry *entry, u32 reg)
 	tx_pid  = rt2x00_get_field32(word, TXWI_W1_PACKETID);
 
 	if (wcid != tx_wcid || ack != tx_ack || (!is_agg && pid != tx_pid)) {
-		DEBUG(entry->queue->rt2x00dev,
-		      "TX status report missed for queue %d entry %d\n",
-		      entry->queue->qid, entry->entry_idx);
+		rt2x00_dbg(entry->queue->rt2x00dev,
+			   "TX status report missed for queue %d entry %d\n",
+			   entry->queue->qid, entry->entry_idx);
 		return TXDONE_UNKNOWN;
 	}
 
@@ -566,8 +565,8 @@ static void rt2800usb_txdone(struct rt2x00_dev *rt2x00dev)
 		queue = rt2x00queue_get_tx_queue(rt2x00dev, qid);
 
 		if (unlikely(rt2x00queue_empty(queue))) {
-			WARNING(rt2x00dev, "Got TX status for an empty "
-					   "queue %u, dropping\n", qid);
+			rt2x00_warn(rt2x00dev, "Got TX status for an empty queue %u, dropping\n",
+				    qid);
 			break;
 		}
 
@@ -575,8 +574,8 @@ static void rt2800usb_txdone(struct rt2x00_dev *rt2x00dev)
 
 		if (unlikely(test_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags) ||
 			     !test_bit(ENTRY_DATA_STATUS_PENDING, &entry->flags))) {
-			WARNING(rt2x00dev, "Data pending for entry %u "
-					   "in queue %u\n", entry->entry_idx, qid);
+			rt2x00_warn(rt2x00dev, "Data pending for entry %u in queue %u\n",
+				    entry->entry_idx, qid);
 			break;
 		}
 
@@ -677,8 +676,8 @@ static void rt2800usb_fill_rxdone(struct queue_entry *entry,
 	 */
 	if (unlikely(rx_pkt_len == 0 ||
 			rx_pkt_len > entry->queue->data_size)) {
-		ERROR(entry->queue->rt2x00dev,
-			"Bad frame size %d, forcing to 0\n", rx_pkt_len);
+		rt2x00_err(entry->queue->rt2x00dev,
+			   "Bad frame size %d, forcing to 0\n", rx_pkt_len);
 		return;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 0d02d16..249d416 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -54,47 +54,40 @@
 #define DRV_VERSION	"2.3.0"
 #define DRV_PROJECT	"http://rt2x00.serialmonkey.com"
 
-/*
- * Debug definitions.
- * Debug output has to be enabled during compile time.
+/* Utility printing macros */
+#define rt2x00_err(dev, fmt, ...)					\
+	wiphy_err((dev)->hw->wiphy, "%s: Error - " fmt,			\
+		  __func__, ##__VA_ARGS__)
+#define rt2x00_warn(dev, fmt, ...)					\
+	wiphy_err((dev)->hw->wiphy, "%s: Warning - " fmt,		\
+		  __func__, ##__VA_ARGS__)
+#define rt2x00_info(dev, fmt, ...)					\
+	wiphy_err((dev)->hw->wiphy, "%s: Info - " fmt,			\
+		  __func__, ##__VA_ARGS__)
+
+/* The special rt2x00_probe_err message form is used
+ * when the rt2x00_dev is not yet initialized.
  */
-#define DEBUG_PRINTK_MSG(__dev, __kernlvl, __lvl, __msg, __args...)	\
-	printk(__kernlvl "%s -> %s: %s - " __msg,			\
-	       wiphy_name((__dev)->hw->wiphy), __func__, __lvl, ##__args)
-
-#define DEBUG_PRINTK_PROBE(__kernlvl, __lvl, __msg, __args...)	\
-	printk(__kernlvl "%s -> %s: %s - " __msg,		\
-	       KBUILD_MODNAME, __func__, __lvl, ##__args)
+#define rt2x00_probe_err(fmt, ...)					\
+	printk(KERN_ERR KBUILD_MODNAME ": %s: Error - " fmt,		\
+	       __func__, ##__VA_ARGS__)
 
+/* Debug definitions.
+ * Debug output has to be enabled during compile time.
+ */
 #ifdef CONFIG_RT2X00_DEBUG
-#define DEBUG_PRINTK(__dev, __kernlvl, __lvl, __msg, __args...)	\
-	DEBUG_PRINTK_MSG(__dev, __kernlvl, __lvl, __msg, ##__args)
-#else
-#define DEBUG_PRINTK(__dev, __kernlvl, __lvl, __msg, __args...)	\
-	do { } while (0)
+#define DEBUG
 #endif /* CONFIG_RT2X00_DEBUG */
 
 /*
  * Various debug levels.
- * The debug levels PANIC and ERROR both indicate serious problems,
- * for this reason they should never be ignored.
- * The special ERROR_PROBE message is for messages that are generated
- * when the rt2x00_dev is not yet initialized.
  */
-#define PANIC(__dev, __msg, __args...) \
-	DEBUG_PRINTK_MSG(__dev, KERN_CRIT, "Panic", __msg, ##__args)
-#define ERROR(__dev, __msg, __args...)	\
-	DEBUG_PRINTK_MSG(__dev, KERN_ERR, "Error", __msg, ##__args)
-#define ERROR_PROBE(__msg, __args...) \
-	DEBUG_PRINTK_PROBE(KERN_ERR, "Error", __msg, ##__args)
-#define WARNING(__dev, __msg, __args...) \
-	DEBUG_PRINTK_MSG(__dev, KERN_WARNING, "Warning", __msg, ##__args)
-#define INFO(__dev, __msg, __args...) \
-	DEBUG_PRINTK_MSG(__dev, KERN_INFO, "Info", __msg, ##__args)
-#define DEBUG(__dev, __msg, __args...) \
-	DEBUG_PRINTK(__dev, KERN_DEBUG, "Debug", __msg, ##__args)
-#define EEPROM(__dev, __msg, __args...) \
-	DEBUG_PRINTK(__dev, KERN_DEBUG, "EEPROM recovery", __msg, ##__args)
+#define rt2x00_dbg(dev, fmt, ...)					\
+	wiphy_dbg((dev)->hw->wiphy, "%s: Debug - " fmt,			\
+		  __func__, ##__VA_ARGS__)
+#define rt2x00_eeprom_dbg(dev, fmt, ...)				\
+	wiphy_dbg((dev)->hw->wiphy, "%s: %s - " fmt,			\
+		  __func__, "EEPROM recovery", ##__VA_ARGS__)
 
 /*
  * Duration calculations
@@ -1101,9 +1094,9 @@ static inline void rt2x00_set_chip(struct rt2x00_dev *rt2x00dev,
 	rt2x00dev->chip.rf = rf;
 	rt2x00dev->chip.rev = rev;
 
-	INFO(rt2x00dev,
-	     "Chipset detected - rt: %04x, rf: %04x, rev: %04x.\n",
-	     rt2x00dev->chip.rt, rt2x00dev->chip.rf, rt2x00dev->chip.rev);
+	rt2x00_info(rt2x00dev, "Chipset detected - rt: %04x, rf: %04x, rev: %04x\n",
+		    rt2x00dev->chip.rt, rt2x00dev->chip.rf,
+		    rt2x00dev->chip.rev);
 }
 
 static inline void rt2x00_set_rt(struct rt2x00_dev *rt2x00dev,
@@ -1112,15 +1105,16 @@ static inline void rt2x00_set_rt(struct rt2x00_dev *rt2x00dev,
 	rt2x00dev->chip.rt = rt;
 	rt2x00dev->chip.rev = rev;
 
-	INFO(rt2x00dev, "RT chipset %04x, rev %04x detected\n",
-	     rt2x00dev->chip.rt, rt2x00dev->chip.rev);
+	rt2x00_info(rt2x00dev, "RT chipset %04x, rev %04x detected\n",
+		    rt2x00dev->chip.rt, rt2x00dev->chip.rev);
 }
 
 static inline void rt2x00_set_rf(struct rt2x00_dev *rt2x00dev, const u16 rf)
 {
 	rt2x00dev->chip.rf = rf;
 
-	INFO(rt2x00dev, "RF chipset %04x detected\n", rt2x00dev->chip.rf);
+	rt2x00_info(rt2x00dev, "RF chipset %04x detected\n",
+		    rt2x00dev->chip.rf);
 }
 
 static inline bool rt2x00_rt(struct rt2x00_dev *rt2x00dev, const u16 rt)
diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 3bb8caf..fe7a7f6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -174,7 +174,7 @@ void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
 	do_gettimeofday(&timestamp);
 
 	if (skb_queue_len(&intf->frame_dump_skbqueue) > 20) {
-		DEBUG(rt2x00dev, "txrx dump queue length exceeded.\n");
+		rt2x00_dbg(rt2x00dev, "txrx dump queue length exceeded\n");
 		return;
 	}
 
@@ -185,7 +185,7 @@ void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
 	skbcopy = alloc_skb(sizeof(*dump_hdr) + skbdesc->desc_len + data_len,
 			    GFP_ATOMIC);
 	if (!skbcopy) {
-		DEBUG(rt2x00dev, "Failed to copy skb for dump.\n");
+		rt2x00_dbg(rt2x00dev, "Failed to copy skb for dump\n");
 		return;
 	}
 
@@ -657,7 +657,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 
 	intf = kzalloc(sizeof(struct rt2x00debug_intf), GFP_KERNEL);
 	if (!intf) {
-		ERROR(rt2x00dev, "Failed to allocate debug handler.\n");
+		rt2x00_err(rt2x00dev, "Failed to allocate debug handler\n");
 		return;
 	}
 
@@ -760,7 +760,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 
 exit:
 	rt2x00debug_deregister(rt2x00dev);
-	ERROR(rt2x00dev, "Failed to register debug handler.\n");
+	rt2x00_err(rt2x00dev, "Failed to register debug handler\n");
 }
 
 void rt2x00debug_deregister(struct rt2x00_dev *rt2x00dev)
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 189744d..90dc143 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -171,7 +171,7 @@ static void rt2x00lib_autowakeup(struct work_struct *work)
 		return;
 
 	if (rt2x00dev->ops->lib->set_device_state(rt2x00dev, STATE_AWAKE))
-		ERROR(rt2x00dev, "Device failed to wakeup.\n");
+		rt2x00_err(rt2x00dev, "Device failed to wakeup\n");
 	clear_bit(CONFIG_POWERSAVING, &rt2x00dev->flags);
 }
 
@@ -673,9 +673,8 @@ static int rt2x00lib_rxdone_read_signal(struct rt2x00_dev *rt2x00dev,
 		break;
 	}
 
-	WARNING(rt2x00dev, "Frame received with unrecognized signal, "
-		"mode=0x%.4x, signal=0x%.4x, type=%d.\n",
-		rxdesc->rate_mode, signal, type);
+	rt2x00_warn(rt2x00dev, "Frame received with unrecognized signal, mode=0x%.4x, signal=0x%.4x, type=%d\n",
+		    rxdesc->rate_mode, signal, type);
 	return 0;
 }
 
@@ -720,8 +719,8 @@ void rt2x00lib_rxdone(struct queue_entry *entry, gfp_t gfp)
 	 */
 	if (unlikely(rxdesc.size == 0 ||
 		     rxdesc.size > entry->queue->data_size)) {
-		ERROR(rt2x00dev, "Wrong frame size %d max %d.\n",
-			rxdesc.size, entry->queue->data_size);
+		rt2x00_err(rt2x00dev, "Wrong frame size %d max %d\n",
+			   rxdesc.size, entry->queue->data_size);
 		dev_kfree_skb(entry->skb);
 		goto renew_skb;
 	}
@@ -1006,7 +1005,7 @@ static int rt2x00lib_probe_hw_modes(struct rt2x00_dev *rt2x00dev,
 
  exit_free_channels:
 	kfree(channels);
-	ERROR(rt2x00dev, "Allocation ieee80211 modes failed.\n");
+	rt2x00_err(rt2x00dev, "Allocation ieee80211 modes failed\n");
 	return -ENOMEM;
 }
 
@@ -1337,7 +1336,7 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	 */
 	retval = rt2x00dev->ops->lib->probe_hw(rt2x00dev);
 	if (retval) {
-		ERROR(rt2x00dev, "Failed to allocate device.\n");
+		rt2x00_err(rt2x00dev, "Failed to allocate device\n");
 		goto exit;
 	}
 
@@ -1353,7 +1352,7 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	 */
 	retval = rt2x00lib_probe_hw(rt2x00dev);
 	if (retval) {
-		ERROR(rt2x00dev, "Failed to initialize hw.\n");
+		rt2x00_err(rt2x00dev, "Failed to initialize hw\n");
 		goto exit;
 	}
 
@@ -1451,7 +1450,7 @@ EXPORT_SYMBOL_GPL(rt2x00lib_remove_dev);
 #ifdef CONFIG_PM
 int rt2x00lib_suspend(struct rt2x00_dev *rt2x00dev, pm_message_t state)
 {
-	DEBUG(rt2x00dev, "Going to sleep.\n");
+	rt2x00_dbg(rt2x00dev, "Going to sleep\n");
 
 	/*
 	 * Prevent mac80211 from accessing driver while suspended.
@@ -1482,8 +1481,7 @@ int rt2x00lib_suspend(struct rt2x00_dev *rt2x00dev, pm_message_t state)
 	 * device is as good as disabled.
 	 */
 	if (rt2x00dev->ops->lib->set_device_state(rt2x00dev, STATE_SLEEP))
-		WARNING(rt2x00dev, "Device failed to enter sleep state, "
-			"continue suspending.\n");
+		rt2x00_warn(rt2x00dev, "Device failed to enter sleep state, continue suspending\n");
 
 	return 0;
 }
@@ -1491,7 +1489,7 @@ EXPORT_SYMBOL_GPL(rt2x00lib_suspend);
 
 int rt2x00lib_resume(struct rt2x00_dev *rt2x00dev)
 {
-	DEBUG(rt2x00dev, "Waking up.\n");
+	rt2x00_dbg(rt2x00dev, "Waking up\n");
 
 	/*
 	 * Restore/enable extra components.
diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/rt2x00/rt2x00firmware.c
index f316aad..1b4254b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
+++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
@@ -42,28 +42,28 @@ static int rt2x00lib_request_firmware(struct rt2x00_dev *rt2x00dev)
 	 */
 	fw_name = rt2x00dev->ops->lib->get_firmware_name(rt2x00dev);
 	if (!fw_name) {
-		ERROR(rt2x00dev,
-		      "Invalid firmware filename.\n"
-		      "Please file bug report to %s.\n", DRV_PROJECT);
+		rt2x00_err(rt2x00dev,
+			   "Invalid firmware filename\n"
+			   "Please file bug report to %s\n", DRV_PROJECT);
 		return -EINVAL;
 	}
 
-	INFO(rt2x00dev, "Loading firmware file '%s'.\n", fw_name);
+	rt2x00_info(rt2x00dev, "Loading firmware file '%s'\n", fw_name);
 
 	retval = request_firmware(&fw, fw_name, device);
 	if (retval) {
-		ERROR(rt2x00dev, "Failed to request Firmware.\n");
+		rt2x00_err(rt2x00dev, "Failed to request Firmware\n");
 		return retval;
 	}
 
 	if (!fw || !fw->size || !fw->data) {
-		ERROR(rt2x00dev, "Failed to read Firmware.\n");
+		rt2x00_err(rt2x00dev, "Failed to read Firmware\n");
 		release_firmware(fw);
 		return -ENOENT;
 	}
 
-	INFO(rt2x00dev, "Firmware detected - version: %d.%d.\n",
-	     fw->data[fw->size - 4], fw->data[fw->size - 3]);
+	rt2x00_info(rt2x00dev, "Firmware detected - version: %d.%d\n",
+		    fw->data[fw->size - 4], fw->data[fw->size - 3]);
 	snprintf(rt2x00dev->hw->wiphy->fw_version,
 			sizeof(rt2x00dev->hw->wiphy->fw_version), "%d.%d",
 			fw->data[fw->size - 4], fw->data[fw->size - 3]);
@@ -73,15 +73,14 @@ static int rt2x00lib_request_firmware(struct rt2x00_dev *rt2x00dev)
 	case FW_OK:
 		break;
 	case FW_BAD_CRC:
-		ERROR(rt2x00dev, "Firmware checksum error.\n");
+		rt2x00_err(rt2x00dev, "Firmware checksum error\n");
 		goto exit;
 	case FW_BAD_LENGTH:
-		ERROR(rt2x00dev,
-		      "Invalid firmware file length (len=%zu)\n", fw->size);
+		rt2x00_err(rt2x00dev, "Invalid firmware file length (len=%zu)\n",
+			   fw->size);
 		goto exit;
 	case FW_BAD_VERSION:
-		ERROR(rt2x00dev,
-		      "Current firmware does not support detected chipset.\n");
+		rt2x00_err(rt2x00dev, "Current firmware does not support detected chipset\n");
 		goto exit;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00leds.c b/drivers/net/wireless/rt2x00/rt2x00leds.c
index 8679d78..997a6c8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00leds.c
+++ b/drivers/net/wireless/rt2x00/rt2x00leds.c
@@ -113,7 +113,7 @@ static int rt2x00leds_register_led(struct rt2x00_dev *rt2x00dev,
 
 	retval = led_classdev_register(device, &led->led_dev);
 	if (retval) {
-		ERROR(rt2x00dev, "Failed to register led handler.\n");
+		rt2x00_err(rt2x00dev, "Failed to register led handler\n");
 		return retval;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 9161c02..f883802 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -46,7 +46,7 @@ static int rt2x00mac_tx_rts_cts(struct rt2x00_dev *rt2x00dev,
 
 	skb = dev_alloc_skb(data_length + rt2x00dev->hw->extra_tx_headroom);
 	if (unlikely(!skb)) {
-		WARNING(rt2x00dev, "Failed to create RTS/CTS frame.\n");
+		rt2x00_warn(rt2x00dev, "Failed to create RTS/CTS frame\n");
 		return -ENOMEM;
 	}
 
@@ -93,7 +93,7 @@ static int rt2x00mac_tx_rts_cts(struct rt2x00_dev *rt2x00dev,
 	retval = rt2x00queue_write_tx_frame(queue, skb, true);
 	if (retval) {
 		dev_kfree_skb_any(skb);
-		WARNING(rt2x00dev, "Failed to send RTS/CTS frame.\n");
+		rt2x00_warn(rt2x00dev, "Failed to send RTS/CTS frame\n");
 	}
 
 	return retval;
@@ -126,9 +126,9 @@ void rt2x00mac_tx(struct ieee80211_hw *hw,
 
 	queue = rt2x00queue_get_tx_queue(rt2x00dev, qid);
 	if (unlikely(!queue)) {
-		ERROR(rt2x00dev,
-		      "Attempt to send packet over invalid queue %d.\n"
-		      "Please file bug report to %s.\n", qid, DRV_PROJECT);
+		rt2x00_err(rt2x00dev,
+			   "Attempt to send packet over invalid queue %d\n"
+			   "Please file bug report to %s\n", qid, DRV_PROJECT);
 		goto exit_free_skb;
 	}
 
@@ -731,9 +731,10 @@ int rt2x00mac_conf_tx(struct ieee80211_hw *hw,
 	queue->aifs = params->aifs;
 	queue->txop = params->txop;
 
-	DEBUG(rt2x00dev,
-	      "Configured TX queue %d - CWmin: %d, CWmax: %d, Aifs: %d, TXop: %d.\n",
-	      queue_idx, queue->cw_min, queue->cw_max, queue->aifs, queue->txop);
+	rt2x00_dbg(rt2x00dev,
+		   "Configured TX queue %d - CWmin: %d, CWmax: %d, Aifs: %d, TXop: %d\n",
+		   queue_idx, queue->cw_min, queue->cw_max, queue->aifs,
+		   queue->txop);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wireless/rt2x00/rt2x00mmio.c
index 06c7669..64b06c6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mmio.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mmio.c
@@ -175,8 +175,8 @@ int rt2x00mmio_initialize(struct rt2x00_dev *rt2x00dev)
 			     rt2x00dev->ops->lib->irq_handler,
 			     IRQF_SHARED, rt2x00dev->name, rt2x00dev);
 	if (status) {
-		ERROR(rt2x00dev, "IRQ %d allocation failed (error %d).\n",
-		      rt2x00dev->irq, status);
+		rt2x00_err(rt2x00dev, "IRQ %d allocation failed (error %d)\n",
+			   rt2x00dev->irq, status);
 		goto exit;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index e87865e..dc49e52 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -68,7 +68,7 @@ static int rt2x00pci_alloc_reg(struct rt2x00_dev *rt2x00dev)
 	return 0;
 
 exit:
-	ERROR_PROBE("Failed to allocate registers.\n");
+	rt2x00_probe_err("Failed to allocate registers\n");
 
 	rt2x00pci_free_reg(rt2x00dev);
 
@@ -84,30 +84,30 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct rt2x00_ops *ops)
 
 	retval = pci_enable_device(pci_dev);
 	if (retval) {
-		ERROR_PROBE("Enable device failed.\n");
+		rt2x00_probe_err("Enable device failed\n");
 		return retval;
 	}
 
 	retval = pci_request_regions(pci_dev, pci_name(pci_dev));
 	if (retval) {
-		ERROR_PROBE("PCI request regions failed.\n");
+		rt2x00_probe_err("PCI request regions failed\n");
 		goto exit_disable_device;
 	}
 
 	pci_set_master(pci_dev);
 
 	if (pci_set_mwi(pci_dev))
-		ERROR_PROBE("MWI not available.\n");
+		rt2x00_probe_err("MWI not available\n");
 
 	if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32))) {
-		ERROR_PROBE("PCI DMA not supported.\n");
+		rt2x00_probe_err("PCI DMA not supported\n");
 		retval = -EIO;
 		goto exit_release_regions;
 	}
 
 	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
-		ERROR_PROBE("Failed to allocate hardware.\n");
+		rt2x00_probe_err("Failed to allocate hardware\n");
 		retval = -ENOMEM;
 		goto exit_release_regions;
 	}
@@ -207,7 +207,7 @@ int rt2x00pci_resume(struct pci_dev *pci_dev)
 
 	if (pci_set_power_state(pci_dev, PCI_D0) ||
 	    pci_enable_device(pci_dev)) {
-		ERROR(rt2x00dev, "Failed to resume device.\n");
+		rt2x00_err(rt2x00dev, "Failed to resume device\n");
 		return -EIO;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 952a049..2213b1d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -531,10 +531,10 @@ static int rt2x00queue_write_tx_data(struct queue_entry *entry,
 	 */
 	if (unlikely(rt2x00dev->ops->lib->get_entry_state &&
 		     rt2x00dev->ops->lib->get_entry_state(entry))) {
-		ERROR(rt2x00dev,
-		      "Corrupt queue %d, accessing entry which is not ours.\n"
-		      "Please file bug report to %s.\n",
-		      entry->queue->qid, DRV_PROJECT);
+		rt2x00_err(rt2x00dev,
+			   "Corrupt queue %d, accessing entry which is not ours\n"
+			   "Please file bug report to %s\n",
+			   entry->queue->qid, DRV_PROJECT);
 		return -EINVAL;
 	}
 
@@ -698,8 +698,8 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb,
 	spin_lock(&queue->tx_lock);
 
 	if (unlikely(rt2x00queue_full(queue))) {
-		ERROR(queue->rt2x00dev,
-		      "Dropping frame due to full tx queue %d.\n", queue->qid);
+		rt2x00_err(queue->rt2x00dev, "Dropping frame due to full tx queue %d\n",
+			   queue->qid);
 		ret = -ENOBUFS;
 		goto out;
 	}
@@ -708,10 +708,10 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb,
 
 	if (unlikely(test_and_set_bit(ENTRY_OWNER_DEVICE_DATA,
 				      &entry->flags))) {
-		ERROR(queue->rt2x00dev,
-		      "Arrived at non-free entry in the non-full queue %d.\n"
-		      "Please file bug report to %s.\n",
-		      queue->qid, DRV_PROJECT);
+		rt2x00_err(queue->rt2x00dev,
+			   "Arrived at non-free entry in the non-full queue %d\n"
+			   "Please file bug report to %s\n",
+			   queue->qid, DRV_PROJECT);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -842,9 +842,9 @@ bool rt2x00queue_for_each_entry(struct data_queue *queue,
 	unsigned int i;
 
 	if (unlikely(start >= Q_INDEX_MAX || end >= Q_INDEX_MAX)) {
-		ERROR(queue->rt2x00dev,
-		      "Entry requested from invalid index range (%d - %d)\n",
-		      start, end);
+		rt2x00_err(queue->rt2x00dev,
+			   "Entry requested from invalid index range (%d - %d)\n",
+			   start, end);
 		return true;
 	}
 
@@ -891,8 +891,8 @@ struct queue_entry *rt2x00queue_get_entry(struct data_queue *queue,
 	unsigned long irqflags;
 
 	if (unlikely(index >= Q_INDEX_MAX)) {
-		ERROR(queue->rt2x00dev,
-		      "Entry requested from invalid index type (%d)\n", index);
+		rt2x00_err(queue->rt2x00dev, "Entry requested from invalid index type (%d)\n",
+			   index);
 		return NULL;
 	}
 
@@ -912,8 +912,8 @@ void rt2x00queue_index_inc(struct queue_entry *entry, enum queue_index index)
 	unsigned long irqflags;
 
 	if (unlikely(index >= Q_INDEX_MAX)) {
-		ERROR(queue->rt2x00dev,
-		      "Index change on invalid index type (%d)\n", index);
+		rt2x00_err(queue->rt2x00dev,
+			   "Index change on invalid index type (%d)\n", index);
 		return;
 	}
 
@@ -1073,7 +1073,8 @@ void rt2x00queue_flush_queue(struct data_queue *queue, bool drop)
 	 * The queue flush has failed...
 	 */
 	if (unlikely(!rt2x00queue_empty(queue)))
-		WARNING(queue->rt2x00dev, "Queue %d failed to flush\n", queue->qid);
+		rt2x00_warn(queue->rt2x00dev, "Queue %d failed to flush\n",
+			    queue->qid);
 
 	/*
 	 * Restore the queue to the previous status
@@ -1262,7 +1263,7 @@ int rt2x00queue_initialize(struct rt2x00_dev *rt2x00dev)
 	return 0;
 
 exit:
-	ERROR(rt2x00dev, "Queue entries allocation failed.\n");
+	rt2x00_err(rt2x00dev, "Queue entries allocation failed\n");
 
 	rt2x00queue_uninitialize(rt2x00dev);
 
@@ -1314,7 +1315,7 @@ int rt2x00queue_allocate(struct rt2x00_dev *rt2x00dev)
 
 	queue = kcalloc(rt2x00dev->data_queues, sizeof(*queue), GFP_KERNEL);
 	if (!queue) {
-		ERROR(rt2x00dev, "Queue allocation failed.\n");
+		rt2x00_err(rt2x00dev, "Queue allocation failed\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00soc.c b/drivers/net/wireless/rt2x00/rt2x00soc.c
index 2aa5c38..9271a5f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00soc.c
+++ b/drivers/net/wireless/rt2x00/rt2x00soc.c
@@ -68,7 +68,7 @@ static int rt2x00soc_alloc_reg(struct rt2x00_dev *rt2x00dev)
 	return 0;
 
 exit:
-	ERROR_PROBE("Failed to allocate registers.\n");
+	rt2x00_probe_err("Failed to allocate registers\n");
 	rt2x00soc_free_reg(rt2x00dev);
 
 	return -ENOMEM;
@@ -82,7 +82,7 @@ int rt2x00soc_probe(struct platform_device *pdev, const struct rt2x00_ops *ops)
 
 	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
-		ERROR_PROBE("Failed to allocate hardware.\n");
+		rt2x00_probe_err("Failed to allocate hardware\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 5e50d4f..8828987 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -70,9 +70,9 @@ int rt2x00usb_vendor_request(struct rt2x00_dev *rt2x00dev,
 		}
 	}
 
-	ERROR(rt2x00dev,
-	      "Vendor Request 0x%02x failed for offset 0x%04x with error %d.\n",
-	      request, offset, status);
+	rt2x00_err(rt2x00dev,
+		   "Vendor Request 0x%02x failed for offset 0x%04x with error %d\n",
+		   request, offset, status);
 
 	return status;
 }
@@ -91,7 +91,7 @@ int rt2x00usb_vendor_req_buff_lock(struct rt2x00_dev *rt2x00dev,
 	 * Check for Cache availability.
 	 */
 	if (unlikely(!rt2x00dev->csr.cache || buffer_length > CSR_CACHE_SIZE)) {
-		ERROR(rt2x00dev, "CSR cache not available.\n");
+		rt2x00_err(rt2x00dev, "CSR cache not available\n");
 		return -ENOMEM;
 	}
 
@@ -157,8 +157,8 @@ int rt2x00usb_regbusy_read(struct rt2x00_dev *rt2x00dev,
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=0x%.08x, value=0x%.08x\n", offset, *reg);
+	rt2x00_err(rt2x00dev, "Indirect register access failed: offset=0x%.08x, value=0x%.08x\n",
+		   offset, *reg);
 	*reg = ~0;
 
 	return 0;
@@ -307,7 +307,7 @@ static bool rt2x00usb_kick_tx_entry(struct queue_entry *entry, void *data)
 	status = skb_padto(entry->skb, length);
 	if (unlikely(status)) {
 		/* TODO: report something more appropriate than IO_FAILED. */
-		WARNING(rt2x00dev, "TX SKB padding error, out of memory\n");
+		rt2x00_warn(rt2x00dev, "TX SKB padding error, out of memory\n");
 		set_bit(ENTRY_DATA_IO_FAILED, &entry->flags);
 		rt2x00lib_dmadone(entry);
 
@@ -520,8 +520,8 @@ EXPORT_SYMBOL_GPL(rt2x00usb_flush_queue);
 
 static void rt2x00usb_watchdog_tx_dma(struct data_queue *queue)
 {
-	WARNING(queue->rt2x00dev, "TX queue %d DMA timed out,"
-		" invoke forced forced reset\n", queue->qid);
+	rt2x00_warn(queue->rt2x00dev, "TX queue %d DMA timed out, invoke forced forced reset\n",
+		    queue->qid);
 
 	rt2x00queue_flush_queue(queue, true);
 }
@@ -622,7 +622,7 @@ static int rt2x00usb_find_endpoints(struct rt2x00_dev *rt2x00dev)
 	 * At least 1 endpoint for RX and 1 endpoint for TX must be available.
 	 */
 	if (!rt2x00dev->rx->usb_endpoint || !rt2x00dev->tx->usb_endpoint) {
-		ERROR(rt2x00dev, "Bulk-in/Bulk-out endpoints not found\n");
+		rt2x00_err(rt2x00dev, "Bulk-in/Bulk-out endpoints not found\n");
 		return -EPIPE;
 	}
 
@@ -775,7 +775,7 @@ static int rt2x00usb_alloc_reg(struct rt2x00_dev *rt2x00dev)
 	return 0;
 
 exit:
-	ERROR_PROBE("Failed to allocate registers.\n");
+	rt2x00_probe_err("Failed to allocate registers\n");
 
 	rt2x00usb_free_reg(rt2x00dev);
 
@@ -795,7 +795,7 @@ int rt2x00usb_probe(struct usb_interface *usb_intf,
 
 	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), ops->hw);
 	if (!hw) {
-		ERROR_PROBE("Failed to allocate hardware.\n");
+		rt2x00_probe_err("Failed to allocate hardware\n");
 		retval = -ENOMEM;
 		goto exit_put_device;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index fc99258..0dc8180 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1309,7 +1309,7 @@ static int rt61pci_load_firmware(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (!reg) {
-		ERROR(rt2x00dev, "Unstable hardware.\n");
+		rt2x00_err(rt2x00dev, "Unstable hardware\n");
 		return -EBUSY;
 	}
 
@@ -1348,7 +1348,7 @@ static int rt61pci_load_firmware(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (i == 100) {
-		ERROR(rt2x00dev, "MCU Control register not ready.\n");
+		rt2x00_err(rt2x00dev, "MCU Control register not ready\n");
 		return -EBUSY;
 	}
 
@@ -1658,7 +1658,7 @@ static int rt61pci_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -1859,8 +1859,8 @@ static int rt61pci_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -1999,7 +1999,7 @@ static void rt61pci_write_beacon(struct queue_entry *entry,
 	 */
 	padding_len = roundup(entry->skb->len, 4) - entry->skb->len;
 	if (padding_len && skb_pad(entry->skb, padding_len)) {
-		ERROR(rt2x00dev, "Failure padding beacon, aborting\n");
+		rt2x00_err(rt2x00dev, "Failure padding beacon, aborting\n");
 		/* skb freed by skb_pad() on failure */
 		entry->skb = NULL;
 		rt2x00mmio_register_write(rt2x00dev, TXRX_CSR9, orig_reg);
@@ -2210,9 +2210,8 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 			/* Catch up.
 			 * Just report any entries we missed as failed.
 			 */
-			WARNING(rt2x00dev,
-				"TX status report missed for entry %d\n",
-				entry_done->entry_idx);
+			rt2x00_warn(rt2x00dev, "TX status report missed for entry %d\n",
+				    entry_done->entry_idx);
 
 			rt2x00lib_txdone_noinfo(entry_done, TXDONE_UNKNOWN);
 			entry_done = rt2x00queue_get_entry(queue, Q_INDEX_DONE);
@@ -2419,7 +2418,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
@@ -2434,7 +2433,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_HARDWARE_RADIO, 0);
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_RF_TYPE, RF5225);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_ANTENNA, word);
-		EEPROM(rt2x00dev, "Antenna: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Antenna: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &word);
@@ -2447,7 +2446,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_NIC_CARDBUS_ACCEL, 0);
 		rt2x00_set_field16(&word, EEPROM_NIC_EXTERNAL_LNA_A, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC, word);
-		EEPROM(rt2x00dev, "NIC: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "NIC: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_LED, &word);
@@ -2455,7 +2454,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_LED_LED_MODE,
 				   LED_MODE_DEFAULT);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_LED, word);
-		EEPROM(rt2x00dev, "Led: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Led: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_FREQ, &word);
@@ -2463,7 +2462,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_FREQ_OFFSET, 0);
 		rt2x00_set_field16(&word, EEPROM_FREQ_SEQ, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_FREQ, word);
-		EEPROM(rt2x00dev, "Freq: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Freq: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_RSSI_OFFSET_BG, &word);
@@ -2471,7 +2470,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_BG_1, 0);
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_BG_2, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_RSSI_OFFSET_BG, word);
-		EEPROM(rt2x00dev, "RSSI OFFSET BG: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "RSSI OFFSET BG: 0x%04x\n", word);
 	} else {
 		value = rt2x00_get_field16(word, EEPROM_RSSI_OFFSET_BG_1);
 		if (value < -10 || value > 10)
@@ -2487,7 +2486,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_A_1, 0);
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_A_2, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_RSSI_OFFSET_A, word);
-		EEPROM(rt2x00dev, "RSSI OFFSET A: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "RSSI OFFSET A: 0x%04x\n", word);
 	} else {
 		value = rt2x00_get_field16(word, EEPROM_RSSI_OFFSET_A_1);
 		if (value < -10 || value > 10)
@@ -2524,7 +2523,7 @@ static int rt61pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	    !rt2x00_rf(rt2x00dev, RF5325) &&
 	    !rt2x00_rf(rt2x00dev, RF2527) &&
 	    !rt2x00_rf(rt2x00dev, RF2529)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RF chipset detected\n");
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index a3387b1..377e09b 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1122,7 +1122,7 @@ static int rt73usb_load_firmware(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (!reg) {
-		ERROR(rt2x00dev, "Unstable hardware.\n");
+		rt2x00_err(rt2x00dev, "Unstable hardware\n");
 		return -EBUSY;
 	}
 
@@ -1139,7 +1139,7 @@ static int rt73usb_load_firmware(struct rt2x00_dev *rt2x00dev,
 					     0, USB_MODE_FIRMWARE,
 					     REGISTER_TIMEOUT_FIRMWARE);
 	if (status < 0) {
-		ERROR(rt2x00dev, "Failed to write Firmware to device.\n");
+		rt2x00_err(rt2x00dev, "Failed to write Firmware to device\n");
 		return status;
 	}
 
@@ -1305,7 +1305,7 @@ static int rt73usb_wait_bbp_ready(struct rt2x00_dev *rt2x00dev)
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "BBP register access failed, aborting.\n");
+	rt2x00_err(rt2x00dev, "BBP register access failed, aborting\n");
 	return -EACCES;
 }
 
@@ -1443,8 +1443,8 @@ static int rt73usb_set_device_state(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (unlikely(retval))
-		ERROR(rt2x00dev, "Device failed to enter state %d (%d).\n",
-		      state, retval);
+		rt2x00_err(rt2x00dev, "Device failed to enter state %d (%d)\n",
+			   state, retval);
 
 	return retval;
 }
@@ -1567,7 +1567,7 @@ static void rt73usb_write_beacon(struct queue_entry *entry,
 	 */
 	padding_len = roundup(entry->skb->len, 4) - entry->skb->len;
 	if (padding_len && skb_pad(entry->skb, padding_len)) {
-		ERROR(rt2x00dev, "Failure padding beacon, aborting\n");
+		rt2x00_err(rt2x00dev, "Failure padding beacon, aborting\n");
 		/* skb freed by skb_pad() on failure */
 		entry->skb = NULL;
 		rt2x00usb_register_write(rt2x00dev, TXRX_CSR9, orig_reg);
@@ -1771,7 +1771,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
 		eth_random_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
+		rt2x00_eeprom_dbg(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
@@ -1786,14 +1786,14 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_HARDWARE_RADIO, 0);
 		rt2x00_set_field16(&word, EEPROM_ANTENNA_RF_TYPE, RF5226);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_ANTENNA, word);
-		EEPROM(rt2x00dev, "Antenna: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Antenna: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_NIC, &word);
 	if (word == 0xffff) {
 		rt2x00_set_field16(&word, EEPROM_NIC_EXTERNAL_LNA, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_NIC, word);
-		EEPROM(rt2x00dev, "NIC: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "NIC: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_LED, &word);
@@ -1809,7 +1809,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_LED_LED_MODE,
 				   LED_MODE_DEFAULT);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_LED, word);
-		EEPROM(rt2x00dev, "Led: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Led: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_FREQ, &word);
@@ -1817,7 +1817,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_FREQ_OFFSET, 0);
 		rt2x00_set_field16(&word, EEPROM_FREQ_SEQ, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_FREQ, word);
-		EEPROM(rt2x00dev, "Freq: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "Freq: 0x%04x\n", word);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_RSSI_OFFSET_BG, &word);
@@ -1825,7 +1825,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_BG_1, 0);
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_BG_2, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_RSSI_OFFSET_BG, word);
-		EEPROM(rt2x00dev, "RSSI OFFSET BG: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "RSSI OFFSET BG: 0x%04x\n", word);
 	} else {
 		value = rt2x00_get_field16(word, EEPROM_RSSI_OFFSET_BG_1);
 		if (value < -10 || value > 10)
@@ -1841,7 +1841,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_A_1, 0);
 		rt2x00_set_field16(&word, EEPROM_RSSI_OFFSET_A_2, 0);
 		rt2x00_eeprom_write(rt2x00dev, EEPROM_RSSI_OFFSET_A, word);
-		EEPROM(rt2x00dev, "RSSI OFFSET A: 0x%04x\n", word);
+		rt2x00_eeprom_dbg(rt2x00dev, "RSSI OFFSET A: 0x%04x\n", word);
 	} else {
 		value = rt2x00_get_field16(word, EEPROM_RSSI_OFFSET_A_1);
 		if (value < -10 || value > 10)
@@ -1875,7 +1875,7 @@ static int rt73usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 			value, rt2x00_get_field32(reg, MAC_CSR0_REVISION));
 
 	if (!rt2x00_rt(rt2x00dev, RT2573) || (rt2x00_rev(rt2x00dev) == 0)) {
-		ERROR(rt2x00dev, "Invalid RT chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RT chipset detected\n");
 		return -ENODEV;
 	}
 
@@ -1883,7 +1883,7 @@ static int rt73usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	    !rt2x00_rf(rt2x00dev, RF2528) &&
 	    !rt2x00_rf(rt2x00dev, RF5225) &&
 	    !rt2x00_rf(rt2x00dev, RF2527)) {
-		ERROR(rt2x00dev, "Invalid RF chipset detected.\n");
+		rt2x00_err(rt2x00dev, "Invalid RF chipset detected\n");
 		return -ENODEV;
 	}
 
-- 
1.8.1.2.459.gbcd45b4.dirty
