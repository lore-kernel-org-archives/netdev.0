From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 17/20] rtl818x: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:57 -0700
Message-ID: <dfdff7075965cbae7e4ca96f4f479e1c2a822a72.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46529 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932308Ab2FOF6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 01:58:23 -0400
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtl818x/rtl8180/dev.c    |   35 ++++++++++---------------
 drivers/net/wireless/rtl818x/rtl8187/dev.c    |   15 +++++-----
 drivers/net/wireless/rtl818x/rtl8187/leds.c   |    6 +++-
 drivers/net/wireless/rtl818x/rtl8187/rfkill.c |    9 +++---
 4 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 2bebcb7..b0818a9 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -15,6 +15,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
@@ -913,15 +915,13 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s (rtl8180): Cannot enable new PCI device\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot enable new PCI device\n", pci_name(pdev));
 		return err;
 	}
 
 	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if (err) {
-		printk(KERN_ERR "%s (rtl8180): Cannot obtain PCI resources\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot obtain PCI resources\n", pci_name(pdev));
 		return err;
 	}
 
@@ -932,16 +932,14 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 
 	if (mem_len < sizeof(struct rtl818x_csr) ||
 	    io_len < sizeof(struct rtl818x_csr)) {
-		printk(KERN_ERR "%s (rtl8180): Too short PCI resources\n",
-		       pci_name(pdev));
+		pr_err("%s: Too short PCI resources\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto err_free_reg;
 	}
 
 	if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
 	    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-		printk(KERN_ERR "%s (rtl8180): No suitable DMA available\n",
-		       pci_name(pdev));
+		pr_err("%s: No suitable DMA available\n", pci_name(pdev));
 		goto err_free_reg;
 	}
 
@@ -949,8 +947,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 
 	dev = ieee80211_alloc_hw(sizeof(*priv), &rtl8180_ops);
 	if (!dev) {
-		printk(KERN_ERR "%s (rtl8180): ieee80211 alloc failed\n",
-		       pci_name(pdev));
+		pr_err("%s: ieee80211 alloc failed\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto err_free_reg;
 	}
@@ -967,8 +964,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 		priv->map = pci_iomap(pdev, 0, io_len);
 
 	if (!priv->map) {
-		printk(KERN_ERR "%s (rtl8180): Cannot map device memory\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot map device memory\n", pci_name(pdev));
 		goto err_free_dev;
 	}
 
@@ -1010,8 +1006,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 		chip_name = "RTL8185vD";
 		break;
 	default:
-		printk(KERN_ERR "%s (rtl8180): Unknown chip! (0x%x)\n",
-		       pci_name(pdev), reg >> 25);
+		pr_err("%s: Unknown chip! (0x%x)\n", pci_name(pdev), reg >> 25);
 		goto err_iounmap;
 	}
 
@@ -1052,13 +1047,12 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 		rf_name = "RTL8255";
 		break;
 	default:
