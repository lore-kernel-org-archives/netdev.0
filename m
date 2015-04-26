From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/bonding: Make DRV macros private
Date: Sun, 26 Apr 2015 15:55:57 +0300
Message-ID: <1430052957-7345-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:40925 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751829AbbDZM4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2015 08:56:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The bonding modules currently defines four macros with
general names that pollute the global namespace:
DRV_VERSION
DRV_RELDATE
DRV_NAME
DRV_DESCRIPTION

Fixing that by defining a private bonding_priv.h
header files which includes those defines.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Hi Dave,

We've been hitting this small issue when working on 
rdma-next (4.2) features to the IB driver, so just 
to avoid unnecessary deps sending it as fix for 4.1-rc1

Matan used the somehow old header for the new file, hope
this is OK, and if not, we'll change...

Or.

 drivers/net/bonding/bond_main.c    |    2 ++
 drivers/net/bonding/bond_procfs.c  |    1 +
 drivers/net/bonding/bonding_priv.h |   25 +++++++++++++++++++++++++
 include/net/bonding.h              |    7 -------
 4 files changed, 28 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/bonding/bonding_priv.h

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 78dde56..3a10551 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -82,6 +82,8 @@
 #include <net/bond_3ad.h>
 #include <net/bond_alb.h>
 
+#include "bonding_priv.h"
+
 /*---------------------------- Module parameters ----------------------------*/
 
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 62694cf..b20b35a 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -4,6 +4,7 @@
 #include <net/netns/generic.h>
 #include <net/bonding.h>
 
+#include "bonding_priv.h"
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
diff --git a/drivers/net/bonding/bonding_priv.h b/drivers/net/bonding/bonding_priv.h
new file mode 100644
index 0000000..5a4d81a
--- /dev/null
+++ b/drivers/net/bonding/bonding_priv.h
@@ -0,0 +1,25 @@
+/*
+ * Bond several ethernet interfaces into a Cisco, running 'Etherchannel'.
+ *
+ * Portions are (c) Copyright 1995 Simon "Guru Aleph-Null" Janes
+ * NCM: Network and Communications Management, Inc.
+ *
+ * BUT, I'm the one who modified it for ethernet, so:
+ * (c) Copyright 1999, Thomas Davis, tadavis@lbl.gov
+ *
+ *	This software may be used and distributed according to the terms
+ *	of the GNU Public License, incorporated herein by reference.
+ *
+ */
+
+#ifndef _BONDING_PRIV_H
+#define _BONDING_PRIV_H
+
+#define DRV_VERSION	"3.7.1"
+#define DRV_RELDATE	"April 27, 2011"
+#define DRV_NAME	"bonding"
+#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
+
+#define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
+
+#endif
diff --git a/include/net/bonding.h b/include/net/bonding.h
index fda6fee..78ed135 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -30,13 +30,6 @@
 #include <net/bond_alb.h>
 #include <net/bond_options.h>
 
-#define DRV_VERSION	"3.7.1"
-#define DRV_RELDATE	"April 27, 2011"
-#define DRV_NAME	"bonding"
-#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
-
-#define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
-
 #define BOND_MAX_ARP_TARGETS	16
 
 #define BOND_DEFAULT_MIIMON	100
-- 
1.7.1
