From: xiaohui.xin@intel.com
Subject: [PATCH v11 02/17] Add a new struct for device to manipulate external buffer.
Date: Sat, 25 Sep 2010 12:27:20 +0800
Message-ID: <c6751a0126ef4d3d1ce75e596ccf9cebd9757052.1285385607.git.xiaohui.xin@intel.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
References: <59d8a50047ee01e26658fd676d26c0162b79e5fd.1285385607.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..ba582e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,6 +530,25 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+/* Add a structure in structure net_device, the new field is
+ * named as mp_port. It's for mediate passthru (zero-copy).
+ * It contains the capability for the net device driver,
+ * a socket, and an external buffer creator, external means
+ * skb buffer belongs to the device may not be allocated from
+ * kernel space.
+ */
+struct mpassthru_port	{
+	int		hdr_len;
+	int		data_len;
+	int		npages;
+	unsigned	flags;
+	struct socket	*sock;
+	int		vnet_hlen;
+	struct skb_ext_page *(*ctor)(struct mpassthru_port *,
+				struct sk_buff *, int);
+	struct skb_ext_page *(*hash)(struct net_device *,
+				struct page *);
+};
 
 /*
  * This structure defines the management hooks for network devices.
@@ -952,7 +971,8 @@ struct net_device {
 	struct macvlan_port	*macvlan_port;
 	/* GARP */
 	struct garp_port	*garp_port;
-
+	/* mpassthru */
+	struct mpassthru_port	*mp_port;
 	/* class/net/name entry */
 	struct device		dev;
 	/* space for optional device, statistics, and wireless sysfs groups */
-- 
1.7.3
