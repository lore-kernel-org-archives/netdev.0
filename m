From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 01/26] rt2x00: ethtool
Date: Sun, 3 Dec 2006 19:19:05 +0100
Message-ID: <200612031919.06078.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:55900 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758883AbWLCSTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:39 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144432nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:37 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Latest d80211 stack no longer provides any ethtool support.
At the moment there is no quick replacement possible for
the ethtool features (debugfs is under investigation, but
requires more work).

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-02 14:52:12.000000000 +0100
@@ -35,7 +35,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -343,81 +342,6 @@
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt2400pci_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, "N/A");
-	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt2400pci_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt2400pci_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT2400PCI_DEBUG
-static u32 rt2400pci_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt2400pci_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT2400PCI_DEBUG */
-
-static int rt2400pci_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt2400pci_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt2400pci_ethtool_ops = {
-	.get_drvinfo	= rt2400pci_get_drvinfo,
-	.get_regs_len	= rt2400pci_get_regs_len,
-	.get_regs	= rt2400pci_get_regs,
-#ifdef CONFIG_RT2400PCI_DEBUG
-	.get_msglevel	= rt2400pci_get_msglevel,
-	.set_msglevel	= rt2400pci_set_msglevel,
-#endif /* CONFIG_RT2400PCI_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt2400pci_get_eeprom_len,
-	.get_eeprom	= rt2400pci_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt2400pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2861,7 +2785,6 @@
 		goto exit_disable_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-02 14:52:11.000000000 +0100
@@ -35,7 +35,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -343,81 +342,6 @@
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt2500pci_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, "N/A");
-	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt2500pci_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt2500pci_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT2500PCI_DEBUG
-static u32 rt2500pci_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt2500pci_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT2500PCI_DEBUG */
-
-static int rt2500pci_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt2500pci_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt2500pci_ethtool_ops = {
-	.get_drvinfo	= rt2500pci_get_drvinfo,
-	.get_regs_len	= rt2500pci_get_regs_len,
-	.get_regs	= rt2500pci_get_regs,
-#ifdef CONFIG_RT2500PCI_DEBUG
-	.get_msglevel	= rt2500pci_get_msglevel,
-	.set_msglevel	= rt2500pci_set_msglevel,
-#endif /* CONFIG_RT2500PCI_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt2500pci_get_eeprom_len,
-	.get_eeprom	= rt2500pci_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt2500pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -3146,7 +3070,6 @@
 		goto exit_disable_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt2500pci_ethtool_ops);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-02 14:52:10.000000000 +0100
@@ -34,7 +34,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -215,81 +214,6 @@
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt2500usb_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, "N/A");
-	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt2500usb_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt2500usb_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT2500USB_DEBUG
-static u32 rt2500usb_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt2500usb_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT2500USB_DEBUG */
-
-static int rt2500usb_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt2500usb_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset, (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt2500usb_ethtool_ops = {
-	.get_drvinfo	= rt2500usb_get_drvinfo,
-	.get_regs_len	= rt2500usb_get_regs_len,
-	.get_regs	= rt2500usb_get_regs,
-#ifdef CONFIG_RT2500USB_DEBUG
-	.get_msglevel	= rt2500usb_get_msglevel,
-	.set_msglevel	= rt2500usb_set_msglevel,
-#endif /* CONFIG_RT2500USB_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt2500usb_get_eeprom_len,
-	.get_eeprom	= rt2500usb_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt2500usb_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2803,7 +2727,6 @@
 		goto exit_put_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt2500usb_ethtool_ops);
 	SET_NETDEV_DEV(net_dev, &usb_intf->dev);
 
 	usb_set_intfdata(usb_intf, net_dev);
diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-02 14:52:10.000000000 +0100
@@ -36,7 +36,6 @@
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -374,81 +373,6 @@
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt61pci_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
-	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt61pci_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt61pci_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev	*rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT61PCI_DEBUG
-static u32 rt61pci_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt61pci_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT61PCI_DEBUG */
-
-static int rt61pci_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt61pci_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt61pci_ethtool_ops = {
-	.get_drvinfo	= rt61pci_get_drvinfo,
-	.get_regs_len	= rt61pci_get_regs_len,
-	.get_regs	= rt61pci_get_regs,
-#ifdef CONFIG_RT61PCI_DEBUG
-	.get_msglevel	= rt61pci_get_msglevel,
-	.set_msglevel	= rt61pci_set_msglevel,
-#endif /* CONFIG_RT61PCI_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt61pci_get_eeprom_len,
-	.get_eeprom	= rt61pci_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt61pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -3663,7 +3587,6 @@
 		goto exit_disable_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt61pci_ethtool_ops);
 	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
diff -rU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-02 14:52:09.000000000 +0100
@@ -35,7 +35,6 @@
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -216,81 +215,6 @@
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt73usb_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
-	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt73usb_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt73usb_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT73USB_DEBUG
-static u32 rt73usb_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt73usb_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT73USB_DEBUG */
-
-static int rt73usb_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt73usb_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset, (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt73usb_ethtool_ops = {
-	.get_drvinfo	= rt73usb_get_drvinfo,
-	.get_regs_len	= rt73usb_get_regs_len,
-	.get_regs	= rt73usb_get_regs,
-#ifdef CONFIG_RT73USB_DEBUG
-	.get_msglevel	= rt73usb_get_msglevel,
-	.set_msglevel	= rt73usb_set_msglevel,
-#endif /* CONFIG_RT2500USB_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt73usb_get_eeprom_len,
-	.get_eeprom	= rt73usb_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt73usb_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -3169,7 +3093,6 @@
 		goto exit_put_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt73usb_ethtool_ops);
 	SET_NETDEV_DEV(net_dev, &usb_intf->dev);
 
 	usb_set_intfdata(usb_intf, net_dev);