-		printk(KERN_ERR "%s (rtl8180): Unknown RF! (0x%x)\n",
-		       pci_name(pdev), eeprom_val);
+		pr_err("%s: Unknown RF! (0x%x)\n", pci_name(pdev), eeprom_val);
 		goto err_iounmap;
 	}
 
 	if (!priv->rf) {
-		printk(KERN_ERR "%s (rtl8180): %s RF frontend not supported!\n",
+		pr_err("%s: %s RF frontend not supported!\n",
 		       pci_name(pdev), rf_name);
 		goto err_iounmap;
 	}
@@ -1074,8 +1068,8 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 
 	eeprom_93cx6_multiread(&eeprom, 0x7, (__le16 *)mac_addr, 3);
 	if (!is_valid_ether_addr(mac_addr)) {
-		printk(KERN_WARNING "%s (rtl8180): Invalid hwaddr! Using"
-		       " randomly generated MAC addr\n", pci_name(pdev));
+		pr_warn("%s: Invalid hwaddr! Using randomly generated MAC addr\n",
+			pci_name(pdev));
 		random_ether_addr(mac_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, mac_addr);
@@ -1104,8 +1098,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 
 	err = ieee80211_register_hw(dev);
 	if (err) {
-		printk(KERN_ERR "%s (rtl8180): Cannot register device\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot register device\n", pci_name(pdev));
 		goto err_iounmap;
 	}
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 4fb1ca1..ae631b4 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -20,6 +20,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/usb.h>
 #include <linux/slab.h>
@@ -1425,7 +1427,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 
 	dev = ieee80211_alloc_hw(sizeof(*priv), &rtl8187_ops);
 	if (!dev) {
-		printk(KERN_ERR "rtl8187: ieee80211 alloc failed\n");
+		pr_err("ieee80211 alloc failed\n");
 		return -ENOMEM;
 	}
 
@@ -1484,8 +1486,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	eeprom_93cx6_multiread(&eeprom, RTL8187_EEPROM_MAC_ADDR,
 			       (__le16 __force *)mac_addr, 3);
 	if (!is_valid_ether_addr(mac_addr)) {
-		printk(KERN_WARNING "rtl8187: Invalid hwaddr! Using randomly "
-		       "generated MAC address\n");
+		pr_warn("Invalid hwaddr! Using randomly generated MAC address\n");
 		random_ether_addr(mac_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, mac_addr);
@@ -1540,8 +1541,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 		 * only uses it in their sources
 		 */
 		/*if (priv->asic_rev == 0) {
-			printk(KERN_WARNING "rtl8187: Forcing use of USB "
-			       "requests to write to radio registers\n");
+			pr_warn("Forcing use of USB requests to write to radio registers\n");
 			priv->asic_rev = 1;
 		}*/
 		switch (rtl818x_ioread8(priv, (u8 *)0xFFE1)) {
@@ -1595,8 +1595,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 				      BIT(NL80211_IFTYPE_ADHOC) ;
 
 	if ((id->driver_info == DEVICE_RTL8187) && priv->is_rtl8187b)
-		printk(KERN_INFO "rtl8187: inconsistency between id with OEM"
-		       " info!\n");
+		pr_info("inconsistency between id with OEM info!\n");
 
 	priv->rf = rtl8187_detect_rf(dev);
 	dev->extra_tx_headroom = (!priv->is_rtl8187b) ?
@@ -1609,7 +1608,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 
 	err = ieee80211_register_hw(dev);
 	if (err) {
-		printk(KERN_ERR "rtl8187: Cannot register device\n");
+		pr_err("Cannot register device\n");
 		goto err_free_dmabuf;
 	}
 	mutex_init(&priv->conf_mutex);
diff --git a/drivers/net/wireless/rtl818x/rtl8187/leds.c b/drivers/net/wireless/rtl818x/rtl8187/leds.c
index c2d5b49..ad6bde4 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/leds.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/leds.c
@@ -15,6 +15,8 @@
 
 #ifdef CONFIG_RTL8187_LEDS
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/mac80211.h>
 #include <linux/usb.h>
 #include <linux/eeprom_93cx6.h>
@@ -154,7 +156,7 @@ static int rtl8187_register_led(struct ieee80211_hw *dev,
 
 	err = led_classdev_register(&priv->udev->dev, &led->led_dev);
 	if (err) {
-		printk(KERN_INFO "LEDs: Failed to register %s\n", name);
+		pr_info("Failed to register %s\n", name);
 		led->dev = NULL;
 		return err;
 	}
@@ -181,7 +183,7 @@ void rtl8187_leds_init(struct ieee80211_hw *dev, u16 custid)
 	/* According to the vendor driver, the LED operation depends on the
 	 * customer ID encoded in the EEPROM
 	 */
-	printk(KERN_INFO "rtl8187: Customer ID is 0x%02X\n", custid);
+	pr_info("Customer ID is 0x%02X\n", custid);
 	switch (custid) {
 	case EEPROM_CID_RSVD0:
 	case EEPROM_CID_RSVD1:
diff --git a/drivers/net/wireless/rtl818x/rtl8187/rfkill.c b/drivers/net/wireless/rtl818x/rtl8187/rfkill.c
index 3411671..cc9223f 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/rfkill.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/rfkill.c
@@ -13,6 +13,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/usb.h>
 #include <net/mac80211.h>
@@ -36,8 +38,7 @@ void rtl8187_rfkill_init(struct ieee80211_hw *hw)
 	struct rtl8187_priv *priv = hw->priv;
 
 	priv->rfkill_off = rtl8187_is_radio_enabled(priv);
-	printk(KERN_INFO "rtl8187: wireless switch is %s\n",
-	       priv->rfkill_off ? "on" : "off");
+	pr_info("wireless switch is %s\n", priv->rfkill_off ? "on" : "off");
 	wiphy_rfkill_set_hw_state(hw->wiphy, !priv->rfkill_off);
 	wiphy_rfkill_start_polling(hw->wiphy);
 }
@@ -51,8 +52,8 @@ void rtl8187_rfkill_poll(struct ieee80211_hw *hw)
 	enabled = rtl8187_is_radio_enabled(priv);
 	if (unlikely(enabled != priv->rfkill_off)) {
 		priv->rfkill_off = enabled;
-		printk(KERN_INFO "rtl8187: wireless radio switch turned %s\n",
-		       enabled ? "on" : "off");
+		pr_info("wireless radio switch turned %s\n",
+			enabled ? "on" : "off");
 		wiphy_rfkill_set_hw_state(hw->wiphy, !enabled);
 	}
 	mutex_unlock(&priv->conf_mutex);
-- 
1.7.8.111.gad25c.dirty
