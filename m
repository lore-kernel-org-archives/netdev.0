From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] DCB: fix kconfig option
Date: Mon, 24 Nov 2008 15:46:27 -0800
Message-ID: <20081124234627.24425.44782.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49765 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbYKXXqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:46:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the netlink option for DCB is necessary to actually be useful,
simplified the Kconfig option.  In addition, added useful help text for the
Kconfig option.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig            |    4 ++--
 drivers/net/ixgbe/Makefile     |    2 +-
 drivers/net/ixgbe/ixgbe.h      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c |   10 +++++-----
 include/linux/netdevice.h      |    4 ++--
 net/Makefile                   |    4 ++--
 net/dcb/Kconfig                |   24 +++++++++++++++++-------
 net/dcb/dcbnl.c                |    2 +-
 8 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index efd461d..75f9f7f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2451,10 +2451,10 @@ config IXGBE_DCA
 	  driver.  DCA is a method for warming the CPU cache before data
 	  is used, with the intent of lessening the impact of cache misses.
 
-config IXGBE_DCBNL
+config IXGBE_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default n
-	depends on IXGBE && DCBNL
+	depends on IXGBE && DCB
 	---help---
 	  Say Y here if you want to use Data Center Bridging (DCB) in the
 	  driver.
diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 3228e50..6e7ef76 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -35,4 +35,4 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82598.o ixgbe_phy.o
 
-ixgbe-$(CONFIG_IXGBE_DCBNL) +=  ixgbe_dcb.o ixgbe_dcb_82598.o ixgbe_dcb_nl.o
+ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 9509aee..6cbf26e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -327,7 +327,7 @@ enum ixgbe_boards {
 };
 
 extern struct ixgbe_info ixgbe_82598_info;
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 extern struct dcbnl_rtnl_ops dcbnl_ops;
 extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                               struct ixgbe_dcb_config *dst_dcb_cfg,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6620397..667a646 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1914,7 +1914,7 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 	}
 }
 
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 /*
  * ixgbe_configure_dcb - Configure DCB hardware
  * @adapter: ixgbe adapter struct
@@ -1960,7 +1960,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_set_rx_mode(netdev);
 
 	ixgbe_restore_vlan(adapter);
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		netif_set_gso_max_size(netdev, 32768);
 		ixgbe_configure_dcb(adapter);
@@ -2749,7 +2749,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss;
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 	int j;
 	struct tc_configuration *tc;
 #endif
@@ -2768,7 +2768,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
 
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 	/* Configure DCB traffic classes */
 	for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
 		tc = &adapter->dcb_cfg.tc_config[j];
@@ -4120,7 +4120,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 
-#ifdef CONFIG_IXGBE_DCBNL
+#ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6095af5..65cfb01 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -43,7 +43,7 @@
 
 #include <net/net_namespace.h>
 #include <net/dsa.h>
-#ifdef CONFIG_DCBNL
+#ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
 
@@ -846,7 +846,7 @@ struct net_device
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
 
-#ifdef CONFIG_DCBNL
+#ifdef CONFIG_DCB
 	/* Data Center Bridging netlink ops */
 	struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
diff --git a/net/Makefile b/net/Makefile
index e5af3dc..4ccc0c7 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -56,8 +56,8 @@ obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
-ifeq ($(CONFIG_DCBNL),y)
-obj-$(CONFIG_DCB)		+= dcb/
+ifeq ($(CONFIG_DCB),)
+obj-y				+= dcb/
 endif
 
 ifeq ($(CONFIG_NET),y)
diff --git a/net/dcb/Kconfig b/net/dcb/Kconfig
index bdf3880..a250498 100644
--- a/net/dcb/Kconfig
+++ b/net/dcb/Kconfig
@@ -1,12 +1,22 @@
 config DCB
-        tristate "Data Center Bridging support"
-
-config DCBNL
-	bool "Data Center Bridging netlink interface support"
-	depends on DCB
+        bool "Data Center Bridging support"
 	default n
 	---help---
-	  This option turns on the netlink interface
-	  (dcbnl) for Data Center Bridging capable devices.
+	  This enables support for configuring Data Center Bridging (DCB)
+	  features on DCB capable Ethernet adapters via rtnetlink.  Say 'Y'
+	  if you have a DCB capable Ethernet adapter which supports this
+	  interface and you are connected to a DCB capable switch.
+
+	  DCB is a collection of Ethernet enhancements which allow DCB capable
+	  NICs and switches to support network traffic with differing
+	  requirements (highly reliable, no drops vs. best effort vs. low
+	  latency) to co-exist on Ethernet.
+
+	  DCB features include:
+	    Enhanced Transmission Selection (aka Priority Grouping) - provides a
+	      framework for assigning bandwidth guarantees to traffic classes.
+	    Priority-based Flow Control (PFC) - a MAC control pause frame which
+	      works at the granularity of the 802.1p priority instead of the
+	      link (802.3x).
 
 	  If unsure, say N.
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index b2bda3f..79a351d 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -48,7 +48,7 @@
  */
 
 MODULE_AUTHOR("Lucy Liu, <lucy.liu@intel.com>");
-MODULE_DESCRIPTION("Data Center Bridging generic netlink interface");
+MODULE_DESCRIPTION("Data Center Bridging netlink interface");
 MODULE_LICENSE("GPL");
 
 /**************** DCB attribute policies *************************************/

