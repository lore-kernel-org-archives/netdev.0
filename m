From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 01/11] net-next: Add
 netif_get_num_default_rss_queues
Date: Sun, 1 Jul 2012 16:18:50 +0300
Message-ID: <1341148740-7375-2-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3429 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326Ab2GANUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:37 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most multi-queue networking driver consider the number of online cpus when
configuring RSS queues.
This patch adds a wrapper to the number of cpus, setting an upper limit on the
number of cpus a driver should consider (by default) when allocating resources
for his queues.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   11 +++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2c2ecea..ab0251d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2119,6 +2119,9 @@ static inline int netif_copy_real_num_queues(struct net_device *to_dev,
 #endif
 }
 
+#define DEFAULT_MAX_NUM_RSS_QUEUES	(8)
+extern int netif_get_num_default_rss_queues(void);
+
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts
  * disabled.
diff --git a/net/core/dev.c b/net/core/dev.c
index ed674e2..69f7a1a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1793,6 +1793,17 @@ int netif_set_real_num_rx_queues(struct net_device *dev, unsigned int rxq)
 EXPORT_SYMBOL(netif_set_real_num_rx_queues);
 #endif
 
+/* netif_get_num_default_rss_queues - default number of RSS queues
+ *
+ * This routine should set an upper limit on the number of RSS queues
+ * used by default by multiqueue devices.
+ */
+int netif_get_num_default_rss_queues()
+{
+	return min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
+}
+EXPORT_SYMBOL(netif_get_num_default_rss_queues);
+
 static inline void __netif_reschedule(struct Qdisc *q)
 {
 	struct softnet_data *sd;
-- 
1.7.9.rc2
