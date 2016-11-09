From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v9 6/8] thunderbolt: Kconfig for Thunderbolt Networking
Date: Wed,  9 Nov 2016 16:20:06 +0200
Message-ID: <1478701208-4585-7-git-send-email-amir.jer.levy@intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
