From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 01/11] net: dsa: mv88e6xxx: add port files
Date: Fri,  4 Nov 2016 03:23:26 +0100
Message-ID: <20161104022336.14273-2-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell switches contains one internal SMI device per port, called
"Port Registers". Depending on the model, the addresses of these devices
start from 0x0, 0x8 or 0x10.

Start moving Port Registers specific code to their own files.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c   | 17 +----------------
 drivers/net/dsa/mv88e6xxx/port.c   | 31 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h   | 24 ++++++++++++++++++++++++
 4 files changed, 57 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/port.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/port.h

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 10ce820..c36be31 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
 mv88e6xxx-objs += global1.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
+mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 72b9dac2..b32b242 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -37,6 +37,7 @@
 #include "mv88e6xxx.h"
 #include "global1.h"
 #include "global2.h"
+#include "port.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
 {
@@ -221,22 +222,6 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
-static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
-			       u16 *val)
-{
-	int addr = chip->info->port_base_addr + port;
-
-	return mv88e6xxx_read(chip, addr, reg, val);
-}
-
-static int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
-				u16 val)
-{
-	int addr = chip->info->port_base_addr + port;
-
-	return mv88e6xxx_write(chip, addr, reg, val);
-}
-
 static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 			      int reg, u16 *val)
 {
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
new file mode 100644
index 0000000..3b36c92
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -0,0 +1,31 @@
+/*
+ * Marvell 88E6xxx Switch Port Registers support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "mv88e6xxx.h"
+#include "port.h"
+
+int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
+			u16 *val)
+{
+	int addr = chip->info->port_base_addr + port;
+
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
+int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
+			 u16 val)
+{
+	int addr = chip->info->port_base_addr + port;
+
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
new file mode 100644
index 0000000..ae1ae2b
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -0,0 +1,24 @@
+/*
+ * Marvell 88E6xxx Switch Port Registers support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _MV88E6XXX_PORT_H
+#define _MV88E6XXX_PORT_H
+
+#include "mv88e6xxx.h"
+
+int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
+			u16 *val);
+int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
+			 u16 val);
+
+#endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
