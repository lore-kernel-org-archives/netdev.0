From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/6] veth: advertise link netns via netlink
Date: Tue, 20 Jan 2015 15:15:46 +0100
Message-ID: <1421763347-4354-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53804 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbATOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:57 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/veth.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8ad596573d17..4cca36ebc4fb 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -469,6 +469,14 @@ static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
 	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
 };
 
+static struct net *veth_get_link_net(const struct net_device *dev)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
+
+	return peer ? dev_net(peer) : dev_net(dev);
+}
+
 static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
 	.priv_size	= sizeof(struct veth_priv),
@@ -478,6 +486,7 @@ static struct rtnl_link_ops veth_link_ops = {
 	.dellink	= veth_dellink,
 	.policy		= veth_policy,
 	.maxtype	= VETH_INFO_MAX,
+	.get_link_net	= veth_get_link_net,
 };
 
 /*
-- 
2.2.2
