From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 4/4] bridge: implement slave management
 operations
Date: Fri, 11 Feb 2011 16:23:47 +0100
Message-ID: <20110211152346.GD2763@psychotron.brq.redhat.com>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756711Ab1BKPXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 10:23:53 -0500
Content-Disposition: inline
In-Reply-To: <20110211152125.GA2763@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/bridge/br_device.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5564435..5648002 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -297,6 +297,46 @@ void br_netpoll_disable(struct net_bridge_port *p)
 
 #endif
 
+static int br_add_slave(struct net_device *dev, struct net_device *slave_dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return br_add_if(br, slave_dev);
+}
+
+static int br_del_slave(struct net_device *dev, struct net_device *slave_dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return br_del_if(br, slave_dev);
+}
+
+static int br_get_slave_count(const struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p;
+	int i = 0;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		i++;
+	}
+	return i;
+}
+
+static struct net_device *br_get_slave(const struct net_device *dev,
+				       int slave_index)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p;
+	int i = 0;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (slave_index == i++)
+			return p->dev;
+	}
+	return NULL;
+}
+
 static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
@@ -326,6 +366,10 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
 	.ndo_poll_controller	 = br_poll_controller,
 #endif
+	.ndo_add_slave		 = br_add_slave,
+	.ndo_del_slave		 = br_del_slave,
+	.ndo_get_slave_count	 = br_get_slave_count,
+	.ndo_get_slave		 = br_get_slave,
 };
 
 static void br_dev_free(struct net_device *dev)
-- 
1.7.3.4

