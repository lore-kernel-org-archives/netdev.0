From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] veth: allow to setup multicast address for veth device
Date: Fri, 4 Oct 2013 16:52:24 +0800
Message-ID: <1380876744-606-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: pablo@netfilter.org, davem@davemloft.net, edumazet@google.com,
	kaber@trash.net, hannes@stressinduktion.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2324 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab3JDIvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:51:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can only setup multicast address for network device when
net_device_ops->ndo_set_rx_mode is not null.

Some configurations need to add multicast address for net
device, such as netfilter cluster match module.

Add a fake ndo_set_rx_mode function to allow this operation.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/veth.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index eee1f19..b2d0347 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -188,6 +188,11 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 	return tot;
 }
 
+/* fake multicast ability */
+static void veth_set_multicast_list(struct net_device *dev)
+{
+}
+
 static int veth_open(struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
@@ -250,6 +255,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_start_xmit      = veth_xmit,
 	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats64     = veth_get_stats64,
+	.ndo_set_rx_mode     = veth_set_multicast_list,
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
-- 
1.8.3.1
