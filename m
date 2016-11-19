From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 1/8] batman-adv: Return non-const ptr in batadv_getlink_net
Date: Sat, 19 Nov 2016 14:35:21 +0100
Message-ID: <20161119133528.1379-2-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49949 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752690AbcKSNfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:32 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@open-mesh.com>

The returned net_namespace of batadv_getlink_net may be used with functions
that potentially modify the struct. Thus it must return the pointer as
non-const like rtnl_link_ops::get_link_net does.

Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/hard-interface.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index a7a462e..fdbb47e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -92,8 +92,8 @@ batadv_hardif_get_by_netdev(const struct net_device *net_dev)
  *
  * Return: result of rtnl_link_ops->get_link_net or @fallback_net
  */
-static const struct net *batadv_getlink_net(const struct net_device *netdev,
-					    const struct net *fallback_net)
+static struct net *batadv_getlink_net(const struct net_device *netdev,
+				      struct net *fallback_net)
 {
 	if (!netdev->rtnl_link_ops)
 		return fallback_net;
@@ -116,9 +116,9 @@ static const struct net *batadv_getlink_net(const struct net_device *netdev,
  * Return: true if the devices are each others parent, otherwise false
  */
 static bool batadv_mutual_parents(const struct net_device *dev1,
-				  const struct net *net1,
+				  struct net *net1,
 				  const struct net_device *dev2,
-				  const struct net *net2)
+				  struct net *net2)
 {
 	int dev1_parent_iflink = dev_get_iflink(dev1);
 	int dev2_parent_iflink = dev_get_iflink(dev2);
@@ -154,7 +154,7 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 {
 	struct net *net = dev_net(net_dev);
 	struct net_device *parent_dev;
-	const struct net *parent_net;
+	struct net *parent_net;
 	bool ret;
 
 	/* check if this is a batman-adv mesh interface */
-- 
2.10.2
