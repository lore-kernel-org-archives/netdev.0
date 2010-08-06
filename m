From: xiaohui.xin@intel.com
Subject: [RFC PATCH v9 02/16] Add a new struct for device to manipulate external buffer.
Date: Fri,  6 Aug 2010 17:23:30 +0800
Message-ID: <1281086624-5765-3-git-send-email-xiaohui.xin@intel.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-2-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1281086624-5765-2-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
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
1.5.4.4

