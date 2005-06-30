From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 1/12] iseries_veth: Make error messages more user friendly, and add a debug macro
Date: Thu, 30 Jun 2005 20:20:39 +1000
Message-ID: <1120126839.106943.128468321759.qpatch__6719.7029399269$1120126796$gmane$org@concordia>
References: <200506302016.55125.michael@ellerman.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxppc64-dev@ozlabs.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
In-Reply-To: <200506302016.55125.michael@ellerman.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently the iseries_veth driver prints the file name and line number in its
error messages. This isn't very useful for most users, so just print
"iseries_veth: message" instead.

Also add a veth_debug() and veth_info() macro to replace the current
veth_printk().


---

 drivers/net/iseries_veth.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

Index: veth-dev/drivers/net/iseries_veth.c
===================================================================
--- veth-dev.orig/drivers/net/iseries_veth.c
+++ veth-dev/drivers/net/iseries_veth.c
@@ -79,6 +79,8 @@
 #include <asm/iommu.h>
 #include <asm/vio.h>
 
+#define DEBUG	1
+
 #include "iseries_veth.h"
 
 MODULE_AUTHOR("Kyle Lucke <klucke@us.ibm.com>");
@@ -176,11 +178,18 @@ static void veth_timed_ack(unsigned long
  * Utility functions
  */
 
-#define veth_printk(prio, fmt, args...) \
-	printk(prio "%s: " fmt, __FILE__, ## args)
+#define veth_info(fmt, args...) \
+	printk(KERN_INFO "iseries_veth: " fmt, ## args)
 
 #define veth_error(fmt, args...) \
-	printk(KERN_ERR "(%s:%3.3d) ERROR: " fmt, __FILE__, __LINE__ , ## args)
+	printk(KERN_ERR "iseries_veth: Error: " fmt, ## args)
+
+#ifdef DEBUG
+#define veth_debug(fmt, args...) \
+	printk(KERN_DEBUG "iseries_veth: " fmt, ## args)
+#else
+#define veth_debug(fmt, args...) do {} while (0)
+#endif
 
 static inline void veth_stack_push(struct veth_lpar_connection *cnx,
 				   struct veth_msg *msg)
