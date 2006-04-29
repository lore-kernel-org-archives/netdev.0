From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Move AX.25 symbol exports
Date: Sat, 29 Apr 2006 14:40:23 +0100
Message-ID: <20060429134023.GA32158@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133570AbWD2Sss (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:48:48 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move AX.25 symbol exports to next to their definitions where they're
supposed to be these days.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/ax25/af_ax25.c    |   20 ++------------------
 net/ax25/ax25_addr.c  |    9 +++++++++
 net/ax25/ax25_iface.c |   13 +++++++++++++
 net/ax25/ax25_ip.c    |    3 +++
 net/ax25/ax25_out.c   |    3 +++
 net/ax25/ax25_timer.c |    3 +++
 net/ax25/ax25_uid.c   |    4 ++++
 7 files changed, 37 insertions(+), 18 deletions(-)

Index: linux-net.git/net/ax25/af_ax25.c
===================================================================
--- linux-net.git.orig/net/ax25/af_ax25.c	2006-04-29 01:54:20.000000000 +0100
+++ linux-net.git/net/ax25/af_ax25.c	2006-04-29 11:30:24.000000000 +0100
@@ -228,6 +228,8 @@ ax25_cb *ax25_find_cb(ax25_address *src_
 	return NULL;
 }
 
+EXPORT_SYMBOL(ax25_find_cb);
+
 void ax25_send_to_raw(ax25_address *addr, struct sk_buff *skb, int proto)
 {
 	ax25_cb *s;
@@ -1979,24 +1981,6 @@ static struct notifier_block ax25_dev_no
 	.notifier_call =ax25_device_event,
 };
 
-EXPORT_SYMBOL(ax25_hard_header);
-EXPORT_SYMBOL(ax25_rebuild_header);
-EXPORT_SYMBOL(ax25_findbyuid);
-EXPORT_SYMBOL(ax25_find_cb);
-EXPORT_SYMBOL(ax25_linkfail_register);
-EXPORT_SYMBOL(ax25_linkfail_release);
-EXPORT_SYMBOL(ax25_listen_register);
-EXPORT_SYMBOL(ax25_listen_release);
-EXPORT_SYMBOL(ax25_protocol_register);
-EXPORT_SYMBOL(ax25_protocol_release);
-EXPORT_SYMBOL(ax25_send_frame);
-EXPORT_SYMBOL(ax25_uid_policy);
-EXPORT_SYMBOL(ax25cmp);
-EXPORT_SYMBOL(ax2asc);
-EXPORT_SYMBOL(asc2ax);
-EXPORT_SYMBOL(null_ax25_address);
-EXPORT_SYMBOL(ax25_display_timer);
-
 static int __init ax25_init(void)
 {
 	int rc = proto_register(&ax25_proto, 0);
Index: linux-net.git/net/ax25/ax25_addr.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_addr.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_addr.c	2006-04-29 11:30:24.000000000 +0100
@@ -11,6 +11,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -33,6 +34,8 @@
  */
 ax25_address null_ax25_address = {{0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00}};
 
+EXPORT_SYMBOL(null_ax25_address);
+
 /*
  *	ax25 -> ascii conversion
  */
@@ -64,6 +67,8 @@ char *ax2asc(char *buf, ax25_address *a)
 
 }
 
+EXPORT_SYMBOL(ax2asc);
+
 /*
  *	ascii -> ax25 conversion
  */
@@ -97,6 +102,8 @@ void asc2ax(ax25_address *addr, char *ca
 	addr->ax25_call[6] &= 0x1E;
 }
 
+EXPORT_SYMBOL(asc2ax);
+
 /*
  *	Compare two ax.25 addresses
  */
@@ -116,6 +123,8 @@ int ax25cmp(ax25_address *a, ax25_addres
  	return 2;			/* Partial match */
 }
 
+EXPORT_SYMBOL(ax25cmp);
+
 /*
  *	Compare two AX.25 digipeater paths.
  */
Index: linux-net.git/net/ax25/ax25_iface.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_iface.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_iface.c	2006-04-29 11:30:24.000000000 +0100
@@ -12,6 +12,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/spinlock.h>
 #include <linux/timer.h>
@@ -74,6 +75,8 @@ int ax25_protocol_register(unsigned int 
 	return 1;
 }
 
+EXPORT_SYMBOL(ax25_protocol_register);
+
 void ax25_protocol_release(unsigned int pid)
 {
 	struct protocol_struct *s, *protocol;
@@ -106,6 +109,8 @@ void ax25_protocol_release(unsigned int 
 	write_unlock(&protocol_list_lock);
 }
 
+EXPORT_SYMBOL(ax25_protocol_release);
+
 int ax25_linkfail_register(void (*func)(ax25_cb *, int))
 {
 	struct linkfail_struct *linkfail;
@@ -123,6 +128,8 @@ int ax25_linkfail_register(void (*func)(
 	return 1;
 }
 
+EXPORT_SYMBOL(ax25_linkfail_register);
+
 void ax25_linkfail_release(void (*func)(ax25_cb *, int))
 {
 	struct linkfail_struct *s, *linkfail;
@@ -155,6 +162,8 @@ void ax25_linkfail_release(void (*func)(
 	spin_unlock_bh(&linkfail_lock);
 }
 
+EXPORT_SYMBOL(ax25_linkfail_release);
+
 int ax25_listen_register(ax25_address *callsign, struct net_device *dev)
 {
 	struct listen_struct *listen;
@@ -176,6 +185,8 @@ int ax25_listen_register(ax25_address *c
 	return 1;
 }
 
+EXPORT_SYMBOL(ax25_listen_register);
+
 void ax25_listen_release(ax25_address *callsign, struct net_device *dev)
 {
 	struct listen_struct *s, *listen;
@@ -208,6 +219,8 @@ void ax25_listen_release(ax25_address *c
 	spin_unlock_bh(&listen_lock);
 }
 
+EXPORT_SYMBOL(ax25_listen_release);
+
 int (*ax25_protocol_function(unsigned int pid))(struct sk_buff *, ax25_cb *)
 {
 	int (*res)(struct sk_buff *, ax25_cb *) = NULL;
Index: linux-net.git/net/ax25/ax25_ip.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_ip.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_ip.c	2006-04-29 11:30:24.000000000 +0100
@@ -12,6 +12,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -221,3 +222,5 @@ int ax25_rebuild_header(struct sk_buff *
 
 #endif
 
+EXPORT_SYMBOL(ax25_hard_header);
+EXPORT_SYMBOL(ax25_rebuild_header);
Index: linux-net.git/net/ax25/ax25_out.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_out.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_out.c	2006-04-29 11:30:24.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -104,6 +105,8 @@ ax25_cb *ax25_send_frame(struct sk_buff 
 	return ax25;			/* We had to create it */
 }
 
+EXPORT_SYMBOL(ax25_send_frame);
+
 /*
  *	All outgoing AX.25 I frames pass via this routine. Therefore this is
  *	where the fragmentation of frames takes place. If fragment is set to
Index: linux-net.git/net/ax25/ax25_timer.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_timer.c	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/net/ax25/ax25_timer.c	2006-04-29 11:30:24.000000000 +0100
@@ -18,6 +18,7 @@
 #include <linux/socket.h>
 #include <linux/in.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/jiffies.h>
 #include <linux/timer.h>
 #include <linux/string.h>
@@ -137,6 +138,8 @@ unsigned long ax25_display_timer(struct 
 	return timer->expires - jiffies;
 }
 
+EXPORT_SYMBOL(ax25_display_timer);
+
 static void ax25_heartbeat_expiry(unsigned long param)
 {
 	int proto = AX25_PROTO_STD_SIMPLEX;
Index: linux-net.git/net/ax25/ax25_uid.c
===================================================================
--- linux-net.git.orig/net/ax25/ax25_uid.c	2006-04-29 01:54:20.000000000 +0100
+++ linux-net.git/net/ax25/ax25_uid.c	2006-04-29 11:30:24.000000000 +0100
@@ -49,6 +49,8 @@ static DEFINE_RWLOCK(ax25_uid_lock);
 
 int ax25_uid_policy = 0;
 
+EXPORT_SYMBOL(ax25_uid_policy);
+
 ax25_uid_assoc *ax25_findbyuid(uid_t uid)
 {
 	ax25_uid_assoc *ax25_uid, *res = NULL;
@@ -67,6 +69,8 @@ ax25_uid_assoc *ax25_findbyuid(uid_t uid
 	return res;
 }
 
+EXPORT_SYMBOL(ax25_findbyuid);
+
 int ax25_uid_ioctl(int cmd, struct sockaddr_ax25 *sax)
 {
 	ax25_uid_assoc *ax25_uid;
