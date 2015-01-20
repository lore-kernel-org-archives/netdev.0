From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/6] macvlan: advertise link netns via netlink
Date: Tue, 20 Jan 2015 15:15:45 +0100
Message-ID: <1421763347-4354-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53814 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbbATOP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:15:58 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assign rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/macvlan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 612e0731142d..1df38bdae2ee 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1471,11 +1471,17 @@ int macvlan_link_register(struct rtnl_link_ops *ops)
 };
 EXPORT_SYMBOL_GPL(macvlan_link_register);
 
+static struct net *macvlan_get_link_net(const struct net_device *dev)
+{
+	return dev_net(macvlan_dev_real_dev(dev));
+}
+
 static struct rtnl_link_ops macvlan_link_ops = {
 	.kind		= "macvlan",
 	.setup		= macvlan_setup,
 	.newlink	= macvlan_newlink,
 	.dellink	= macvlan_dellink,
+	.get_link_net	= macvlan_get_link_net,
 };
 
 static int macvlan_device_event(struct notifier_block *unused,
-- 
2.2.2
