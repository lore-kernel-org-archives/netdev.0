From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v6 02/19] Add a new struct for device to manipulate external buffer.
Date: Fri, 21 May 2010 17:30:18 +0800
Message-ID: <1274434235-5929-3-git-send-email-xiaohui.xin@intel.com>
References: <1274434235-5929-1-git-send-email-xiaohui.xin@intel.com>
 <1274434235-5929-2-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32584 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab0EUJXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 05:23:44 -0400
In-Reply-To: <1274434235-5929-2-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/netdevice.h |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa8b476..bae725c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,6 +530,22 @@ struct netdev_queue {
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
+	struct skb_external_page *(*ctor)(struct mpassthru_port *,
+				struct sk_buff *, int);
+};
 
 /*
  * This structure defines the management hooks for network devices.
@@ -952,7 +968,8 @@ struct net_device {
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

