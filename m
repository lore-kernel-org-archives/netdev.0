From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] missing includes in networking headers
Date: Mon, 31 May 2004 17:37:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531153738.GA19250@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm looking through the debian kernel package, and it's adding a bunch
of additional includes and forward declarations to the networking headers.
After review all of these makes sense although I don't know what the
pratical implications.

In particular:

 - struct sk_buff forward declaration in netlink.h
 - struct net_device forward declaration in skbuff.h
 - <linux/spinlock.h> for rwlock_t in ip6_fib.h
 - <linux/ipv6.h> for inet6_sk in ip6_route.h
 - struct neighbour and struct net_device forward declarations in
   neighbour.h


--- 1.15/include/linux/netlink.h	2004-04-16 18:24:35 +02:00
+++ edited/include/linux/netlink.h	2004-05-31 15:56:15 +02:00
@@ -4,6 +4,9 @@
 #include <linux/socket.h> /* for sa_family_t */
 #include <linux/types.h>
 
+struct sk_buff;
+
+
 #define NETLINK_ROUTE		0	/* Routing/device hook				*/
 #define NETLINK_SKIP		1	/* Reserved for ENskip  			*/
 #define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
--- 1.43/include/linux/skbuff.h	2004-05-30 21:09:46 +02:00
+++ edited/include/linux/skbuff.h	2004-05-31 15:55:28 +02:00
@@ -28,6 +28,9 @@
 #include <linux/poll.h>
 #include <linux/net.h>
 
+struct net_device;
+
+
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
 #define SLAB_SKB 		/* Slabified skbuffs 	   */
--- 1.7/include/net/ip6_fib.h	2003-06-04 07:05:08 +02:00
+++ edited/include/net/ip6_fib.h	2004-05-31 15:56:57 +02:00
@@ -20,6 +20,7 @@
 #include <net/dst.h>
 #include <net/flow.h>
 #include <linux/rtnetlink.h>
+#include <linux/spinlock.h>
 
 struct rt6_info;
 
===== include/net/ip6_route.h 1.13 vs edited =====
--- 1.13/include/net/ip6_route.h	2004-05-30 20:58:39 +02:00
+++ edited/include/net/ip6_route.h	2004-05-31 15:58:35 +02:00
@@ -11,6 +11,7 @@
 
 #include <net/flow.h>
 #include <net/ip6_fib.h>
+#include <linux/ipv6.h>
 #include <linux/tcp.h>
 #include <linux/ip.h>
 
--- 1.7/include/net/neighbour.h	2004-04-16 22:48:54 +02:00
+++ edited/include/net/neighbour.h	2004-05-31 15:59:24 +02:00
@@ -49,6 +49,9 @@
 #include <linux/err.h>
 #include <linux/sysctl.h>
 
+struct neighbour;
+struct net_device;
+
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
 #define NUD_CONNECTED	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE)
