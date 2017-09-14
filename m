From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 4/5] net: Add TLS TX offload features
Date: Thu, 14 Sep 2017 13:46:27 +0300
Message-ID: <1505385988-94522-5-git-send-email-ilyal@mellanox.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37262 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751841AbdINKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:35 -0400
In-Reply-To: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a netdev feature to configure TLS TX offloads.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/linux/netdev_features.h | 2 ++
 net/core/ethtool.c              | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index dc8b489..ed0648a 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -76,6 +76,7 @@ enum {
 	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
 	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
 	NETIF_F_RX_UDP_TUNNEL_PORT_BIT, /* Offload of RX port for UDP tunnels */
+	NETIF_F_HW_TLS_TX_BIT,		/* Hardware TLS TX offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -140,6 +141,7 @@ enum {
 #define NETIF_F_HW_ESP		__NETIF_F(HW_ESP)
 #define NETIF_F_HW_ESP_TX_CSUM	__NETIF_F(HW_ESP_TX_CSUM)
 #define	NETIF_F_RX_UDP_TUNNEL_PORT  __NETIF_F(RX_UDP_TUNNEL_PORT)
+#define NETIF_F_HW_TLS_TX	__NETIF_F(HW_TLS_TX)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6a582ae..2ae1fc4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -106,6 +106,7 @@ int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
 	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
 	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
 	[NETIF_F_RX_UDP_TUNNEL_PORT_BIT] =	 "rx-udp_tunnel-port-offload",
+	[NETIF_F_HW_TLS_TX_BIT] =	 "tls-hw-tx-offload",
 };
 
 static const char
-- 
1.8.3.1
