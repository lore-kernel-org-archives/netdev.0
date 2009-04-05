From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/3] gigaset: documentation update
Date: Sun,  5 Apr 2009 18:39:33 +0200 (CEST)
Message-ID: <20090404-patch-03.tilman@imap.cc>
References: <20090404-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:56707 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbZDEQjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 12:39:54 -0400
In-Reply-To: <20090404-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update, correct and clarify instructions for loading the driver
and for setting the UNDOCREQ kernel configuration option.

Impact: documentation

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |   52 ++++++++++++++++++++++--------------
 1 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index 55b2852..02c0e93 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -61,24 +61,28 @@ GigaSet 307x Device Driver
      ---------------------
 2.1. Modules
      -------
-     To get the device working, you have to load the proper kernel module. You
-     can do this using
-         modprobe modulename
-     where modulename is ser_gigaset (M101), usb_gigaset (M105), or
-     bas_gigaset (direct USB connection to the base).
+     For the devices to work, the proper kernel modules have to be loaded.
+     This normally happens automatically when the system detects the USB
+     device (base, M105) or when the line discipline is attached (M101). It
+     can also be triggered manually using the modprobe(8) command, for example
+     for troubleshooting or to pass module parameters.
 
      The module ser_gigaset provides a serial line discipline N_GIGASET_M101
-     which drives the device through the regular serial line driver. To use it,
-     run the Gigaset M101 daemon "gigasetm101d" (also available from
-     http://sourceforge.net/projects/gigaset307x/) with the device file of the
-     RS232 port to the M101 as an argument, for example:
-	 gigasetm101d /dev/ttyS1
-     This will open the device file, set its line discipline to N_GIGASET_M101,
-     and then sleep in the background, keeping the device open so that the
-     line discipline remains active. To deactivate it, kill the daemon, for
-     example with
-	 killall gigasetm101d
-     before disconnecting the device.
+     which drives the device through the regular serial line driver. It must
+     be attached to the serial line to which the M101 is connected with the
+     ldattach(8) command (requires util-linux-ng release 2.14 or later), for
+     example:
+	 ldattach GIGASET_M101 /dev/ttyS1
+     This will open the device file, attach the line discipline to it, and
+     then sleep in the background, keeping the device open so that the line
+     discipline remains active. To deactivate it, kill the daemon, for example
+     with
+	 killall ldattach
+     before disconnecting the device. To have this happen automatically at
+     system startup/shutdown on an LSB compatible system, create and activate
+     an appropriate LSB startup script /etc/init.d/gigaset. (The init name
+     'gigaset' is officially assigned to this project by LANANA.)
+     Alternatively, just add the 'ldattach' command line to /etc/rc.local.
 
 2.2. Device nodes for user space programs
      ------------------------------------
@@ -194,10 +198,11 @@ GigaSet 307x Device Driver
      operation (for wireless access to the base), but are needed for access
      to the M105's own configuration mode (registration to the base, baudrate
      and line format settings, device status queries) via the gigacontr
-     utility. Their use is disabled in the driver by default for safety
-     reasons but can be enabled by setting the kernel configuration option
-     "Support for undocumented USB requests" (GIGASET_UNDOCREQ) to "Y" and
-     recompiling.
+     utility. Their use is controlled by the kernel configuration option
+     "Support for undocumented USB requests" (CONFIG_GIGASET_UNDOCREQ). If you
+     encounter error code -ENOTTY when trying to use some features of the
+     M105, try setting that option to "y" via 'make {x,menu}config' and
+     recompiling the driver.
 
 
 3.   Troubleshooting
@@ -228,6 +233,13 @@ GigaSet 307x Device Driver
      Solution:
         Select Unimodem mode for all DECT data adapters. (see section 2.4.)
 
+     Problem:
+        You want to configure your USB DECT data adapter (M105) but gigacontr
+        reports an error: "/dev/ttyGU0: Inappropriate ioctl for device".
+     Solution:
+        Recompile the usb_gigaset driver with the kernel configuration option
+        CONFIG_GIGASET_UNDOCREQ set to 'y'. (see section 2.6.)
+
 3.2. Telling the driver to provide more information
      ----------------------------------------------
      Building the driver with the "Gigaset debugging" kernel configuration
-- 
1.6.2.1.214.ge986c

