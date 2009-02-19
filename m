From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 2/7] net: add FCoE offload support through net_device
Date: Thu, 19 Feb 2009 12:49:49 -0700
Message-ID: <20090219194949.22270.40834.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a "struct net_fcoe_ops *fcoe_ops" to net_device struct so any
network adapter driver can provide Fiber Channle over Ethernet (FCoE) offload
support through net_device. The fcoe_ops is only available when FCoE is
enabled in kernel as built-in or module driver.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/netdevice.h |    8 ++++++++
 include/linux/netfcoe.h   |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfcoe.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec54785..faf85be 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -47,6 +47,10 @@
 #include <net/dcbnl.h>
 #endif
 
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#include <linux/netfcoe.h>
+#endif
+
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
@@ -840,6 +844,10 @@ struct net_device
 	struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
 
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+	struct net_fcoe_ops *fcoe_ops;
+#endif
+
 #ifdef CONFIG_COMPAT_NET_DEV_OPS
 	struct {
 		int			(*init)(struct net_device *dev);
diff --git a/include/linux/netfcoe.h b/include/linux/netfcoe.h
new file mode 100644
index 0000000..9d6d64d
--- /dev/null
+++ b/include/linux/netfcoe.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright(c) 2007 - 2009 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Maintained at www.Open-FCoE.org
+ */
+#ifndef __NET_FCOE_H__
+#define __NET_FCOE_H__
+
+#define NET_FCOE_CRC	(1 << 0) /* FC CRC32 offload */
+#define NET_FCOE_LSO	(1 << 1) /* Large send offload */
+#define NET_FCOE_LRO	(1 << 2) /* Large receive offload */
+/*
+ * Ops struct for FCoE enabled drivers to callback through the netdevice struct
+ */
+struct net_fcoe_ops {
+	u16 lro_xid;
+	u32 features;
+	int (*ddp_setup)(struct net_device *netdev, u16 xid,
+			 struct scatterlist *sgl, unsigned int nents);
+	int (*ddp_done)(struct net_device *netdev, u16 xid);
+};
+
+#endif /* __NET_FCOE_H__ */

