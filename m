From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 06/13] net: Add xfrm offload callbacks to struct net_device
Date: Thu, 4 Feb 2016 07:36:59 +0100
Message-ID: <1454567826-13018-7-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36668 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754377AbcBDHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:48 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the callbacks we need for IPsec GSO
and maybe also for IPsec hardware offload.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6fd1f1d..6936e96f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -778,6 +778,12 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
 
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
+struct xfrmdev_ops {
+	int			(*xdo_dev_encap) (struct sk_buff *skb);
+	int			(*xdo_dev_prepare) (struct sk_buff *skb);
+	int			(*xdo_dev_validate) (struct sk_buff *skb);
+	void			(*xdo_dev_resume) (struct sk_buff *skb, int err);
+};
 
 /*
  * This structure defines the management hooks for network devices.
@@ -1625,6 +1631,9 @@ struct net_device {
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	const struct l3mdev_ops	*l3mdev_ops;
 #endif
+#ifdef CONFIG_XFRM
+	const struct xfrmdev_ops *xfrmdev_ops;
+#endif
 
 	const struct header_ops *header_ops;
 
-- 
1.9.1
