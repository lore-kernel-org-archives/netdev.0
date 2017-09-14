From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 3/5] net: Add TLS offload netdev ops
Date: Thu, 14 Sep 2017 13:46:26 +0300
Message-ID: <1505385988-94522-4-git-send-email-ilyal@mellanox.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37202 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751796AbdINKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:35 -0400
In-Reply-To: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new netdev ops to add and delete tls context

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/linux/netdevice.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cdfd9ad..4ea81bab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -826,6 +826,23 @@ struct xfrmdev_ops {
 };
 #endif
 
+#if IS_ENABLED(CONFIG_TLS_DEVICE)
+enum tls_offload_ctx_dir {
+	TLS_OFFLOAD_CTX_DIR_RX,
+	TLS_OFFLOAD_CTX_DIR_TX,
+};
+
+struct tls_crypto_info;
+
+struct tlsdev_ops {
+	int (*tls_dev_add)(struct net_device *netdev, struct sock *sk,
+			   enum tls_offload_ctx_dir direction,
+			   struct tls_crypto_info *crypto_info);
+	void (*tls_dev_del)(struct net_device *netdev, struct sock *sk,
+			    enum tls_offload_ctx_dir direction);
+};
+#endif
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1713,6 +1730,10 @@ struct net_device {
 	const struct xfrmdev_ops *xfrmdev_ops;
 #endif
 
+#if IS_ENABLED(CONFIG_TLS_DEVICE)
+	const struct tlsdev_ops *tlsdev_ops;
+#endif
+
 	const struct header_ops *header_ops;
 
 	unsigned int		flags;
-- 
1.8.3.1
