From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/6][ATM]: remove bridge/lec interdependency
Date: Tue, 22 Mar 2005 19:54:14 -0500
Message-ID: <200503230054.j2N0sC52028366@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/22 08:39:37-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/core/dev.c
#   2005/03/22 08:39:19-05:00 chas@relax.cmf.nrl.navy.mil +6 -0
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/bridge/br_private.h
#   2005/03/22 08:39:18-05:00 chas@relax.cmf.nrl.navy.mil +6 -0
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/bridge/br.c
#   2005/03/22 08:39:18-05:00 chas@relax.cmf.nrl.navy.mil +1 -8
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.h
#   2005/03/22 08:39:18-05:00 chas@relax.cmf.nrl.navy.mil +0 -8
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.c
#   2005/03/22 08:39:18-05:00 chas@relax.cmf.nrl.navy.mil +1 -4
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/common.c
#   2005/03/22 08:39:18-05:00 chas@relax.cmf.nrl.navy.mil +0 -15
#   [ATM]: remove bridge/lec interdependency
#
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2005-03-22 19:50:34 -05:00
+++ b/net/atm/common.c	2005-03-22 19:50:34 -05:00
@@ -755,21 +755,6 @@
 	return vcc->dev->ops->getsockopt(vcc, level, optname, optval, len);
 }
 
-
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-struct net_bridge;
-struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
-						unsigned char *addr) = NULL;
-void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent) = NULL;
-#if defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_BRIDGE_MODULE)
-EXPORT_SYMBOL(br_fdb_get_hook);
-EXPORT_SYMBOL(br_fdb_put_hook);
-#endif /* defined(CONFIG_ATM_LANE_MODULE) || defined(CONFIG_BRIDGE_MODULE) */
-#endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
-#endif /* defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE) */
-
-
 static int __init atm_init(void)
 {
 	int error;
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	2005-03-22 19:50:34 -05:00
+++ b/net/atm/lec.c	2005-03-22 19:50:34 -05:00
@@ -37,11 +37,8 @@
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 #include <linux/if_bridge.h>
 #include "../bridge/br_private.h"
-static unsigned char bridge_ula_lec[] = {0x01, 0x80, 0xc2, 0x00, 0x00};
 
-extern struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
-       unsigned char *addr);
-extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
+static unsigned char bridge_ula_lec[] = {0x01, 0x80, 0xc2, 0x00, 0x00};
 #endif
 
 /* Modular too */
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	2005-03-22 19:50:34 -05:00
+++ b/net/atm/lec.h	2005-03-22 19:50:34 -05:00
@@ -14,14 +14,6 @@
 #include <linux/netdevice.h>
 #include <linux/atmlec.h>
 
-#if defined (CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-#include <linux/if_bridge.h>
-struct net_bridge;
-extern struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
-                                                unsigned char *addr);
-extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
-#endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
-
 #define LEC_HEADER_LEN 16
 
 struct lecdatahdr_8023 {
diff -Nru a/net/bridge/br.c b/net/bridge/br.c
--- a/net/bridge/br.c	2005-03-22 19:50:34 -05:00
+++ b/net/bridge/br.c	2005-03-22 19:50:34 -05:00
@@ -22,10 +22,6 @@
 
 #include "br_private.h"
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-#include "../atm/lec.h"
-#endif
-
 int (*br_should_route_hook) (struct sk_buff **pskb) = NULL;
 
 static int __init br_init(void)
@@ -39,10 +35,9 @@
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	br_fdb_get_hook = br_fdb_get;
 	br_fdb_put_hook = br_fdb_put;
-#endif
+
 	register_netdevice_notifier(&br_device_notifier);
 
 	return 0;
@@ -60,10 +55,8 @@
 
 	synchronize_net();
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	br_fdb_get_hook = NULL;
 	br_fdb_put_hook = NULL;
-#endif
 
 	br_handle_frame_hook = NULL;
 	br_fdb_fini();
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2005-03-22 19:50:34 -05:00
+++ b/net/bridge/br_private.h	2005-03-22 19:50:34 -05:00
@@ -216,6 +216,12 @@
 extern void br_stp_port_timer_init(struct net_bridge_port *p);
 extern unsigned long br_timer_value(const struct timer_list *timer);
 
+/* br.c */
+extern struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
+						       unsigned char *addr);
+extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
+
+
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
 extern int br_sysfs_addif(struct net_bridge_port *p);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2005-03-22 19:50:34 -05:00
+++ b/net/core/dev.c	2005-03-22 19:50:34 -05:00
@@ -1561,6 +1561,10 @@
 
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
 int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
+struct net_bridge;
+struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
+						unsigned char *addr);
+void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
 static __inline__ int handle_bridge(struct sk_buff **pskb,
 				    struct packet_type **pt_prev, int *ret)
@@ -3347,6 +3351,8 @@
 
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 EXPORT_SYMBOL(br_handle_frame_hook);
+EXPORT_SYMBOL(br_fdb_get_hook);
+EXPORT_SYMBOL(br_fdb_put_hook);
 #endif
 
 #ifdef CONFIG_KMOD
