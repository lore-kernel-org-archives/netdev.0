From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [patch 2/2] prism54: whitespace cleanup
Date: Sun, 08 Oct 2006 00:38:15 -0400
Message-ID: <20061008043954.621912351.dtor@insightbb.com>
References: <20061008043813.401495520.dtor@insightbb.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:48048 "EHLO
	asav09.insightbb.com") by vger.kernel.org with ESMTP
	id S1750785AbWJHEki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 00:40:38 -0400
To: linville@tuxdriver.com
Content-Disposition: inline; filename=prism54-whitespace-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET: prism54 - whitespace cleanup

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 drivers/net/wireless/prism54/isl_38xx.c       |   17 +++----
 drivers/net/wireless/prism54/isl_38xx.h       |    7 +-
 drivers/net/wireless/prism54/isl_ioctl.c      |   61 ++++++++++++--------------
 drivers/net/wireless/prism54/isl_ioctl.h      |    1 
 drivers/net/wireless/prism54/isl_oid.h        |   32 ++++++-------
 drivers/net/wireless/prism54/islpci_dev.c     |   13 ++---
 drivers/net/wireless/prism54/islpci_dev.h     |   11 ++--
 drivers/net/wireless/prism54/islpci_eth.c     |    7 +-
 drivers/net/wireless/prism54/islpci_eth.h     |    1 
 drivers/net/wireless/prism54/islpci_hotplug.c |   23 ++++-----
 drivers/net/wireless/prism54/islpci_mgt.c     |    3 -
 drivers/net/wireless/prism54/islpci_mgt.h     |    5 --
 drivers/net/wireless/prism54/oid_mgt.c        |    6 +-
 drivers/net/wireless/prism54/prismcompat.h    |    4 -
 14 files changed, 89 insertions(+), 102 deletions(-)

Index: work/drivers/net/wireless/prism54/isl_38xx.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/isl_38xx.c
+++ work/drivers/net/wireless/prism54/isl_38xx.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003-2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>_
  *
@@ -38,7 +37,7 @@
  * isl38xx_disable_interrupts - disable all interrupts
  * @device: pci memory base address
  *
- *  Instructs the device to disable all interrupt reporting by asserting 
+ *  Instructs the device to disable all interrupt reporting by asserting
  *  the IRQ line. New events may still show up in the interrupt identification
  *  register located at offset %ISL38XX_INT_IDENT_REG.
  */
