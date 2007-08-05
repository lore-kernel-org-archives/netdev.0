From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH 3/4][SSB] MIPS core flash driver
Date: Mon, 6 Aug 2007 01:20:44 +0200
Message-ID: <20070805232044.GD13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:47638 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750AbXHEX4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 19:56:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below against 2.6.23-rc1-mm2 fixes the size of the flash 
window and detect the width of the flash bus (8 or 16 bits).

It originally comes from the OpenWrt patches.

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

--- a/drivers/ssb/driver_mipscore.c	
+++ b/drivers/ssb/driver_mipscore.c	
@@ -186,12 +186,16 @@
 {
 	struct ssb_bus *bus = mcore->dev->bus;
 
+	mcore->flash_buswidth = 2;
 	if (bus->chipco.dev) {
 		mcore->flash_window = 0x1c000000;
-		mcore->flash_window_size = 0x800000;
+		mcore->flash_window_size = 0x02000000;
+		if ((ssb_read32(bus->chipco.dev, SSB_CHIPCO_FLASH_CFG)
+		               & SSB_CHIPCO_CFG_DS16) == 0)
+			mcore->flash_buswidth = 1;
 	} else {
 		mcore->flash_window = 0x1fc00000;
-		mcore->flash_window_size = 0x400000;
+		mcore->flash_window_size = 0x00400000;
 	}
 }
 
--- a/include/linux/ssb/ssb_driver_mips.h
+++ b/include/linux/ssb/ssb_driver_mips.h
@@ -20,6 +20,7 @@
 	int nr_serial_ports;
 	struct ssb_serial_port serial_ports[4];
 
+	int flash_buswidth;
 	u32 flash_window;
 	u32 flash_window_size;
 };

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
