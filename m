From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: use hlist_for_each_entry()
Date: Fri, 30 Oct 2009 09:37:49 +0100
Message-ID: <4AEAA5DD.3040704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58191 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbZJ3Ihr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small cleanup of __dev_get_by_name() and __dev_get_by_index()
to use hlist_for_each_entry() : They'll look like their _rcu variant.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 631cc40..94f42a1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -587,13 +587,13 @@ __setup("netdev=", netdev_boot_setup);
 struct net_device *__dev_get_by_name(struct net *net, const char *name)
 {
 	struct hlist_node *p;
+	struct net_device *dev;
+	struct hlist_head *head = dev_name_hash(net, name);
 
-	hlist_for_each(p, dev_name_hash(net, name)) {
-		struct net_device *dev
-			= hlist_entry(p, struct net_device, name_hlist);
+	hlist_for_each_entry(dev, p, head, name_hlist)
 		if (!strncmp(dev->name, name, IFNAMSIZ))
 			return dev;
-	}
+
 	return NULL;
 }
 EXPORT_SYMBOL(__dev_get_by_name);
@@ -638,13 +638,13 @@ EXPORT_SYMBOL(dev_get_by_name);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex)
 {
 	struct hlist_node *p;
+	struct net_device *dev;
+	struct hlist_head *head = dev_index_hash(net, ifindex);
 
-	hlist_for_each(p, dev_index_hash(net, ifindex)) {
-		struct net_device *dev
-			= hlist_entry(p, struct net_device, index_hlist);
+	hlist_for_each_entry(dev, p, head, index_hlist)
 		if (dev->ifindex == ifindex)
 			return dev;
-	}
+
 	return NULL;
 }
 EXPORT_SYMBOL(__dev_get_by_index);