@@ -204,17 +203,19 @@ isl38xx_interface_reset(void __iomem *de
 	/* enable the interrupt for detecting initialization */
 
 	/* Note: Do not enable other interrupts here. We want the
-	 * device to have come up first 100% before allowing any other 
+	 * device to have come up first 100% before allowing any other
 	 * interrupts. */
 	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
 
 void
-isl38xx_enable_common_interrupts(void __iomem *device_base) {
+isl38xx_enable_common_interrupts(void __iomem *device_base)
+{
 	u32 reg;
-	reg = ( ISL38XX_INT_IDENT_UPDATE | 
-			ISL38XX_INT_IDENT_SLEEP | ISL38XX_INT_IDENT_WAKEUP);
+
+	reg = ISL38XX_INT_IDENT_UPDATE | ISL38XX_INT_IDENT_SLEEP |
+	      ISL38XX_INT_IDENT_WAKEUP;
 	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);
 }
@@ -234,23 +235,21 @@ isl38xx_in_queue(isl38xx_control_block *
 		/* send queues */
 	case ISL38XX_CB_TX_MGMTQ:
 		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
+
 	case ISL38XX_CB_TX_DATA_LQ:
 	case ISL38XX_CB_TX_DATA_HQ:
 		BUG_ON(delta > ISL38XX_CB_TX_QSIZE);
 		return delta;
-		break;
 
 		/* receive queues */
 	case ISL38XX_CB_RX_MGMTQ:
 		BUG_ON(delta > ISL38XX_CB_MGMT_QSIZE);
 		return ISL38XX_CB_MGMT_QSIZE - delta;
-		break;
 
 	case ISL38XX_CB_RX_DATA_LQ:
 	case ISL38XX_CB_RX_DATA_HQ:
 		BUG_ON(delta > ISL38XX_CB_RX_QSIZE);
 		return ISL38XX_CB_RX_QSIZE - delta;
-		break;
 	}
 	BUG();
 	return 0;
Index: work/drivers/net/wireless/prism54/isl_38xx.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/isl_38xx.h
+++ work/drivers/net/wireless/prism54/isl_38xx.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -67,10 +66,10 @@
  * @base: (host) memory base address of the device
  * @val: 32bit value (host order) to write
  * @offset: byte offset into @base to write value to
- * 
+ *
  *  This helper takes care of writing a 32bit datum to the
- *  specified offset into the device's pci memory space, and making sure 
- *  the pci memory buffers get flushed by performing one harmless read 
+ *  specified offset into the device's pci memory space, and making sure
+ *  the pci memory buffers get flushed by performing one harmless read
  *  from the %ISL38XX_PCI_POSTING_FLUSH offset.
  */
 static inline void
Index: work/drivers/net/wireless/prism54/isl_ioctl.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/isl_ioctl.c
+++ work/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
@@ -55,12 +54,12 @@ static const unsigned char scan_rate_lis
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
  * @iw_mode: new mode (%IW_MODE_*)
- * 
+ *
  *  This is a helper function, hence it does not lock. Make sure
- *  caller deals with locking *if* necessary. This function sets the 
- *  mode-dependent mib values and does the mapping of the Linux 
- *  Wireless API modes to Device firmware modes. It also checks for 
- *  correct valid Linux wireless modes. 
+ *  caller deals with locking *if* necessary. This function sets the
+ *  mode-dependent mib values and does the mapping of the Linux
+ *  Wireless API modes to Device firmware modes. It also checks for
+ *  correct valid Linux wireless modes.
  */
 static int
 prism54_mib_mode_helper(islpci_private *priv, u32 iw_mode)
@@ -118,7 +117,7 @@ prism54_mib_mode_helper(islpci_private *
  *
  *  this function initializes the struct given as @mib with defaults,
  *  of which many are retrieved from the global module parameter
- *  variables.  
+ *  variables.
  */
 
 void
@@ -134,7 +133,7 @@ prism54_mib_init(islpci_private *priv)
 	authen = CARD_DEFAULT_AUTHEN;
 	wep = CARD_DEFAULT_WEP;
 	filter = CARD_DEFAULT_FILTER; /* (0) Do not filter un-encrypted data */
-	dot1x = CARD_DEFAULT_DOT1X; 
+	dot1x = CARD_DEFAULT_DOT1X;
 	mlme = CARD_DEFAULT_MLME_MODE;
 	conformance = CARD_DEFAULT_CONFORMANCE;
 	power = 127;
@@ -228,7 +227,7 @@ prism54_get_wireless_stats(struct net_de
 	} else
 		priv->iwstatistics.qual.updated = 0;
 
-	/* Update our wireless stats, but do not schedule to often 
+	/* Update our wireless stats, but do not schedule to often
 	 * (max 1 HZ) */
 	if ((priv->stats_timestamp == 0) ||
 	    time_after(jiffies, priv->stats_timestamp + 1 * HZ)) {
@@ -705,7 +704,7 @@ prism54_get_scan(struct net_device *ndev
 	* Starting with WE-17, the buffer can be as big as needed.
 	* But the device won't repport anything if you change the value
 	* of IWMAX_BSS=24. */
-	
+
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
 
@@ -785,7 +784,7 @@ prism54_get_essid(struct net_device *nde
 	return rvalue;
 }
 
-/* Provides no functionality, just completes the ioctl. In essence this is a 
+/* Provides no functionality, just completes the ioctl. In essence this is a
  * just a cosmetic ioctl.
  */
 static int
@@ -1104,7 +1103,7 @@ prism54_set_encode(struct net_device *nd
 					    &key);
 		}
 		/*
-		 * If a valid key is set, encryption should be enabled 
+		 * If a valid key is set, encryption should be enabled
 		 * (user may turn it off later).
 		 * This is also how "iwconfig ethX key on" works
 		 */
@@ -1126,7 +1125,7 @@ prism54_set_encode(struct net_device *nd
 	}
 	/* now read the flags */
 	if (dwrq->flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
+		/* Encoding disabled,
 		 * authen = DOT11_AUTH_OS;
 		 * invoke = 0;
 		 * exunencrypt = 0; */
@@ -1214,7 +1213,7 @@ prism54_get_txpower(struct net_device *n
 	vwrq->value = (s32) r.u / 4;
 	vwrq->fixed = 1;
 	/* radio is not turned of
-	 * btw: how is possible to turn off only the radio 
+	 * btw: how is possible to turn off only the radio
 	 */
 	vwrq->disabled = 0;
 
@@ -2354,17 +2353,17 @@ prism54_process_trap_helper(islpci_priva
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_AUTHING)
 			break;
 
 		confirm = kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
 
-		if (!confirm) 
+		if (!confirm)
 			break;
 
 		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2398,10 +2397,10 @@ prism54_process_trap_helper(islpci_priva
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
-		
+
 		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
 
 		if (!confirm)
@@ -2417,7 +2416,7 @@ prism54_process_trap_helper(islpci_priva
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2435,14 +2434,14 @@ prism54_process_trap_helper(islpci_priva
 		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
 
 		kfree(confirm);
-		
+
 		break;
 
 	case DOT11_OID_REASSOCIATEEX:
 		handle_request(priv, mlme, oid);
 		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
 
-		if (priv->iw_mode != IW_MODE_MASTER 
+		if (priv->iw_mode != IW_MODE_MASTER
 				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
 
@@ -2461,7 +2460,7 @@ prism54_process_trap_helper(islpci_priva
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
+					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n",
 				mlmeex->address[0],
 				mlmeex->address[1],
 				mlmeex->address[2],
@@ -2473,13 +2472,13 @@ prism54_process_trap_helper(islpci_priva
 			break;
 		}
 
-		confirm->size = wpa_ie_len; 
+		confirm->size = wpa_ie_len;
 		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
 
 		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
 
 		kfree(confirm);
-		
+
 		break;
 
 	default:
@@ -2545,10 +2544,10 @@ enum {
 #define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
 ((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
 
-/* Maximum length for algorithm names (-1 for nul termination) 
+/* Maximum length for algorithm names (-1 for nul termination)
  * used in ioctl() */
 #define HOSTAP_CRYPT_ALG_NAME_LEN 16
-	
+
 struct prism2_hostapd_param {
 	u32 cmd;
 	u8 sta_addr[ETH_ALEN];
@@ -2621,7 +2620,7 @@ prism2_ioctl_set_encryption(struct net_d
 					    &key);
 		}
 		/*
-		 * If a valid key is set, encryption should be enabled 
+		 * If a valid key is set, encryption should be enabled
 		 * (user may turn it off later).
 		 * This is also how "iwconfig ethX key on" works
 		 */
@@ -2643,7 +2642,7 @@ prism2_ioctl_set_encryption(struct net_d
 	}
 	/* now read the flags */
 	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
+		/* Encoding disabled,
 		 * authen = DOT11_AUTH_OS;
 		 * invoke = 0;
 		 * exunencrypt = 0; */
@@ -2710,7 +2709,7 @@ prism2_ioctl_set_generic_element(struct 
 
 	       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
 
-	       if (ret == 0) 
+	       if (ret == 0)
 		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
 				       ndev->name);
        }
@@ -2870,7 +2869,7 @@ prism54_set_wpa(struct net_device *ndev,
 			mlme = DOT11_MLME_AUTO;
 			printk("%s: Disabling WPA\n", ndev->name);
 			break;
-		case 2: 
+		case 2:
 		case 1: /* WPA */
 			printk("%s: Enabling WPA\n", ndev->name);
 			break;
Index: work/drivers/net/wireless/prism54/isl_ioctl.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/isl_ioctl.h
+++ work/drivers/net/wireless/prism54/isl_ioctl.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *            (C) 2003 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
Index: work/drivers/net/wireless/prism54/isl_oid.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/isl_oid.h
+++ work/drivers/net/wireless/prism54/isl_oid.h
@@ -1,6 +1,4 @@
 /*
- *
- *  
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
@@ -23,7 +21,7 @@
 #if !defined(_ISL_OID_H)
 #define _ISL_OID_H
 
-/* 
+/*
  * MIB related constant and structure definitions for communicating
  * with the device firmware
  */
@@ -99,7 +97,7 @@ struct obj_attachment {
 	char data[0];
 } __attribute__((packed));
 
-/* 
+/*
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
  */
@@ -154,13 +152,13 @@ enum dot11_priv_t {
 
 /* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
  * Value is in microseconds. Represents the # microseconds
- * the firmware will take to group frames before sending out then out 
+ * the firmware will take to group frames before sending out then out
  * together with a CSMA contention. Without this all frames are
- * sent with a CSMA contention. 
- * Bibliography: 
+ * sent with a CSMA contention.
+ * Bibliography:
  * http://www.hpl.hp.com/personal/Jean_Tourrilhes/Papers/Packet.Frame.Grouping.html
  */
-enum dot11_maxframeburst_t { 
+enum dot11_maxframeburst_t {
 	/* Values for DOT11_OID_MAXFRAMEBURST */
 	DOT11_MAXFRAMEBURST_OFF = 0, /* Card firmware default */
 	DOT11_MAXFRAMEBURST_MIXED_SAFE = 650, /* 802.11 a,b,g safe */
@@ -176,9 +174,9 @@ enum dot11_maxframeburst_t { 
 /* Support for 802.11 long and short frame preambles.
  * Long	 preamble uses 128-bit sync field, 8-bit  CRC
  * Short preamble uses 56-bit  sync field, 16-bit CRC
- * 
+ *
  * 802.11a -- not sure, both optionally ?
- * 802.11b supports long and optionally short 
+ * 802.11b supports long and optionally short
  * 802.11g supports both */
 enum dot11_preamblesettings_t {
 	DOT11_PREAMBLESETTING_LONG = 0,
@@ -194,7 +192,7 @@ enum dot11_preamblesettings_t {
  * Long uses 802.11a slot timing  (9 usec ?)
  * Short uses 802.11b slot timing (20 use ?) */
 enum dot11_slotsettings_t {
-	DOT11_SLOTSETTINGS_LONG = 0, 
+	DOT11_SLOTSETTINGS_LONG = 0,
 		/* Allows *only* long 802.11b slot timing */
 	DOT11_SLOTSETTINGS_SHORT = 1,
 		/* Allows *only* long 802.11a slot timing */
@@ -203,7 +201,7 @@ enum dot11_slotsettings_t {
 };
 
 /* All you need to know, ERP is "Extended Rate PHY".
- * An Extended Rate PHY (ERP) STA or AP shall support three different 
+ * An Extended Rate PHY (ERP) STA or AP shall support three different
  * preamble and header formats:
  * Long  preamble (refer to above)
  * Short preamble (refer to above)
@@ -221,7 +219,7 @@ enum do11_nonerpstatus_t {
 /* (ERP is "Extended Rate PHY") Way to read NONERP is NON-ERP-*
  * The key here is DOT11 NON ERP NEVER protects against
  * NON ERP STA's. You *don't* want this unless
- * you know what you are doing. It means you will only 
+ * you know what you are doing. It means you will only
  * get Extended Rate capabilities */
 enum dot11_nonerpprotection_t {
 	DOT11_NONERP_NEVER = 0,
@@ -229,13 +227,13 @@ enum dot11_nonerpprotection_t {
 	DOT11_NONERP_DYNAMIC = 2
 };
 
-/* Preset OID configuration for 802.11 modes 
- * Note: DOT11_OID_CW[MIN|MAX] hold the values of the 
+/* Preset OID configuration for 802.11 modes
+ * Note: DOT11_OID_CW[MIN|MAX] hold the values of the
  * DCS MIN|MAX backoff used */
 enum dot11_profile_t { /* And set/allowed values */
 	/* Allowed values for DOT11_OID_PROFILES */
 	DOT11_PROFILE_B_ONLY = 0,
-		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps 
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps
 		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
 		 * DOT11_OID_CWMIN: 31
 		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
@@ -275,7 +273,7 @@ enum oid_inl_conformance_t {
 	OID_INL_CONFORMANCE_NONE = 0,	/* Perform active scanning */
 	OID_INL_CONFORMANCE_STRICT = 1,	/* Strictly adhere to 802.11d */
 	OID_INL_CONFORMANCE_FLEXIBLE = 2,	/* Use passed 802.11d info to
-		* determine channel AND/OR just make assumption that active 
+		* determine channel AND/OR just make assumption that active
 		* channels are valid  channels */
 };
 
Index: work/drivers/net/wireless/prism54/islpci_dev.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_dev.c
+++ work/drivers/net/wireless/prism54/islpci_dev.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
@@ -413,7 +412,7 @@ prism54_bring_down(islpci_private *priv)
 	islpci_set_state(priv, PRV_STATE_PREBOOT);
 
 	/* disable all device interrupts in case they weren't */
-	isl38xx_disable_interrupts(priv->device_base);  
+	isl38xx_disable_interrupts(priv->device_base);
 
 	/* For safety reasons, we may want to ensure that no DMA transfer is
 	 * currently in progress by emptying the TX and RX queues. */
@@ -480,7 +479,7 @@ islpci_reset_if(islpci_private *priv)
 
 	DEFINE_WAIT(wait);
 	prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
-	
+
 	/* now the last step is to reset the interface */
 	isl38xx_interface_reset(priv->device_base, priv->device_host_address);
 	islpci_set_state(priv, PRV_STATE_PREINIT);
@@ -488,7 +487,7 @@ islpci_reset_if(islpci_private *priv)
         for(count = 0; count < 2 && result; count++) {
 		/* The software reset acknowledge needs about 220 msec here.
 		 * Be conservative and wait for up to one second. */
-	
+
 		remaining = schedule_timeout_uninterruptible(HZ);
 
 		if(remaining > 0) {
@@ -496,7 +495,7 @@ islpci_reset_if(islpci_private *priv)
 			break;
 		}
 
-		/* If we're here it's because our IRQ hasn't yet gone through. 
+		/* If we're here it's because our IRQ hasn't yet gone through.
 		 * Retry a bit more...
 		 */
 		printk(KERN_ERR "%s: no 'reset complete' IRQ seen - retrying\n",
@@ -514,7 +513,7 @@ islpci_reset_if(islpci_private *priv)
 
 	/* Now that the device is 100% up, let's allow
 	 * for the other interrupts --
-	 * NOTE: this is not *yet* true since we've only allowed the 
+	 * NOTE: this is not *yet* true since we've only allowed the
 	 * INIT interrupt on the IRQ line. We can perhaps poll
 	 * the IRQ line until we know for sure the reset went through */
 	isl38xx_enable_common_interrupts(priv->device_base);
@@ -716,7 +715,7 @@ islpci_alloc_memory(islpci_private *priv
 
 	prism54_acl_init(&priv->acl);
 	prism54_wpa_bss_ie_init(priv);
-	if (mgt_init(priv)) 
+	if (mgt_init(priv))
 		goto out_free;
 
 	return 0;
Index: work/drivers/net/wireless/prism54/islpci_dev.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_dev.h
+++ work/drivers/net/wireless/prism54/islpci_dev.h
@@ -1,6 +1,5 @@
 /*
- *  
- *  Copyright (C) 2002 Intersil Americas Inc. 
+ *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2003 Aurelien Alleaume <slts@free.fr>
@@ -72,12 +71,12 @@ struct islpci_bss_wpa_ie {
 	u8 bssid[ETH_ALEN];
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	size_t wpa_ie_len;
-	
+
 };
 
 typedef struct {
 	spinlock_t slock;	/* generic spinlock; */
-	
+
 	u32 priv_oid;
 
 	/* our mib cache */
@@ -85,7 +84,7 @@ typedef struct {
         struct rw_semaphore mib_sem;
 	void **mib;
 	char nickname[IW_ESSID_MAX_SIZE+1];
-	
+
 	/* Take care of the wireless stats */
 	struct work_struct stats_work;
 	struct semaphore stats_sem;
@@ -120,7 +119,7 @@ typedef struct {
 	struct net_device *ndev;
 
 	/* device queue interface members */
-	struct isl38xx_cb *control_block;	/* device control block 
+	struct isl38xx_cb *control_block;	/* device control block
 							   (== driver_mem_address!) */
 
 	/* Each queue has three indexes:
Index: work/drivers/net/wireless/prism54/islpci_eth.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_eth.c
+++ work/drivers/net/wireless/prism54/islpci_eth.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
  *  This program is free software; you can redistribute it and/or modify
@@ -48,7 +47,7 @@ islpci_eth_cleanup_transmit(islpci_priva
 		/* read the index of the first fragment to be freed */
 		index = priv->free_data_tx % ISL38XX_CB_TX_QSIZE;
 
-		/* check for holes in the arrays caused by multi fragment frames 
+		/* check for holes in the arrays caused by multi fragment frames
 		 * searching for the last fragment of a frame */
 		if (priv->pci_map_tx_address[index] != (dma_addr_t) NULL) {
 			/* entry is the last fragment of a frame
@@ -285,7 +284,7 @@ islpci_monitor_rx(islpci_private *priv, 
 		    (struct avs_80211_1_header *) skb_push(*skb,
 							   sizeof (struct
 								   avs_80211_1_header));
-		
+
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
 		avs->mactime = cpu_to_be64(le64_to_cpu(clock));
@@ -391,7 +390,7 @@ islpci_eth_receive(islpci_private *priv)
 			struct rx_annex_header *annex =
 			    (struct rx_annex_header *) skb->data;
 			wstats.level = annex->rfmon.rssi;
-			/* The noise value can be a bit outdated if nobody's 
+			/* The noise value can be a bit outdated if nobody's
 			 * reading wireless stats... */
 			wstats.noise = priv->local_iwstatistics.qual.noise;
 			wstats.qual = wstats.level - wstats.noise;
Index: work/drivers/net/wireless/prism54/islpci_eth.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_eth.h
+++ work/drivers/net/wireless/prism54/islpci_eth.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *
  *  This program is free software; you can redistribute it and/or modify
Index: work/drivers/net/wireless/prism54/islpci_hotplug.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_hotplug.c
+++ work/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *
@@ -40,8 +39,8 @@ static int	init_pcitm = 0;
 module_param(init_pcitm, int, 0);
 
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
- * driver_data 
- * If you have an update for this please contact prism54-devel@prism54.org 
+ * driver_data
+ * If you have an update for this please contact prism54-devel@prism54.org
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
@@ -132,15 +131,15 @@ prism54_probe(struct pci_dev *pdev, cons
 
 	/* 0x40 is the programmable timer to configure the response timeout (TRDY_TIMEOUT)
 	 * 0x41 is the programmable timer to configure the retry timeout (RETRY_TIMEOUT)
-	 * 	The RETRY_TIMEOUT is used to set the number of retries that the core, as a
-	 * 	Master, will perform before abandoning a cycle. The default value for
-	 * 	RETRY_TIMEOUT is 0x80, which far exceeds the PCI 2.1 requirement for new
-	 * 	devices. A write of zero to the RETRY_TIMEOUT register disables this
-	 * 	function to allow use with any non-compliant legacy devices that may
-	 * 	execute more retries.
+	 *	The RETRY_TIMEOUT is used to set the number of retries that the core, as a
+	 *	Master, will perform before abandoning a cycle. The default value for
+	 *	RETRY_TIMEOUT is 0x80, which far exceeds the PCI 2.1 requirement for new
+	 *	devices. A write of zero to the RETRY_TIMEOUT register disables this
+	 *	function to allow use with any non-compliant legacy devices that may
+	 *	execute more retries.
 	 *
-	 * 	Writing zero to both these two registers will disable both timeouts and
-	 * 	*can* solve problems caused by devices that are slow to respond.
+	 *	Writing zero to both these two registers will disable both timeouts and
+	 *	*can* solve problems caused by devices that are slow to respond.
 	 *	Make this configurable - MSW
 	 */
 	if ( init_pcitm >= 0 ) {
@@ -241,7 +240,7 @@ prism54_remove(struct pci_dev *pdev)
 		isl38xx_disable_interrupts(priv->device_base);
 		islpci_set_state(priv, PRV_STATE_OFF);
 		/* This bellow causes a lockup at rmmod time. It might be
-		 * because some interrupts still linger after rmmod time, 
+		 * because some interrupts still linger after rmmod time,
 		 * see bug #17 */
 		/* pci_set_power_state(pdev, 3);*/	/* try to power-off */
 	}
Index: work/drivers/net/wireless/prism54/islpci_mgt.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_mgt.c
+++ work/drivers/net/wireless/prism54/islpci_mgt.c
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright 2004 Jens Maurer <Jens.Maurer@gmx.net>
  *
@@ -502,7 +501,7 @@ islpci_mgt_transaction(struct net_device
 	printk(KERN_WARNING "%s: timeout waiting for mgmt response\n",
 	       ndev->name);
 
-	/* TODO: we should reset the device here */     
+	/* TODO: we should reset the device here */
  out:
 	finish_wait(&priv->mgmt_wqueue, &wait);
 	up(&priv->mgmt_sem);
Index: work/drivers/net/wireless/prism54/islpci_mgt.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/islpci_mgt.h
+++ work/drivers/net/wireless/prism54/islpci_mgt.h
@@ -1,5 +1,4 @@
 /*
- *  
  *  Copyright (C) 2002 Intersil Americas Inc.
  *  Copyright (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *
@@ -36,8 +35,8 @@ extern int pc_debug;
 
 
 /* General driver definitions */
-#define PCIDEVICE_LATENCY_TIMER_MIN 		0x40
-#define PCIDEVICE_LATENCY_TIMER_VAL 		0x50
+#define PCIDEVICE_LATENCY_TIMER_MIN		0x40
+#define PCIDEVICE_LATENCY_TIMER_VAL		0x50
 
 /* Debugging verbose definitions */
 #define SHOW_NOTHING                            0x00	/* overrules everything */
Index: work/drivers/net/wireless/prism54/oid_mgt.c
===================================================================
--- work.orig/drivers/net/wireless/prism54/oid_mgt.c
+++ work/drivers/net/wireless/prism54/oid_mgt.c
@@ -1,4 +1,4 @@
-/*   
+/*
  *  Copyright (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -503,7 +503,7 @@ mgt_set_varlen(islpci_private *priv, enu
 		}
 		if (ret || response_op == PIMFOR_OP_ERROR)
 			ret = -EIO;
-	} else 
+	} else
 		ret = -EIO;
 
 	/* re-set given data to what it was */
@@ -727,7 +727,7 @@ mgt_commit(islpci_private *priv)
  * MEDIUMLIMIT,BEACONPERIOD,DTIMPERIOD,ATIMWINDOW,LISTENINTERVAL
  * FREQUENCY,EXTENDEDRATES.
  *
- * The way to do this is to set ESSID. Note though that they may get 
+ * The way to do this is to set ESSID. Note though that they may get
  * unlatch before though by setting another OID. */
 #if 0
 void
Index: work/drivers/net/wireless/prism54/prismcompat.h
===================================================================
--- work.orig/drivers/net/wireless/prism54/prismcompat.h
+++ work/drivers/net/wireless/prism54/prismcompat.h
@@ -1,4 +1,4 @@
-/*  
+/*
  *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
  *
  *  This program is free software; you can redistribute it and/or modify
@@ -16,7 +16,7 @@
  *
  */
 
-/*  
+/*
  *	Compatibility header file to aid support of different kernel versions
  */
 
