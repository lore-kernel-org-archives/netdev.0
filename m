From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Vlan convert stubs to no-ops
Date: Mon, 28 Jul 2003 15:21:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728152114.02a10f4e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux 802.1Q VLAN" <vlan@wanfear.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When building without /proc, the interfaces can be converted to no-ops
(very minor code savings).

Patch for 2.6.0-test2
diff -Nru a/net/8021q/Makefile b/net/8021q/Makefile
--- a/net/8021q/Makefile	Mon Jul 28 15:05:58 2003
+++ b/net/8021q/Makefile	Mon Jul 28 15:05:58 2003
@@ -4,4 +4,9 @@
 
 obj-$(CONFIG_VLAN_8021Q) += 8021q.o
 
-8021q-objs := vlan.o vlanproc.o vlan_dev.o
+8021q-objs := vlan.o vlan_dev.o
+
+ifeq ($(CONFIG_PROC_FS),y)
+8021q-objs += vlanproc.o
+endif
+
diff -Nru a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
--- a/net/8021q/vlanproc.c	Mon Jul 28 15:05:58 2003
+++ b/net/8021q/vlanproc.c	Mon Jul 28 15:05:58 2003
@@ -38,8 +38,6 @@
 
 /****** Function Prototypes *************************************************/
 
-#ifdef CONFIG_PROC_FS
-
 /* Proc filesystem interface */
 static ssize_t vlan_proc_read(struct file *file, char *buf, size_t count,
                               loff_t *ppos);
@@ -438,32 +436,3 @@
 
 	return cnt;
 }
-
-#else /* No CONFIG_PROC_FS */
-
-/*
- *	No /proc - output stubs
- */
- 
-int __init vlan_proc_init (void)
-{
-	return 0;
-}
-
-void vlan_proc_cleanup(void)
-{
-	return;
-}
-
-
-int vlan_proc_add_dev(struct net_device *vlandev)
-{
-	return 0;
-}
-
-int vlan_proc_rem_dev(struct net_device *vlandev)
-{
-	return 0;
-}
-
-#endif /* No CONFIG_PROC_FS */
diff -Nru a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
--- a/net/8021q/vlanproc.h	Mon Jul 28 15:05:58 2003
+++ b/net/8021q/vlanproc.h	Mon Jul 28 15:05:58 2003
@@ -1,6 +1,7 @@
 #ifndef __BEN_VLAN_PROC_INC__
 #define __BEN_VLAN_PROC_INC__
 
+#ifdef CONFIG_PROC_FS
 int vlan_proc_init(void);
 
 int vlan_proc_rem_dev(struct net_device *vlandev);
@@ -8,5 +9,14 @@
 void vlan_proc_cleanup (void);
 
 #define	VLAN_PROC_BUFSZ	(4096)	/* buffer size for printing proc info */
+
+#else /* No CONFIG_PROC_FS */
+
+#define vlan_proc_init()	(0)
+#define vlan_proc_cleanup()	do {} while(0)
+#define vlan_proc_add_dev(dev)	((void)(dev), 0)
+#define vlan_proc_rem_dev(dev)	((void)(dev), 0)
+
+#endif
 
 #endif /* !(__BEN_VLAN_PROC_INC__) */
