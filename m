From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] remove magic '31' for netdev priv. alignment
Date: Mon, 5 Apr 2004 15:56:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405155654.69a9bb4b.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[resend/rediff]

// linux-2.6.5
// remove magic number of '31' from net_device and private alignment;

diffstat:=
 drivers/net/net_init.c    |    8 +++++---
 include/linux/netdevice.h |    7 ++++++-
 2 files changed, 11 insertions(+), 4 deletions(-)


diff -Naurp ./drivers/net/net_init.c.orig ./drivers/net/net_init.c
--- ./drivers/net/net_init.c.orig	2004-04-03 19:36:16.000000000 -0800
+++ ./drivers/net/net_init.c	2004-04-05 15:46:26.000000000 -0700
@@ -79,8 +79,9 @@ struct net_device *alloc_netdev(int size
 
 	/* ensure 32-byte alignment of both the device and private area */
 
-	alloc_size = (sizeof(struct net_device) + 31) & ~31;
-	alloc_size += sizeof_priv + 31;
+	alloc_size = (sizeof(struct net_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST;
+	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kmalloc (alloc_size, GFP_KERNEL);
 	if (!p) {
@@ -90,7 +91,8 @@ struct net_device *alloc_netdev(int size
 
 	memset(p, 0, alloc_size);
 
-	dev = (struct net_device *)(((long)p + 31) & ~31);
+	dev = (struct net_device *)(((long)p + NETDEV_ALIGN_CONST)
+				& ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
 
 	if (sizeof_priv)
diff -Naurp ./include/linux/netdevice.h.orig ./include/linux/netdevice.h
--- ./include/linux/netdevice.h.orig	2004-04-03 19:38:18.000000000 -0800
+++ ./include/linux/netdevice.h	2004-04-05 15:46:26.000000000 -0700
@@ -484,9 +484,14 @@ struct net_device
 	int padded;
 };
 
+#define	NETDEV_ALIGN		32
+#define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
+
 static inline void *netdev_priv(struct net_device *dev)
 {
-	return (char *)dev + ((sizeof(struct net_device) + 31) & ~31);
+	return (char *)dev + ((sizeof(struct net_device)
+					+ NETDEV_ALIGN_CONST)
+				& ~NETDEV_ALIGN_CONST);
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)


--
~Randy
"We have met the enemy and he is us."  -- Pogo (by Walt Kelly)
