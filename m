From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mark arcdev_setup static
Date: Sun, 9 Jan 2005 14:33:35 +0100
Message-ID: <20050109133335.GA20801@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's only used in arcnet.c, and following the model of the other
link layers it doesn't make sense to use it outside alloc_arcdev()
either.


--- 1.19/drivers/net/arcnet/arcnet.c	2004-09-23 22:10:54 +02:00
+++ edited/drivers/net/arcnet/arcnet.c	2004-10-23 16:09:36 +02:00
@@ -91,7 +91,6 @@
 EXPORT_SYMBOL(arc_proto_null);
 EXPORT_SYMBOL(arcnet_unregister_proto);
 EXPORT_SYMBOL(arcnet_debug);
-EXPORT_SYMBOL(arcdev_setup);
 EXPORT_SYMBOL(alloc_arcdev);
 EXPORT_SYMBOL(arcnet_interrupt);
 
@@ -305,7 +304,7 @@
 
 
 /* Setup a struct device for ARCnet. */
-void arcdev_setup(struct net_device *dev)
+static void arcdev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_ARCNET;
 	dev->hard_header_len = sizeof(struct archdr);
--- 1.7/include/linux/arcdevice.h	2004-10-05 22:16:18 +02:00
+++ edited/include/linux/arcdevice.h	2004-10-23 16:09:24 +02:00
@@ -330,7 +330,6 @@
 
 void arcnet_unregister_proto(struct ArcProto *proto);
 irqreturn_t arcnet_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-void arcdev_setup(struct net_device *dev);
 struct net_device *alloc_arcdev(char *name);
 void arcnet_rx(struct net_device *dev, int bufnum);
 
