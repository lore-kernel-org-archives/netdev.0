From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 9/24] RT2x00: Don't use driver_data and driver_info fields
Date: Wed, 26 Jul 2006 19:05:04 +0200
Message-ID: <200607261905.04965.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:5025 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030291AbWGZRHd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:33 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812601nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:32 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

driver_info and driver_data are not required for rt2x00,
neither is there any need to check that field when the probe()
function is called. The PCI and USB layers already correctly
make the checks.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-23 18:34:06.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 
19:36:40.000000000 +0200
@@ -2670,11 +2670,6 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (unlikely(id->driver_data != RT2460)) {
-		ERROR("Detected device not supported.\n");
-		return -ENODEV;
-	}
-
 	if (pci_enable_device(pci_dev)) {
 		ERROR("Enable device failed.\n");
 		return -EIO;
@@ -2839,7 +2834,7 @@
 	DRV_NAME " - " DRV_VERSION " (" DRV_RELDATE ") by " DRV_PROJECT;
 
 static struct pci_device_id rt2400pci_device_table[] = {
-	{ PCI_DEVICE(0x1814, 0x0101), .driver_data = RT2460},
+	{ PCI_DEVICE(0x1814, 0x0101) },
 	{ 0, }
 };
 
diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-23 18:34:14.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 
19:33:46.000000000 +0200
@@ -2936,11 +2936,6 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (unlikely(id->driver_data != RT2560)) {
-		ERROR("Detected device not supported.\n");
-		return -ENODEV;
-	}
-
 	if (pci_enable_device(pci_dev)) {
 		ERROR("Enable device failed.\n");
 		return -EIO;
@@ -3105,7 +3100,7 @@
 	DRV_NAME " - " DRV_VERSION " (" DRV_RELDATE ") by " DRV_PROJECT;
 
 static struct pci_device_id rt2500pci_device_table[] = {
-	{ PCI_DEVICE(0x1814, 0x0201), .driver_data = RT2560},
+	{ PCI_DEVICE(0x1814, 0x0201) },
 	{ 0, }
 };
 
diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-23 18:36:12.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 
19:36:18.000000000 +0200
@@ -2545,11 +2545,6 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (unlikely(id->driver_info != RT2570)) {
-		ERROR("Detected device not supported.\n");
-		return -ENODEV;
-	}
-
 	usb_dev = usb_get_dev(usb_dev);
 
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
@@ -2682,46 +2677,46 @@
 
 static struct usb_device_id rt2500usb_device_table[] = {
 	/* ASUS */
-	{ USB_DEVICE(0x0b05, 0x1706), .driver_info = RT2570},
-	{ USB_DEVICE(0x0b05, 0x1707), .driver_info = RT2570},
+	{ USB_DEVICE(0x0b05, 0x1706) },
+	{ USB_DEVICE(0x0b05, 0x1707) },
 	/* Belkin */
-	{ USB_DEVICE(0x050d, 0x7050), .driver_info = RT2570},
-	{ USB_DEVICE(0x050d, 0x7051), .driver_info = RT2570},
-	{ USB_DEVICE(0x050d, 0x705a), .driver_info = RT2570},
+	{ USB_DEVICE(0x050d, 0x7050) },
+	{ USB_DEVICE(0x050d, 0x7051) },
+	{ USB_DEVICE(0x050d, 0x705a) },
 	/* Cisco Systems */
-	{ USB_DEVICE(0x13b1, 0x000d), .driver_info = RT2570},
-	{ USB_DEVICE(0x13b1, 0x0011), .driver_info = RT2570},
-	{ USB_DEVICE(0x13b1, 0x001a), .driver_info = RT2570},
+	{ USB_DEVICE(0x13b1, 0x000d) },
+	{ USB_DEVICE(0x13b1, 0x0011) },
+	{ USB_DEVICE(0x13b1, 0x001a) },
 	/* Conceptronic */
-	{ USB_DEVICE(0x14b2, 0x3c02), .driver_info = RT2570},
+	{ USB_DEVICE(0x14b2, 0x3c02) },
 	/* D-LINK */
-	{ USB_DEVICE(0x2001, 0x3c00), .driver_info = RT2570},
+	{ USB_DEVICE(0x2001, 0x3c00) },
 	/* Gigabyte */
-	{ USB_DEVICE(0x1044, 0x8001), .driver_info = RT2570},
-	{ USB_DEVICE(0x1044, 0x8007), .driver_info = RT2570},
+	{ USB_DEVICE(0x1044, 0x8001) },
+	{ USB_DEVICE(0x1044, 0x8007) },
 	/* Hercules */
-	{ USB_DEVICE(0x06f8, 0xe000), .driver_info = RT2570},
+	{ USB_DEVICE(0x06f8, 0xe000) },
 	/* Melco */
-	{ USB_DEVICE(0x0411, 0x0066), .driver_info = RT2570},
-	{ USB_DEVICE(0x0411, 0x0067), .driver_info = RT2570},
-	{ USB_DEVICE(0x0411, 0x008b), .driver_info = RT2570},
+	{ USB_DEVICE(0x0411, 0x0066) },
+	{ USB_DEVICE(0x0411, 0x0067) },
+	{ USB_DEVICE(0x0411, 0x008b) },
 	/* MSI */
-	{ USB_DEVICE(0x0db0, 0x6861), .driver_info = RT2570},
-	{ USB_DEVICE(0x0db0, 0x6865), .driver_info = RT2570},
-	{ USB_DEVICE(0x0db0, 0x6869), .driver_info = RT2570},
+	{ USB_DEVICE(0x0db0, 0x6861) },
+	{ USB_DEVICE(0x0db0, 0x6865) },
+	{ USB_DEVICE(0x0db0, 0x6869) },
 	/* Ralink */
-	{ USB_DEVICE(0x148f, 0x1706), .driver_info = RT2570},
-	{ USB_DEVICE(0x148f, 0x2570), .driver_info = RT2570},
-	{ USB_DEVICE(0x148f, 0x2573), .driver_info = RT2570},
-	{ USB_DEVICE(0x148f, 0x9020), .driver_info = RT2570},
+	{ USB_DEVICE(0x148f, 0x1706) },
+	{ USB_DEVICE(0x148f, 0x2570) },
+	{ USB_DEVICE(0x148f, 0x2573) },
+	{ USB_DEVICE(0x148f, 0x9020) },
 	/* SMC */
-	{ USB_DEVICE(0x0707, 0xee13), .driver_info = RT2570},
+	{ USB_DEVICE(0x0707, 0xee13) },
 	/* Spairon */
-	{ USB_DEVICE(0x114b, 0x0110), .driver_info = RT2570},
+	{ USB_DEVICE(0x114b, 0x0110) },
 	/* Trust */
-	{ USB_DEVICE(0x0eb0, 0x9020), .driver_info = RT2570},
+	{ USB_DEVICE(0x0eb0, 0x9020) },
 	/* Zinwell */
-	{ USB_DEVICE(0x5a57, 0x0260), .driver_info = RT2570},
+	{ USB_DEVICE(0x5a57, 0x0260) },
 	{0,}
 };
 
diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 
19:22:41.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 
19:34:27.000000000 +0200
@@ -3517,11 +3517,6 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (unlikely(id->driver_data != RT61)) {
-		ERROR("Detected device not supported.\n");
-		return -ENODEV;
-	}
-
 	if (pci_enable_device(pci_dev)) {
 		ERROR("Enable device failed.\n");
 		return -EIO;
@@ -3687,11 +3682,11 @@
 
 static struct pci_device_id rt61pci_device_table[] = {
 	/* RT2561s */
-	{ PCI_DEVICE(0x1814, 0x0301), .driver_data = RT61},
+	{ PCI_DEVICE(0x1814, 0x0301) },
 	/* RT2561 v2 */
-	{ PCI_DEVICE(0x1814, 0x0302), .driver_data = RT61},
+	{ PCI_DEVICE(0x1814, 0x0302) },
 	/* RT2661 */
-	{ PCI_DEVICE(0x1814, 0x0401), .driver_data = RT61},
+	{ PCI_DEVICE(0x1814, 0x0401) },
 	{ 0, }
 };
 
diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.h 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 
18:33:18.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 
19:33:56.000000000 +0200
@@ -30,7 +30,6 @@
 /*
  * RT chip defines.
  */
-#define RT61				0x0300
 #define RT2561				0x0301
 #define RT2561s				0x0302
 #define RT2661				0x0401
diff -rU3 wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-state/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 
19:23:14.000000000 +0200
+++ wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 
19:33:08.000000000 +0200
@@ -2972,11 +2972,6 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (unlikely(id->driver_info != RT73)) {
-		ERROR("Detected device not supported.\n");
-		return -ENODEV;
-	}
-
 	usb_dev = usb_get_dev(usb_dev);
 
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
@@ -3108,23 +3103,23 @@
 
 static struct usb_device_id rt73usb_device_table[] = {
 	/* Belkin */
-	{ USB_DEVICE(0x050d, 0x7050), .driver_info = RT73},
-	{ USB_DEVICE(0x050d, 0x705a), .driver_info = RT73},
+	{ USB_DEVICE(0x050d, 0x7050) },
+	{ USB_DEVICE(0x050d, 0x705a) },
 	/* Conceptronic */
-	{ USB_DEVICE(0x14b2, 0x3c22), .driver_info = RT73},
+	{ USB_DEVICE(0x14b2, 0x3c22) },
 	/* D-Link */
-	{ USB_DEVICE(0x07d1, 0x3c03), .driver_info = RT73},
-	{ USB_DEVICE(0x07d1, 0x3c04), .driver_info = RT73},
+	{ USB_DEVICE(0x07d1, 0x3c03) },
+	{ USB_DEVICE(0x07d1, 0x3c04) },
 	/* Gigabyte */
-	{ USB_DEVICE(0x1044, 0x8008), .driver_info = RT73},
+	{ USB_DEVICE(0x1044, 0x8008) },
 	/* MSI */
-	{ USB_DEVICE(0x0db0, 0x6877), .driver_info = RT73},
-	{ USB_DEVICE(0x0db0, 0xa874), .driver_info = RT73},
+	{ USB_DEVICE(0x0db0, 0x6877) },
+	{ USB_DEVICE(0x0db0, 0xa874) },
 	/* Ralink */
-	{ USB_DEVICE(0x148f, 0x2573), .driver_info = RT73},
-	{ USB_DEVICE(0x148f, 0x2671), .driver_info = RT73},
+	{ USB_DEVICE(0x148f, 0x2573) },
+	{ USB_DEVICE(0x148f, 0x2671) },
 	/* Qcom */
-	{ USB_DEVICE(0x18e8, 0x6196), .driver_info = RT73},
+	{ USB_DEVICE(0x18e8, 0x6196) },
 	{ 0, }
 };
 
