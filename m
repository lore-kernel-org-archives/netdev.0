From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/2] net: make struct tun_struct private to tun.c
Date: Sat, 5 Apr 2008 21:53:55 +1000
Message-ID: <200804052153.55676.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60816 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519AbYDELyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 07:54:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no reason for this to be in the header, and it just hurts
recompile time.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r f657af5295ee drivers/net/tun.c
--- a/drivers/net/tun.c	Tue Apr 01 21:19:09 2008 +1000
+++ b/drivers/net/tun.c	Fri Apr 04 16:03:31 2008 +1100
@@ -67,9 +67,42 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
+/* Uncomment to enable debugging */
+/* #define TUN_DEBUG 1 */
+
 #ifdef TUN_DEBUG
 static int debug;
+
+#define DBG  if(tun->debug)printk
+#define DBG1 if(debug==2)printk
+#else
+#define DBG( a... )
+#define DBG1( a... )
 #endif
+
+struct tun_struct {
+	struct list_head        list;
+	unsigned long 		flags;
+	int			attached;
+	uid_t			owner;
+	gid_t			group;
+
+	wait_queue_head_t	read_wait;
+	struct sk_buff_head	readq;
+
+	struct net_device	*dev;
+
+	struct fasync_struct    *fasync;
+
+	unsigned long if_flags;
+	u8 dev_addr[ETH_ALEN];
+	u32 chr_filter[2];
+	u32 net_filter[2];
+
+#ifdef TUN_DEBUG	
+	int debug;
+#endif  
+};
 
 /* Network device part of the driver */
 
diff -r f657af5295ee include/linux/Kbuild
--- a/include/linux/Kbuild	Tue Apr 01 21:19:09 2008 +1000
+++ b/include/linux/Kbuild	Fri Apr 04 16:03:31 2008 +1100
@@ -86,6 +86,7 @@ header-y += if_ppp.h
 header-y += if_ppp.h
 header-y += if_slip.h
 header-y += if_strip.h
+header-y += if_tun.h
 header-y += if_tunnel.h
 header-y += in6.h
 header-y += in_route.h
@@ -229,7 +230,6 @@ unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppox.h
 unifdef-y += if_tr.h
-unifdef-y += if_tun.h
 unifdef-y += if_vlan.h
 unifdef-y += if_wanpipe.h
 unifdef-y += igmp.h
diff -r f657af5295ee include/linux/if_tun.h
--- a/include/linux/if_tun.h	Tue Apr 01 21:19:09 2008 +1000
+++ b/include/linux/if_tun.h	Fri Apr 04 16:03:31 2008 +1100
@@ -18,46 +18,7 @@
 #ifndef __IF_TUN_H
 #define __IF_TUN_H
 
-/* Uncomment to enable debugging */
-/* #define TUN_DEBUG 1 */
-
 #include <linux/types.h>
-
-#ifdef __KERNEL__
-
-#ifdef TUN_DEBUG
-#define DBG  if(tun->debug)printk
-#define DBG1 if(debug==2)printk
-#else
-#define DBG( a... )
-#define DBG1( a... )
-#endif
-
-struct tun_struct {
-	struct list_head        list;
-	unsigned long 		flags;
-	int			attached;
-	uid_t			owner;
-	gid_t			group;
-
-	wait_queue_head_t	read_wait;
-	struct sk_buff_head	readq;
-
-	struct net_device	*dev;
-
-	struct fasync_struct    *fasync;
-
-	unsigned long if_flags;
-	u8 dev_addr[ETH_ALEN];
-	u32 chr_filter[2];
-	u32 net_filter[2];
-
-#ifdef TUN_DEBUG	
-	int debug;
-#endif  
-};
-
-#endif /* __KERNEL__ */
 
 /* Read queue size */
 #define TUN_READQ_SIZE	500
