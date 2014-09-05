From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] bridge: implement rtnl_link_ops->get_slave_size and rtnl_link_ops->fill_slave_info
Date: Fri,  5 Sep 2014 15:51:29 +0200
Message-ID: <1409925092-17808-3-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:58356 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756701AbaIENvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:45 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so870683wib.15
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:44 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rtnetlink users to get port info in IFLA_INFO_SLAVE_DATA attr

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_netlink.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index cb5fcf6..80d2347 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -461,6 +461,19 @@ static int br_dev_newlink(struct net *src_net, struct net_device *dev,
 	return register_netdevice(dev);
 }
 
+static int br_port_fill_slave_info(struct sk_buff *skb,
+				   const struct net_device *brdev,
+				   const struct net_device *dev)
+{
+	return br_port_fill_attrs(skb, br_port_get_rtnl(dev));
+}
+
+static size_t br_port_get_slave_size(const struct net_device *brdev,
+				     const struct net_device *dev)
+{
+	return br_port_info_size();
+}
+
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
 	struct net_port_vlans *pv;
@@ -485,12 +498,14 @@ static struct rtnl_af_ops br_af_ops = {
 };
 
 struct rtnl_link_ops br_link_ops __read_mostly = {
-	.kind		= "bridge",
-	.priv_size	= sizeof(struct net_bridge),
-	.setup		= br_dev_setup,
-	.validate	= br_validate,
-	.newlink	= br_dev_newlink,
-	.dellink	= br_dev_delete,
+	.kind			= "bridge",
+	.priv_size		= sizeof(struct net_bridge),
+	.setup			= br_dev_setup,
+	.validate		= br_validate,
+	.newlink		= br_dev_newlink,
+	.dellink		= br_dev_delete,
+	.get_slave_size		= br_port_get_slave_size,
+	.fill_slave_info	= br_port_fill_slave_info,
 };
 
 int __init br_netlink_init(void)
-- 
1.9.3
