From: Alex Chiang <achiang@hp.com>
Subject: [PATCH] atlx: move modinfo data from atlx.h to atl1.c
Date: Tue, 26 May 2009 16:33:50 -0600
Message-ID: <20090526223350.GJ19049@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jcliburn@gmail.com, scott.scriven@hp.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:17360 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbZEZWdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 18:33:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both atl1.c and atl2.c include atlx.h, which defines some modinfo
stuff. But atl2.c seems like it doesn't want the modinfo data
from atlx.h, as it defines its own.

Running modinfo on atl2.ko, we get conflicting information:

$ /sbin/modinfo drivers/net/atlx/atl2.ko | egrep "version|description|author"
version:        2.2.3
description:    Atheros Fast Ethernet Network Driver
author:         Atheros Corporation <xiong.huang@atheros.com>, Chris Snook <csnook@redhat.com>
version:        2.1.3
author:         Xiong Huang <xiong.huang@atheros.com>, 	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>

Move the modinfo data out of atlx.h and into atl1.c to eliminate
the confusion:

$ /sbin/modinfo drivers/net/atlx/atl1.ko | egrep "version|description|author"
version:        2.1.3
author:         Xiong Huang <xiong.huang@atheros.com>, 	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>
description:    Atheros L1 Gigabit Ethernet Driver

$ /sbin/modinfo drivers/net/atlx/atl2.ko | egrep "version|description|author"
version:        2.2.3
description:    Atheros Fast Ethernet Network Driver
author:         Atheros Corporation <xiong.huang@atheros.com>, Chris Snook <csnook@redhat.com>

Cc: Jay Cliburn <jcliburn@gmail.com>
Reported-by: Scott Scriven <scott.scriven@hp.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---
 atl1.c |    6 ++++++
 atlx.h |    6 ------
 2 files changed, 6 insertions(+), 6 deletions(-)
---
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 13f0bdc..152852f 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -82,6 +82,12 @@
 
 #include "atl1.h"
 
+#define ATLX_DRIVER_VERSION "2.1.3"
+MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
+	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(ATLX_DRIVER_VERSION);
+
 /* Temporary hack for merging atl1 and atl2 */
 #include "atlx.c"
 
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
index 297a03d..14054b7 100644
--- a/drivers/net/atlx/atlx.h
+++ b/drivers/net/atlx/atlx.h
@@ -29,12 +29,6 @@
 #include <linux/module.h>
 #include <linux/types.h>
 
-#define ATLX_DRIVER_VERSION "2.1.3"
-MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
-	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(ATLX_DRIVER_VERSION);
-
 #define ATLX_ERR_PHY			2
 #define ATLX_ERR_PHY_SPEED		7
 #define ATLX_ERR_PHY_RES		8
