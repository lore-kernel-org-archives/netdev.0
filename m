From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v8 6/8] thunderbolt: Kconfig for Thunderbolt Networking
Date: Wed, 28 Sep 2016 17:44:28 +0300
Message-ID: <1475073870-2126-7-git-send-email-amir.jer.levy@intel.com>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:17211 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932916AbcI1OsA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 10:48:00 -0400
In-Reply-To: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to the Kconfig Thunderbolt description to add
Thunderbolt networking as an option.
The menu item "Thunderbolt support" now offers:
"Apple Hardware Support" (existing)
        and/or
"Thunderbolt Networking" (new)

You can choose the driver for your platform or build both drivers -
each driver will detect if it can run on the specific platform.
If the Thunderbolt Networking option is chosen, Thunderbolt Networking
will be enabled between Linux non-Apple systems, macOS and
Windows based systems.
Thunderbolt Networking will not affect any other Thunderbolt feature that
was previous available to Linux users on either Apple or
non-Apple platforms.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 drivers/thunderbolt/Kconfig  | 27 +++++++++++++++++++++++----
 drivers/thunderbolt/Makefile |  3 ++-
 2 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/thunderbolt/Kconfig b/drivers/thunderbolt/Kconfig
index c121acc..376e5bb 100644
--- a/drivers/thunderbolt/Kconfig
+++ b/drivers/thunderbolt/Kconfig
@@ -1,13 +1,32 @@
-menuconfig THUNDERBOLT
-	tristate "Thunderbolt support for Apple devices"
+config THUNDERBOLT
+	tristate "Thunderbolt support"
 	depends on PCI
 	select CRC32
 	help
-	  Cactus Ridge Thunderbolt Controller driver
+	  Thunderbolt Controller driver
+
+if THUNDERBOLT
+
+config THUNDERBOLT_APPLE
+	tristate "Apple hardware support"
+	help
 	  This driver is required if you want to hotplug Thunderbolt devices on
 	  Apple hardware.
 
 	  Device chaining is currently not supported.
 
-	  To compile this driver a module, choose M here. The module will be
+	  To compile this driver as a module, choose M here. The module will be
 	  called thunderbolt.
+
+config THUNDERBOLT_ICM
+	tristate "Thunderbolt Networking"
+	help
+	  This driver is required if you want Thunderbolt Networking on
+	  non-Apple hardware.
+	  It creates a virtual Ethernet device that enables computer to
+	  computer communication over a Thunderbolt cable.
+
+	  To compile this driver as a module, choose M here. The module will be
+	  called thunderbolt_icm.
+
+endif
diff --git a/drivers/thunderbolt/Makefile b/drivers/thunderbolt/Makefile
index 5d1053c..b6aa6a3 100644
--- a/drivers/thunderbolt/Makefile
+++ b/drivers/thunderbolt/Makefile
@@ -1,3 +1,4 @@
-obj-${CONFIG_THUNDERBOLT} := thunderbolt.o
+obj-${CONFIG_THUNDERBOLT_APPLE} := thunderbolt.o
 thunderbolt-objs := nhi.o ctl.o tb.o switch.o cap.o path.o tunnel_pci.o eeprom.o
 
+obj-${CONFIG_THUNDERBOLT_ICM} += icm/
-- 
2.7.4
