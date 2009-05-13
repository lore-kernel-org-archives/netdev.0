From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 7/8] gigaset: remove UNDOCREQ config option
Date: Thu, 14 May 2009 00:44:18 +0200 (CEST)
Message-ID: <20090514-patch-07.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:38985 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760355AbZEMWog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:36 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop the kernel config option GIGASET_UNDOCREQ, permanently
activating the code it controlled, as there have been no reports
of problems caused by its activation but many problems caused by
it being disabled.
Also fix a few bad comments while we're at it.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset  |   33 +++----------------
 drivers/isdn/gigaset/Kconfig       |    7 ----
 drivers/isdn/gigaset/usb-gigaset.c |   62 +++++++++++++----------------------
 3 files changed, 28 insertions(+), 74 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index f6e9eaa..f996310 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -149,10 +149,8 @@ GigaSet 307x Device Driver
      configuration files and chat scripts in the gigaset-VERSION/ppp directory
      in the driver packages from http://sourceforge.net/projects/gigaset307x/.
      Please note that the USB drivers are not able to change the state of the
-     control lines (the M105 driver can be configured to use some undocumented
-     control requests, if you really need the control lines, though). This means
-     you must use "Stupid Mode" if you are using wvdial or you should use the
-     nocrtscts option of pppd.
+     control lines. This means you must use "Stupid Mode" if you are using
+     wvdial or you should use the nocrtscts option of pppd.
      You must also assure that the ppp_async module is loaded with the parameter
      flag_time=0. You can do this e.g. by adding a line like
 
@@ -190,20 +188,7 @@ GigaSet 307x Device Driver
      You can also use /sys/class/tty/ttyGxy/cidmode for changing the CID mode
      setting (ttyGxy is ttyGU0 or ttyGB0).
 
-2.6. M105 Undocumented USB Requests
-     ------------------------------
-     The Gigaset M105 USB data box understands a couple of useful, but
-     undocumented USB commands. These requests are not used in normal
-     operation (for wireless access to the base), but are needed for access
-     to the M105's own configuration mode (registration to the base, baudrate
-     and line format settings, device status queries) via the gigacontr
-     utility. Their use is controlled by the kernel configuration option
-     "Support for undocumented USB requests" (CONFIG_GIGASET_UNDOCREQ). If you
-     encounter error code -ENOTTY when trying to use some features of the
-     M105, try setting that option to "y" via 'make {x,menu}config' and
-     recompiling the driver.
-
-2.7. Unregistered Wireless Devices (M101/M105)
+2.6. Unregistered Wireless Devices (M101/M105)
      -----------------------------------------
      The main purpose of the ser_gigaset and usb_gigaset drivers is to allow
      the M101 and M105 wireless devices to be used as ISDN devices for ISDN
@@ -215,8 +200,7 @@ GigaSet 307x Device Driver
      driver. In that situation, a restricted set of functions is available
      which includes, in particular, those necessary for registering the device
      to a base or for switching it between Fixed Part and Portable Part
-     modes. For the M105, these commands require the "Support for undocumented
-     USB requests" configuration option (see section 2.6.) to be enabled.
+     modes.
 
 3.   Troubleshooting
      ---------------
@@ -247,19 +231,12 @@ GigaSet 307x Device Driver
         Select Unimodem mode for all DECT data adapters. (see section 2.4.)
 
      Problem:
-        You want to configure your USB DECT data adapter (M105) but gigacontr
-        reports an error: "/dev/ttyGU0: Inappropriate ioctl for device".
-     Solution:
-        Recompile the usb_gigaset driver with the kernel configuration option
-        CONFIG_GIGASET_UNDOCREQ set to 'y'. (see section 2.6.)
-
-     Problem:
 	Messages like this:
 	    usb_gigaset 3-2:1.0: Could not initialize the device.
 	appear in your syslog.
      Solution:
 	Check whether your M10x wireless device is correctly registered to the
-	Gigaset base. (see section 2.7.)
+	Gigaset base. (see section 2.6.)
 
 3.2. Telling the driver to provide more information
      ----------------------------------------------
diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index 9ca889a..65ca305 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -42,11 +42,4 @@ config GIGASET_DEBUG
 	  This enables debugging code in the Gigaset drivers.
 	  If in doubt, say yes.
 
-config GIGASET_UNDOCREQ
-	bool "Support for undocumented USB requests"
-	help
-	  This enables support for USB requests we only know from
-	  reverse engineering (currently M105 only). If you need
-	  features like configuration mode of M105, say yes.
-
 endif # ISDN_DRV_GIGASET
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index d783851..4deb1ab 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -153,8 +153,6 @@ static inline unsigned tiocm_to_gigaset(unsigned state)
 	return ((state & TIOCM_DTR) ? 1 : 0) | ((state & TIOCM_RTS) ? 2 : 0);
 }
 
