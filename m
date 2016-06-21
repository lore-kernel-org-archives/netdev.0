From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: move driver in its own folder
Date: Tue, 21 Jun 2016 12:28:19 -0400
Message-ID: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the upcoming support for cross-chip operations and other mv88e6xxx
enhancements, new files will be added.

Similarly to mlxsw or b53, move mv88e6xxx files into their own folder.

In the meantime, update the MAINTAINERS entry to please checkpatch.pl,
by replacing the invalid 88E6352 entry with 88E6XXX, maintained by
Andrew and myself.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 MAINTAINERS                                 | 11 ++++++-----
 drivers/net/dsa/Kconfig                     | 10 ++--------
 drivers/net/dsa/Makefile                    |  2 +-
 drivers/net/dsa/mv88e6xxx/Kconfig           |  7 +++++++
 drivers/net/dsa/mv88e6xxx/Makefile          |  1 +
 drivers/net/dsa/{ => mv88e6xxx}/mv88e6xxx.c |  3 ++-
 drivers/net/dsa/{ => mv88e6xxx}/mv88e6xxx.h |  3 ++-
 7 files changed, 21 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/Kconfig
 create mode 100644 drivers/net/dsa/mv88e6xxx/Makefile
 rename drivers/net/dsa/{ => mv88e6xxx}/mv88e6xxx.c (99%)
 rename drivers/net/dsa/{ => mv88e6xxx}/mv88e6xxx.h (99%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 50f69ba7..2b27168 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7172,6 +7172,12 @@ W:	http://www.kernel.org/doc/man-pages
 L:	linux-man@vger.kernel.org
 S:	Maintained
 
+MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER
+M:	Andrew Lunn <andrew@lunn.ch>
+M:	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+S:	Maintained
+F:	drivers/net/dsa/mv88e6xxx/
+
 MARVELL ARMADA DRM SUPPORT
 M:	Russell King <rmk+kernel@armlinux.org.uk>
 S:	Maintained
@@ -7179,11 +7185,6 @@ F:	drivers/gpu/drm/armada/
 F:	include/uapi/drm/armada_drm.h
 F:	Documentation/devicetree/bindings/display/armada/
 
-MARVELL 88E6352 DSA support
-M:	Guenter Roeck <linux@roeck-us.net>
-S:	Maintained
-F:	drivers/net/dsa/mv88e6352.c
-
 MARVELL CRYPTO DRIVER
 M:	Boris Brezillon <boris.brezillon@free-electrons.com>
 M:	Arnaud Ebalard <arno@natisbad.org>
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index be481e1..8f45443 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -9,14 +9,6 @@ config NET_DSA_MV88E6060
 	  This enables support for the Marvell 88E6060 ethernet switch
 	  chip.
 
-config NET_DSA_MV88E6XXX
-	tristate "Marvell 88E6xxx Ethernet switch chip support"
-	depends on NET_DSA
-	select NET_DSA_TAG_EDSA
-	---help---
-	  This enables support for most of the Marvell 88E6xxx models of
-	  Ethernet switch chips, except 88E6060.
-
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
 	depends on HAS_IOMEM && NET_DSA
@@ -30,4 +22,6 @@ config NET_DSA_BCM_SF2
 
 source "drivers/net/dsa/b53/Kconfig"
 
+source "drivers/net/dsa/mv88e6xxx/Kconfig"
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index 97bc70a..ca1e71b 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
 
 obj-y				+= b53/
+obj-y				+= mv88e6xxx/
diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
new file mode 100644
index 0000000..490bc06
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/Kconfig
@@ -0,0 +1,7 @@
+config NET_DSA_MV88E6XXX
+	tristate "Marvell 88E6xxx Ethernet switch fabric support"
+	depends on NET_DSA
+	select NET_DSA_TAG_EDSA
+	help
+	  This driver adds support for most of the Marvell 88E6xxx models of
+	  Ethernet switch chips, except 88E6060.
diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
new file mode 100644
index 0000000..1128fc7
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.c
similarity index 99%
rename from drivers/net/dsa/mv88e6xxx.c
rename to drivers/net/dsa/mv88e6xxx/mv88e6xxx.c
index 9b116d8..2073f7b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.c
@@ -1,5 +1,6 @@
 /*
- * net/dsa/mv88e6xxx.c - Marvell 88e6xxx switch chip support
+ * Marvell 88e6xxx Ethernet switch single-chip support
+ *
  * Copyright (c) 2008 Marvell Semiconductor
  *
  * Copyright (c) 2015 CMC Electronics, Inc.
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
similarity index 99%
rename from drivers/net/dsa/mv88e6xxx.h
rename to drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a94acd8..856c6e5 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -1,5 +1,6 @@
 /*
- * net/dsa/mv88e6xxx.h - Marvell 88e6xxx switch chip support
+ * Marvell 88e6xxx common definitions
+ *
  * Copyright (c) 2008 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
-- 
2.9.0
