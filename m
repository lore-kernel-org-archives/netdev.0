From: Jeff Garzik <jgarzik@pobox.com>
Subject: [patch][fyi] move ethtool_op_tx_csum
Date: Mon, 1 Sep 2003 20:33:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902003339.GA29156@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Queued here for both 2.4 and 2.5.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1129  -> 1.1130 
#	  net/core/ethtool.c	1.3     -> 1.4    
#	include/linux/ethtool.h	1.16    -> 1.17   
#	       net/netsyms.c	1.41    -> 1.42   
#	drivers/net/8139cp.c	1.43    -> 1.44   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/01	jgarzik@redhat.com	1.1130
# [NET] move ethtool_op_set_tx_csum from 8139cp drvr to net/core/ethtool.c,
# where it belongs.
# --------------------------------------------
#
diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	Mon Sep  1 20:32:14 2003
+++ b/drivers/net/8139cp.c	Mon Sep  1 20:32:14 2003
@@ -1405,17 +1405,6 @@
 	return 0;
 }
 
-/* move this to net/core/ethtool.c */
-static int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |= NETIF_F_IP_CSUM;
-	else
-		dev->features &= ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
 static void cp_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		        void *p)
 {
diff -Nru a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h	Mon Sep  1 20:32:14 2003
+++ b/include/linux/ethtool.h	Mon Sep  1 20:32:14 2003
@@ -255,6 +255,7 @@
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
+int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 u32 ethtool_op_get_sg(struct net_device *dev);
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 
diff -Nru a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c	Mon Sep  1 20:32:14 2003
+++ b/net/core/ethtool.c	Mon Sep  1 20:32:14 2003
@@ -31,6 +31,16 @@
 	return (dev->features & NETIF_F_IP_CSUM) != 0;
 }
 
+int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_IP_CSUM;
+	else
+		dev->features &= ~NETIF_F_IP_CSUM;
+
+	return 0;
+}
+
 u32 ethtool_op_get_sg(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_SG) != 0;
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Mon Sep  1 20:32:14 2003
+++ b/net/netsyms.c	Mon Sep  1 20:32:14 2003
@@ -617,6 +617,7 @@
 /* ethtool.c */
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_tx_csum);
+EXPORT_SYMBOL(ethtool_op_set_tx_csum);
 EXPORT_SYMBOL(ethtool_op_get_sg);
 EXPORT_SYMBOL(ethtool_op_set_sg);
 
