From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 04/15] net: Add TLS offload netdevice and socket support
Date: Tue, 28 Mar 2017 16:26:21 +0300
Message-ID: <1490707592-1430-5-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47606 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753359AbdC1N1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:27:34 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>

This patch add a new NDO to add and delete TLS contexts on netdevices.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/linux/netdevice.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 51f9336..ce4760c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -844,6 +844,25 @@ struct xfrmdev_ops {
 };
 #endif
 
+#if IS_ENABLED(CONFIG_TLS)
+enum tls_offload_ctx_dir {
+	TLS_OFFLOAD_CTX_DIR_RX,
+	TLS_OFFLOAD_CTX_DIR_TX,
+};
+
+struct tls_crypto_info;
+struct tls_offload_context;
+
+struct tlsdev_ops {
+	int (*tls_dev_add)(struct net_device *netdev, struct sock *sk,
+			enum tls_offload_ctx_dir direction,
+			struct tls_crypto_info *crypto_info,
+			struct tls_offload_context **ctx);
+	void (*tls_dev_del)(struct net_device *netdev, struct sock *sk,
+			enum tls_offload_ctx_dir direction);
+};
+#endif
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1722,6 +1741,10 @@ struct net_device {
 	const struct xfrmdev_ops *xfrmdev_ops;
 #endif
 
+#if IS_ENABLED(CONFIG_TLS)
+	const struct tlsdev_ops *tlsdev_ops;
+#endif
+
 	const struct header_ops *header_ops;
 
 	unsigned int		flags;
-- 
2.7.4
