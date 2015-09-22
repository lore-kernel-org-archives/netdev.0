From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 28/33] arcnet: Add com9026.h to standardize COM9026_REG_<foo>
Date: Tue, 22 Sep 2015 11:02:09 +0200
Message-ID: <1442912534-10821-29-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60184 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Deduplicate the COM9026 registers.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c | 13 +------------
 drivers/net/arcnet/arcnet.c   |  1 +
 drivers/net/arcnet/com9026.h  | 17 +++++++++++++++++
 drivers/net/arcnet/com90io.c  | 11 +----------
 drivers/net/arcnet/com90xx.c  | 13 +------------
 5 files changed, 21 insertions(+), 34 deletions(-)
 create mode 100644 drivers/net/arcnet/com9026.h

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 4c35a7e..a07e249 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -39,6 +39,7 @@
 #include <linux/io.h>
 
 #include "arcdevice.h"
+#include "com9026.h"
 
 /* Internal function declarations */
 
@@ -59,18 +60,6 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum,
 #define BUFFER_SIZE	(512)
 #define MIRROR_SIZE	(BUFFER_SIZE * 4)
 
-/* COM 9026 controller chip --> ARCnet register addresses */
-#define COM9026_REG_W_INTMASK	0	/* writable */
-#define COM9026_REG_R_STATUS	0	/* readable */
-#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
-#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
-#define COM9026_REG_R_RESET	8	/* software reset (on read) */
-#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
-#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
-#define COM9026_REG_W_ADDR_HI	15
-
-#define COM9026_REG_R_STATION	1	/* Station ID */
-
 /* We cannot probe for a RIM I card; one reason is I don't know how to reset
  * them.  In fact, we can't even get their node ID automatically.  So, we
  * need to be passed a specific shmem address, IRQ, and node ID.
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bcfdd91..2158e98 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -53,6 +53,7 @@
 #include <linux/jiffies.h>
 
 #include "arcdevice.h"
+#include "com9026.h"
 
 /* "do nothing" functions for protocol drivers */
 static void null_rx(struct net_device *dev, int bufnum,
diff --git a/drivers/net/arcnet/com9026.h b/drivers/net/arcnet/com9026.h
new file mode 100644
index 0000000..efcaf67
--- /dev/null
+++ b/drivers/net/arcnet/com9026.h
@@ -0,0 +1,17 @@
+#ifndef __COM9026_H
+#define __COM9026_H
+
+/* COM 9026 controller chip --> ARCnet register addresses */
+
+#define COM9026_REG_W_INTMASK	0	/* writable */
+#define COM9026_REG_R_STATUS	0	/* readable */
+#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
+#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
+#define COM9026_REG_R_RESET	8	/* software reset (on read) */
+#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
+#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
+#define COM9026_REG_W_ADDR_HI	15
+
+#define COM9026_REG_R_STATION	1	/* Station ID */
+
+#endif
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 7e084f1..b57863d 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -40,6 +40,7 @@
 #include <linux/io.h>
 
 #include "arcdevice.h"
+#include "com9026.h"
 
 /* Internal function declarations */
 
@@ -58,16 +59,6 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum,
 /* The number of low I/O ports used by the card. */
 #define ARCNET_TOTAL_SIZE 16
 
-/* COM 9026 controller chip --> ARCnet register addresses */
-#define COM9026_REG_W_INTMASK	0	/* writable */
-#define COM9026_REG_R_STATUS	0	/* readable */
-#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
-#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
-#define COM9026_REG_R_RESET	8	/* software reset (on read) */
-#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
-#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
-#define COM9026_REG_W_ADDR_HI	15
-
 /****************************************************************************
  *                                                                          *
  * IO-mapped operation routines                                             *
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index a97d086..0d9b45f 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -38,6 +38,7 @@
 #include <linux/io.h>
 
 #include "arcdevice.h"
+#include "com9026.h"
 
 /* Define this to speed up the autoprobe by assuming if only one io port and
  * shmem are left in the list at Stage 5, they must correspond to each
@@ -78,18 +79,6 @@ static int numcards;
 #define BUFFER_SIZE (512)
 #define MIRROR_SIZE (BUFFER_SIZE * 4)
 
-/* COM 9026 controller chip --> ARCnet register addresses */
-#define COM9026_REG_W_INTMASK	0	/* writable */
-#define COM9026_REG_R_STATUS	0	/* readable */
-#define COM9026_REG_W_COMMAND	1	/* writable, returns random vals on read (?) */
-#define COM9026_REG_RW_CONFIG	2	/* Configuration register */
-#define COM9026_REG_R_RESET	8	/* software reset (on read) */
-#define COM9026_REG_RW_MEMDATA	12	/* Data port for IO-mapped memory */
-#define COM9026_REG_W_ADDR_LO	14	/* Control registers for said */
-#define COM9026_REG_W_ADDR_HI	15
-
-#define COM9026_REG_R_STATION	1	/* Station ID */
-
 static int com90xx_skip_probe __initdata = 0;
 
 /* Module parameters */
-- 
2.5.1
