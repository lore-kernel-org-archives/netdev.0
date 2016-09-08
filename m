From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v8 1/3] netdevice: Add offload statistics ndo
Date: Thu,  8 Sep 2016 08:19:51 +0200
Message-ID: <1473315593-2078-2-git-send-email-jiri@resnulli.us>
References: <1473315593-2078-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32857 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756354AbcIHGe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:34:27 -0400
Received: by mail-wm0-f66.google.com with SMTP id b187so2277771wme.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:34:26 -0700 (PDT)
In-Reply-To: <1473315593-2078-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a new ndo to return statistics for offloaded operation.
Since there can be many different offloaded operation with many
stats types, the ndo gets an attribute id by which it knows which
stats are wanted. The ndo also gets a void pointer to be cast according
to the attribute id.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 67bb978..2d2c09b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -924,6 +924,14 @@ struct netdev_xdp {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
+ * bool (*ndo_has_offload_stats)(int attr_id)
+ *	Return true if this device supports offload stats of this attr_id.
+ *
+ * int (*ndo_get_offload_stats)(int attr_id, const struct net_device *dev,
+ *	void *attr_data)
+ *	Get statistics for offload operations by attr_id. Write it into the
+ *	attr_data pointer.
+ *
  * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16 vid);
  *	If device supports VLAN filtering this function is called when a
  *	VLAN id is registered.
@@ -1155,6 +1163,10 @@ struct net_device_ops {
 
 	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
 						     struct rtnl_link_stats64 *storage);
+	bool			(*ndo_has_offload_stats)(int attr_id);
+	int			(*ndo_get_offload_stats)(int attr_id,
+							 const struct net_device *dev,
+							 void *attr_data);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
 	int			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
-- 
2.5.5
