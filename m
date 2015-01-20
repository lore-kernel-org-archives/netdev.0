From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/6] vlan: advertise link netns via netlink
Date: Tue, 20 Jan 2015 15:15:44 +0100
Message-ID: <1421763347-4354-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53802 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbATOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:57 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/8021q/vlan_netlink.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 8ac8a5cc2143..c92b52f37d38 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -238,6 +238,13 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static struct net *vlan_get_link_net(const struct net_device *dev)
+{
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+
+	return dev_net(real_dev);
+}
+
 struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.kind		= "vlan",
 	.maxtype	= IFLA_VLAN_MAX,
@@ -250,6 +257,7 @@ struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.dellink	= unregister_vlan_dev,
 	.get_size	= vlan_get_size,
 	.fill_info	= vlan_fill_info,
+	.get_link_net	= vlan_get_link_net,
 };
 
 int __init vlan_netlink_init(void)
-- 
2.2.2