-#ifdef CONFIG_GIGASET_UNDOCREQ
-/* WARNING: EXPERIMENTAL! */
 static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 				  unsigned new_state)
 {
@@ -176,6 +174,11 @@ static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
 	return 0;
 }
 
+/*
+ * Set M105 configuration value
+ * using undocumented device commands reverse engineered from USB traces
+ * of the Siemens Windows driver
+ */
 static int set_value(struct cardstate *cs, u8 req, u16 val)
 {
 	struct usb_device *udev = cs->hw.usb->udev;
@@ -205,8 +208,10 @@ static int set_value(struct cardstate *cs, u8 req, u16 val)
 	return r < 0 ? r : (r2 < 0 ? r2 : 0);
 }
 
-/* WARNING: HIGHLY EXPERIMENTAL! */
-// don't use this in an interrupt/BH
+/*
+ * set the baud rate on the internal serial adapter
+ * using the undocumented parameter setting command
+ */
 static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
 {
 	u16 val;
@@ -237,8 +242,10 @@ static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
 	return set_value(cs, 1, val);
 }
 
-/* WARNING: HIGHLY EXPERIMENTAL! */
-// don't use this in an interrupt/BH
+/*
+ * set the line format on the internal serial adapter
+ * using the undocumented parameter setting command
+ */
 static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 {
 	u16 val = 0;
@@ -274,24 +281,6 @@ static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
 	return set_value(cs, 3, val);
 }
 
-#else
-static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
-				  unsigned new_state)
-{
-	return -ENOTTY;
-}
-
-static int gigaset_set_line_ctrl(struct cardstate *cs, unsigned cflag)
-{
-	return -ENOTTY;
-}
-
-static int gigaset_baud_rate(struct cardstate *cs, unsigned cflag)
-{
-	return -ENOTTY;
-}
-#endif
-
 
  /*================================================================================================================*/
 static int gigaset_init_bchannel(struct bc_state *bcs)
@@ -362,10 +351,8 @@ static void gigaset_modem_fill(unsigned long data)
 	} while (again);
 }
 
-/**
- *	gigaset_read_int_callback
- *
- *	It is called if the data was received from the device.
+/*
+ * Interrupt Input URB completion routine
  */
 static void gigaset_read_int_callback(struct urb *urb)
 {
@@ -567,18 +554,19 @@ static int gigaset_chars_in_buffer(struct cardstate *cs)
 	return cs->cmdbytes;
 }
 
+/*
+ * set the break characters on the internal serial adapter
+ * using undocumented device commands reverse engineered from USB traces
+ * of the Siemens Windows driver
+ */
 static int gigaset_brkchars(struct cardstate *cs, const unsigned char buf[6])
 {
-#ifdef CONFIG_GIGASET_UNDOCREQ
 	struct usb_device *udev = cs->hw.usb->udev;
 
 	gigaset_dbg_buffer(DEBUG_USBREQ, "brkchars", 6, buf);
 	memcpy(cs->hw.usb->bchars, buf, 6);
 	return usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x19, 0x41,
 			       0, 0, &buf, 6, 2000);
-#else
-	return -ENOTTY;
-#endif
 }
 
 static int gigaset_freebcshw(struct bc_state *bcs)
@@ -625,7 +613,6 @@ static int gigaset_initcshw(struct cardstate *cs)
 	ucs->bchars[5] = 0x13;
 	ucs->bulk_out_buffer = NULL;
 	ucs->bulk_out_urb = NULL;
-	//ucs->urb_cmd_out = NULL;
 	ucs->read_urb = NULL;
 	tasklet_init(&cs->write_tasklet,
 		     &gigaset_modem_fill, (unsigned long) cs);
@@ -742,7 +729,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	cs->dev = &interface->dev;
 
 	/* save address of controller structure */
-	usb_set_intfdata(interface, cs); // dev_set_drvdata(&interface->dev, cs);
+	usb_set_intfdata(interface, cs);
 
 	endpoint = &hostif->endpoint[0].desc;
 
@@ -921,8 +908,7 @@ static const struct gigaset_ops ops = {
 	gigaset_m10x_input,
 };
 
-/**
- *	usb_gigaset_init
+/*
  * This function is called while kernel-module is loaded
  */
 static int __init usb_gigaset_init(void)
@@ -952,9 +938,7 @@ error:
 	return -1;
 }
 
-
-/**
- *	usb_gigaset_exit
+/*
  * This function is called while unloading the kernel-module
  */
 static void __exit usb_gigaset_exit(void)
-- 
1.6.2.1.214.ge986c

