From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] add alloc_ltalkdev
Date: Wed, 4 May 2005 21:27:40 +0200
Message-ID: <20050504192740.GA21409@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this matches the API used by other link layer like ethernet or token
ring.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: drivers/net/appletalk/cops.c
===================================================================
--- 2aa9e4732d7014dcda4c0e80d2e377f52e2262e9/drivers/net/appletalk/cops.c  (mode:100644 sha1:2161c2d585f0869e57ebfe101a49686f5ea36b4b)
+++ uncommitted/drivers/net/appletalk/cops.c  (mode:100644)
@@ -65,7 +65,7 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
-#include <linux/if_ltalk.h>	/* For ltalk_setup() */
+#include <linux/if_ltalk.h>
 #include <linux/delay.h>	/* For udelay() */
 #include <linux/atalk.h>
 #include <linux/spinlock.h>
@@ -223,7 +223,7 @@
 	int base_addr;
 	int err = 0;
 
-	dev = alloc_netdev(sizeof(struct cops_local), "lt%d", ltalk_setup);
+	dev = alloc_ltalkdev(sizeof(struct cops_local));
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
Index: drivers/net/appletalk/ltpc.c
===================================================================
--- 2aa9e4732d7014dcda4c0e80d2e377f52e2262e9/drivers/net/appletalk/ltpc.c  (mode:100644 sha1:ad8e943231a1c3a93cb769fb3d1fad23baa40ac6)
+++ uncommitted/drivers/net/appletalk/ltpc.c  (mode:100644)
@@ -1039,7 +1039,7 @@
 	unsigned long f;
 	unsigned long timeout;
 
-	dev = alloc_netdev(sizeof(struct ltpc_private), "lt%d", ltalk_setup);
+	dev = alloc_ltalkdev(sizeof(struct ltpc_private));
 	if (!dev)
 		goto out;
 
Index: include/linux/if_ltalk.h
===================================================================
--- 2aa9e4732d7014dcda4c0e80d2e377f52e2262e9/include/linux/if_ltalk.h  (mode:100644 sha1:e75e832b7ff0dd56d79bb07029a89a16c067afa2)
+++ uncommitted/include/linux/if_ltalk.h  (mode:100644)
@@ -6,7 +6,7 @@
 #define LTALK_ALEN		1
 
 #ifdef __KERNEL__
-extern void ltalk_setup(struct net_device *);
+extern struct net_device *alloc_ltalkdev(int sizeof_priv);
 #endif
 
 #endif
Index: net/appletalk/dev.c
===================================================================
--- 2aa9e4732d7014dcda4c0e80d2e377f52e2262e9/net/appletalk/dev.c  (mode:100644 sha1:76598445d84b1591279ea3467b68ebe119bb3684)
+++ uncommitted/net/appletalk/dev.c  (mode:100644)
@@ -19,7 +19,7 @@
 	return -EINVAL;
 }
 
-void ltalk_setup(struct net_device *dev)
+static void ltalk_setup(struct net_device *dev)
 {
 	/* Fill in the fields of the device structure with localtalk-generic values. */
 	
@@ -40,4 +40,22 @@
 
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST|IFF_NOARP;
 }
-EXPORT_SYMBOL(ltalk_setup);
+
+/**
+ * alloc_ltalkdev - Allocates and sets up an localtalk device
+ * @sizeof_priv: Size of additional driver-private structure to be allocated
+ *	for this localtalk device
+ *
+ * Fill in the fields of the device structure with localtalk-generic
+ * values. Basically does everything except registering the device.
+ *
+ * Constructs a new net device, complete with a private data area of
+ * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * this private data area.
+ */
+
+struct net_device *alloc_ltalkdev(int sizeof_priv)
+{
+	return alloc_netdev(sizeof_priv, "lt%d", ltalk_setup);
+}
+EXPORT_SYMBOL(alloc_ltalkdev);
