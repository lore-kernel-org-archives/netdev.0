From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 13/29] LMC: Get rid of debug.[ch].
Date: Sat, 31 Jul 2010 17:05:36 +0200
Message-ID: <1280588752-9340-13-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57893 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525Ab0GaPGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:18 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/Makefile |    2 +-
 drivers/net/wan/lmc/debug.c  |   23 -----------------------
 drivers/net/wan/lmc/debug.h  |    6 ------
 drivers/net/wan/lmc/lmc.h    |   18 ------------------
 drivers/net/wan/lmc/main.c   |    1 -
 drivers/net/wan/lmc/media.c  |    1 -
 drivers/net/wan/lmc/var.h    |   38 ++++++++++++++++++++++++++++++++++=
++++
 7 files changed, 39 insertions(+), 50 deletions(-)
 delete mode 100644 drivers/net/wan/lmc/debug.c
 delete mode 100644 drivers/net/wan/lmc/debug.h

diff --git a/drivers/net/wan/lmc/Makefile b/drivers/net/wan/lmc/Makefil=
e
index 2f461a7..6c21b7c 100644
--- a/drivers/net/wan/lmc/Makefile
+++ b/drivers/net/wan/lmc/Makefile
@@ -5,7 +5,7 @@
=20
 obj-$(CONFIG_LANMEDIA) +=3D lmc.o
=20
-lmc-objs :=3D debug.o media.o main.o
+lmc-objs :=3D media.o main.o
=20
 # Like above except every packet gets echoed to KERN_DEBUG
 # in hex
diff --git a/drivers/net/wan/lmc/debug.c b/drivers/net/wan/lmc/debug.c
deleted file mode 100644
index 7c05cfe..0000000
--- a/drivers/net/wan/lmc/debug.c
+++ /dev/null
@@ -1,23 +0,0 @@
-#include <linux/types.h>
-#include <linux/netdevice.h>
-#include <linux/interrupt.h>
-#include "debug.h"
-
-void lmc_trace(struct net_device *dev, char *msg)
-{
-#ifdef LMC_TRACE
-	unsigned long j =3D jiffies + 3; /* Wait for 50 ms */
-
-	if (in_interrupt()) {
-		printk(KERN_DEBUG "%s: * %s\n", dev->name, msg);
-#if 0
-		while (time_before(jiffies, j + 10))
-			;
-#endif
-	} else {
-		printk(KERN_DEBUG "%s: %s\n", dev->name, msg);
-		while (time_before(jiffies, j))
-			schedule();
-	}
-#endif
-}
diff --git a/drivers/net/wan/lmc/debug.h b/drivers/net/wan/lmc/debug.h
deleted file mode 100644
index f026077..0000000
--- a/drivers/net/wan/lmc/debug.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _LMC_DEBUG_H_
-#define _LMC_DEBUG_H_
-
-void lmc_trace(struct net_device *dev, char *msg);
-
-#endif
diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index 4ab8fe8..5f467d1 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -3,22 +3,4 @@
=20
 #include "var.h"
=20
-int lmc_probe(struct net_device *dev);
-unsigned lmc_mii_readreg(struct card * const sc, unsigned devaddr,
-			 unsigned regno);
-void lmc_mii_writereg(struct card * const sc, unsigned devaddr,
-		      unsigned regno, unsigned data);
-void lmc_led_on(struct card * const, u32);
-void lmc_led_off(struct card * const, u32);
-unsigned lmc_mii_readreg(struct card * const, unsigned, unsigned);
-void lmc_mii_writereg(struct card * const, unsigned, unsigned, unsigne=
d);
-void lmc_gpio_mkinput(struct card * const sc, u32 bits);
-void lmc_gpio_mkoutput(struct card * const sc, u32 bits);
-int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-
-extern struct media lmc_ds3_media;
-extern struct media lmc_ssi_media;
-extern struct media lmc_t1_media;
-extern struct media lmc_hssi_media;
-
 #endif
diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index dc7e435..c80131f 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -73,7 +73,6 @@
 #include "lmc.h"
 #include "var.h"
 #include "ioctl.h"
-#include "debug.h"
=20
 static int LMC_PKT_BUF_SZ =3D 1542;
=20
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 2411214..9b1c394 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -19,7 +19,6 @@
 #include "lmc.h"
 #include "var.h"
 #include "ioctl.h"
-#include "debug.h"
=20
 #define CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE 1
=20
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index b889bf6..d694731 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -433,4 +433,42 @@ struct card {
 #define LMC_CRC_LEN_16		2	/* 16-bit CRC */
 #define LMC_CRC_LEN_32		4
=20
+extern struct media lmc_ds3_media;
+extern struct media lmc_ssi_media;
+extern struct media lmc_t1_media;
+extern struct media lmc_hssi_media;
+
+static inline void lmc_trace(struct net_device *dev, char *msg)
+{
+#ifdef LMC_TRACE
+	unsigned long j =3D jiffies + 3; /* Wait for 50 ms */
+
+	if (in_interrupt()) {
+		printk(KERN_DEBUG "%s: * %s\n", dev->name, msg);
+#if 0
+		while (time_before(jiffies, j + 10))
+			;
+#endif
+	} else {
+		printk(KERN_DEBUG "%s: %s\n", dev->name, msg);
+		while (time_before(jiffies, j))
+			schedule();
+	}
+#endif
+}
+
+
+int lmc_probe(struct net_device *dev);
+unsigned lmc_mii_readreg(struct card * const sc, unsigned devaddr,
+			 unsigned regno);
+void lmc_mii_writereg(struct card * const sc, unsigned devaddr,
+		      unsigned regno, unsigned data);
+void lmc_led_on(struct card * const, u32);
+void lmc_led_off(struct card * const, u32);
+unsigned lmc_mii_readreg(struct card * const, unsigned, unsigned);
+void lmc_mii_writereg(struct card * const, unsigned, unsigned, unsigne=
d);
+void lmc_gpio_mkinput(struct card * const sc, u32 bits);
+void lmc_gpio_mkoutput(struct card * const sc, u32 bits);
+int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
+
 #endif /* _LMC_VAR_H_ */
--=20
1.7.1.1

