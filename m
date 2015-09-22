From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 18/33] arcnet: Move files out of include/linux
Date: Tue, 22 Sep 2015 11:01:59 +0200
Message-ID: <1442912534-10821-19-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35430 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932626AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

These #include files don't need to be in the include/linux directory
as they can be local to drivers/net/arcnet/

Move them and update the #include statements.

Update the MAINTAINERS file pattern by deleting arcdevice from the
NETWORKING block as arcnet is currently unmaintained.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 MAINTAINERS                                       | 1 -
 drivers/net/arcnet/arc-rawmode.c                  | 3 ++-
 drivers/net/arcnet/arc-rimi.c                     | 3 ++-
 {include/linux => drivers/net/arcnet}/arcdevice.h | 0
 drivers/net/arcnet/arcnet.c                       | 3 ++-
 drivers/net/arcnet/capmode.c                      | 3 ++-
 drivers/net/arcnet/com20020-isa.c                 | 6 +++---
 drivers/net/arcnet/com20020-pci.c                 | 6 +++---
 drivers/net/arcnet/com20020.c                     | 6 +++---
 {include/linux => drivers/net/arcnet}/com20020.h  | 0
 drivers/net/arcnet/com20020_cs.c                  | 7 +++----
 drivers/net/arcnet/com90io.c                      | 3 ++-
 drivers/net/arcnet/com90xx.c                      | 3 ++-
 drivers/net/arcnet/rfc1051.c                      | 3 ++-
 drivers/net/arcnet/rfc1201.c                      | 3 ++-
 15 files changed, 28 insertions(+), 22 deletions(-)
 rename {include/linux => drivers/net/arcnet}/arcdevice.h (100%)
 rename {include/linux => drivers/net/arcnet}/com20020.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 274f854..2705240 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7300,7 +7300,6 @@ S:	Odd Fixes
 F:	drivers/net/
 F:	include/linux/if_*
 F:	include/linux/netdevice.h
-F:	include/linux/arcdevice.h
 F:	include/linux/etherdevice.h
 F:	include/linux/fcdevice.h
 F:	include/linux/fddidevice.h
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 59b3083..35a747a 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -33,7 +33,8 @@
 #include <net/arp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 8fa5eb4..37406ff 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -37,7 +37,8 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 /* Internal function declarations */
 
diff --git a/include/linux/arcdevice.h b/drivers/net/arcnet/arcdevice.h
similarity index 100%
rename from include/linux/arcdevice.h
rename to drivers/net/arcnet/arcdevice.h
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 00074e7..c8423ee 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -50,9 +50,10 @@
 #include <linux/if_arp.h>
 #include <net/arp.h>
 #include <linux/init.h>
-#include <linux/arcdevice.h>
 #include <linux/jiffies.h>
 
+#include "arcdevice.h"
+
 /* "do nothing" functions for protocol drivers */
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length);
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 46a76dc..2f2d0d9 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -35,7 +35,8 @@
 #include <net/arp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 352500b..ab5202b 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -39,11 +39,11 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/bootmem.h>
-#include <linux/arcdevice.h>
-#include <linux/com20020.h>
-
 #include <linux/io.h>
 
+#include "arcdevice.h"
+#include "com20020.h"
+
 /* We cannot (yet) probe for an IO mapped card, although we can check that
  * it's where we were told it was, and even do autoirq.
  */
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index a28887d..1a75a69 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -39,12 +39,12 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/arcdevice.h>
-#include <linux/com20020.h>
 #include <linux/list.h>
-
 #include <linux/io.h>
 
+#include "arcdevice.h"
+#include "com20020.h"
+
 /* Module parameters */
 
 static int node;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 00f910c..f46e220 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -37,11 +37,11 @@
 #include <linux/netdevice.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
-#include <linux/arcdevice.h>
-#include <linux/com20020.h>
-
 #include <linux/io.h>
 
+#include "arcdevice.h"
+#include "com20020.h"
+
 static char *clockrates[] = {
 	"XXXXXXX", "XXXXXXXX", "XXXXXX",
 	"2.5 Mb/s", "1.25Mb/s", "625 Kb/s", "312.5 Kb/s",
diff --git a/include/linux/com20020.h b/drivers/net/arcnet/com20020.h
similarity index 100%
rename from include/linux/com20020.h
rename to drivers/net/arcnet/com20020.h
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 8541694..5fdde69 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -42,13 +42,12 @@
 #include <linux/delay.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/arcdevice.h>
-#include <linux/com20020.h>
-
+#include <linux/io.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ds.h>
 
-#include <linux/io.h>
+#include "arcdevice.h"
+#include "com20020.h"
 
 static void regdump(struct net_device *dev)
 {
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 9e779a53..ce15d191 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -38,7 +38,8 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 /* Internal function declarations */
 
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 62100ac..b672795 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -36,7 +36,8 @@
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <linux/io.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 /* Define this to speed up the autoprobe by assuming if only one io port and
  * shmem are left in the list at Stage 5, they must correspond to each
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 691bee5..4b1a754 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -33,7 +33,8 @@
 #include <net/arp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev);
 static void rx(struct net_device *dev, int bufnum,
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index aaa1966..566da5e 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -32,7 +32,8 @@
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/arcdevice.h>
+
+#include "arcdevice.h"
 
 MODULE_LICENSE("GPL");
 
-- 
2.5.1
