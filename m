From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 11/11] isdn/gigaset: remove EXPERIMENTAL tag from GIGASET_CAPI
Date: Tue,  6 Jul 2010 02:19:30 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-11.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:42015 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757116Ab0GFATq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 20:19:46 -0400
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CAPI variant of the Gigaset drivers can, in combination with
capidrv, now fully replace the legacy ISDN4Linux variant. All
reported problems have been fixed. So remove the EXPERIMENTAL tag
from the Kconfig option selecting it, and adapt the documentation
accordingly to encourage users to switch to it.

Impact: documentation/status update, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |  100 +++++++++++++++++++-----------------
 drivers/isdn/gigaset/Kconfig      |    4 +-
 2 files changed, 55 insertions(+), 49 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index e472df8..7502c3f 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -47,9 +47,9 @@ GigaSet 307x Device Driver
 
 1.2. Software
      --------
-     The driver works with ISDN4linux and so can be used with any software
-     which is able to use ISDN4linux for ISDN connections (voice or data).
-     Experimental Kernel CAPI support is available as a compilation option.
+     The driver works with the Kernel CAPI subsystem as well as the old
+     ISDN4Linux subsystem, so it can be used with any software which is able
+     to use CAPI 2.0 or ISDN4Linux for ISDN connections (voice or data).
 
      There are some user space tools available at
      http://sourceforge.net/projects/gigaset307x/
@@ -152,61 +152,42 @@ GigaSet 307x Device Driver
      - GIGVER_FWBASE: retrieve the firmware version of the base
      Upon return, version[] is filled with the requested version information.
 
-2.3. ISDN4linux
-     ----------
-     This is the "normal" mode of operation. After loading the module you can
-     set up the ISDN system just as you'd do with any ISDN card supported by
-     the ISDN4Linux subsystem. Most distributions provide some configuration
-     utility. If not, you can use some HOWTOs like
-         http://www.linuxhaven.de/dlhp/HOWTO/DE-ISDN-HOWTO-5.html
-     If this doesn't work, because you have some device like SX100 where
-     debug output (see section 3.2.) shows something like this when dialing
-         CMD Received: ERROR
-         Available Params: 0
-         Connection State: 0, Response: -1
-         gigaset_process_response: resp_code -1 in ConState 0 !
-         Timeout occurred
-     you probably need to use unimodem mode. (see section 2.5.)
-
-2.4. CAPI
+2.3. CAPI
      ----
      If the driver is compiled with CAPI support (kernel configuration option
-     GIGASET_CAPI, experimental) it can also be used with CAPI 2.0 kernel and
-     user space applications. For user space access, the module capi.ko must
-     be loaded. The capiinit command (included in the capi4k-utils package)
-     does this for you.
-
-     The CAPI variant of the driver supports legacy ISDN4Linux applications
-     via the capidrv compatibility driver. The kernel module capidrv.ko must
-     be loaded explicitly with the command
+     GIGASET_CAPI) the devices will show up as CAPI controllers as soon as the
+     corresponding driver module is loaded, and can then be used with CAPI 2.0
+     kernel and user space applications. For user space access, the module
+     capi.ko must be loaded.
+
+     Legacy ISDN4Linux applications are supported via the capidrv
+     compatibility driver. The kernel module capidrv.ko must be loaded
+     explicitly with the command
         modprobe capidrv
      if needed, and cannot be unloaded again without unloading the driver
      first. (These are limitations of capidrv.)
 
-     The note about unimodem mode in the preceding section applies here, too.
-
-2.5. Unimodem mode
-     -------------
-     This is needed for some devices [e.g. SX100] as they have problems with
-     the "normal" commands.
+     Most distributions handle loading and unloading of the various CAPI
+     modules automatically via the command capiinit(1) from the capi4k-utils
+     package or a similar mechanism. Note that capiinit(1) cannot unload the
+     Gigaset drivers because it doesn't support more than one module per
+     driver.
 
-     If you have installed the command line tool gigacontr, you can enter
-     unimodem mode using
-         gigacontr --mode unimodem
-     You can switch back using
-         gigacontr --mode isdn
+2.4. ISDN4Linux
+     ----------
+     If the driver is compiled without CAPI support (native ISDN4Linux
+     variant), it registers the device with the legacy ISDN4Linux subsystem
+     after loading the module. It can then be used with ISDN4Linux
+     applications only. Most distributions provide some configuration utility
+     for setting up that subsystem. Otherwise you can use some HOWTOs like
+         http://www.linuxhaven.de/dlhp/HOWTO/DE-ISDN-HOWTO-5.html
 
-     You can also put the driver directly into Unimodem mode when it's loaded,
-     by passing the module parameter startmode=0 to the hardware specific
-     module, e.g.
-	modprobe usb_gigaset startmode=0
-     or by adding a line like
-	options usb_gigaset startmode=0
-     to an appropriate module configuration file, like /etc/modprobe.d/gigaset
-     or /etc/modprobe.conf.local.
 
+2.5. Unimodem mode
+     -------------
      In this mode the device works like a modem connected to a serial port
      (the /dev/ttyGU0, ... mentioned above) which understands the commands
+
          ATZ                 init, reset
              => OK or ERROR
          ATD
@@ -234,6 +215,31 @@ GigaSet 307x Device Driver
      to an appropriate module configuration file, like /etc/modprobe.d/gigaset
      or /etc/modprobe.conf.local.
 
+     Unimodem mode is needed for making some devices [e.g. SX100] work which
+     do not support the regular Gigaset command set. If debug output (see
+     section 3.2.) shows something like this when dialing:
+         CMD Received: ERROR
+         Available Params: 0
+         Connection State: 0, Response: -1
+         gigaset_process_response: resp_code -1 in ConState 0 !
+         Timeout occurred
+     then switching to unimodem mode may help.
+
+     If you have installed the command line tool gigacontr, you can enter
+     unimodem mode using
+         gigacontr --mode unimodem
+     You can switch back using
+         gigacontr --mode isdn
+
+     You can also put the driver directly into Unimodem mode when it's loaded,
+     by passing the module parameter startmode=0 to the hardware specific
+     module, e.g.
+	modprobe usb_gigaset startmode=0
+     or by adding a line like
+	options usb_gigaset startmode=0
+     to an appropriate module configuration file, like /etc/modprobe.d/gigaset
+     or /etc/modprobe.conf.local.
+
 2.6. Call-ID (CID) mode
      ------------------
      Call-IDs are numbers used to tag commands to, and responses from, the
diff --git a/drivers/isdn/gigaset/Kconfig b/drivers/isdn/gigaset/Kconfig
index dcefedc..b18a92c 100644
--- a/drivers/isdn/gigaset/Kconfig
+++ b/drivers/isdn/gigaset/Kconfig
@@ -17,8 +17,7 @@ menuconfig ISDN_DRV_GIGASET
 if ISDN_DRV_GIGASET
 
 config GIGASET_CAPI
-	bool "Gigaset CAPI support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
+	bool "Gigaset CAPI support"
 	depends on ISDN_CAPI='y'||(ISDN_CAPI='m'&&ISDN_DRV_GIGASET='m')
 	default ISDN_I4L='n'
 	help
@@ -27,6 +26,7 @@ config GIGASET_CAPI
 	  subsystem you'll have to enable the capidrv glue driver.
 	  (select ISDN_CAPI_CAPIDRV.)
 	  Say N to build the old native ISDN4Linux variant.
+	  If unsure, say Y.
 
 config GIGASET_I4L
 	bool
-- 
1.6.5.3.298.g39add

