From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] l2tp: define "l2tpeth" device type
Date: Mon, 24 Apr 2017 14:16:07 +0200
Message-ID: <f9c1eb350915a145978d7f5d485ad210c11ba5ca.1493035407.git.g.nault@alphalink.fr>
References: <cover.1493035407.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:41071 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1044560AbdDXMQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 08:16:11 -0400
Content-Disposition: inline
In-Reply-To: <cover.1493035407.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export type of l2tpeth interfaces to userspace
(/sys/class/net/<iface>/uevent).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_eth.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 5e44b3cc1212..59aba8aeac03 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -130,8 +130,13 @@ static const struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
+static struct device_type l2tpeth_type = {
+	.name = "l2tpeth",
+};
+
 static void l2tp_eth_dev_setup(struct net_device *dev)
 {
+	SET_NETDEV_DEVTYPE(dev, &l2tpeth_type);
 	ether_setup(dev);
 	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
 	dev->features		|= NETIF_F_LLTX;
-- 
2.11.0
