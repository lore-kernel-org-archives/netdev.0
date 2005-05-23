From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM support
Date: Mon, 23 May 2005 16:07:57 -0500
Message-ID: <20050523210757.GB5910@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Added support to ethtool for NETIF_F_HW_CSUM.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- include/linux/ethtool.h.orig	2005-05-16 08:49:43.000000000 -0500
+++ include/linux/ethtool.h	2005-05-21 15:11:05.000000000 -0500
@@ -256,6 +256,7 @@ struct net_device;
 u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
+int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
 u32 ethtool_op_get_sg(struct net_device *dev);
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
--- net/core/ethtool.c.orig	2005-05-21 14:16:33.000000000 -0500
+++ net/core/ethtool.c	2005-05-21 18:07:16.000000000 -0500
@@ -29,7 +29,7 @@ u32 ethtool_op_get_link(struct net_devic
 
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
-	return (dev->features & NETIF_F_IP_CSUM) != 0;
+	return (dev->features & (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM)) != 0;
 }
 
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
@@ -42,6 +42,15 @@ int ethtool_op_set_tx_csum(struct net_de
 	return 0;
 }
 
+int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_HW_CSUM;
+	else
+		dev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
+}
 u32 ethtool_op_get_sg(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_SG) != 0;
@@ -817,3 +826,4 @@ EXPORT_SYMBOL(ethtool_op_get_tx_csum);
 EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
+EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
