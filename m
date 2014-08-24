From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 2/3] net: add __netdev_xmit_{only,flush} helpers
Date: Sun, 24 Aug 2014 15:42:17 +0200
Message-ID: <1408887738-7661-3-git-send-email-dborkman@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbaHXNmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 09:42:24 -0400
In-Reply-To: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds two helpers to use xmit and flushing separately from
each other as opposed to netdev_start_xmit().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netdevice.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1d05932..33faa33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3393,6 +3393,21 @@ static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_devi
 	return __netdev_start_xmit(ops, skb, dev);
 }
 
+static inline netdev_tx_t __netdev_xmit_only(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	return ops->ndo_start_xmit(skb, dev);
+}
+
+static inline void __netdev_xmit_flush(struct net_device *dev, u16 queue)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_xmit_flush)
+		ops->ndo_xmit_flush(dev, queue);
+}
+
 int netdev_class_create_file_ns(struct class_attribute *class_attr,
 				const void *ns);
 void netdev_class_remove_file_ns(struct class_attribute *class_attr,
-- 
1.7.11.7
