From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/16] batman-adv: Remove unused define BAT_ATTR_HIF_UINT
Date: Mon, 29 Oct 2012 09:58:04 +0100
Message-ID: <1351501097-1289-4-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54101 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab2J2I7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:00 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/sysfs.c | 49 -------------------------------------------------
 1 file changed, 49 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 66518c7..42cd09e 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -122,55 +122,6 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			   batadv_store_##_name)
 
 
-#define BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
-ssize_t batadv_store_##_name(struct kobject *kobj,			\
-			     struct attribute *attr, char *buff,	\
-			     size_t count)				\
-{									\
-	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
-	struct batadv_hard_iface *hard_iface;				\
-	ssize_t length;							\
-									\
-	hard_iface = batadv_hardif_get_by_netdev(net_dev);		\
-	if (!hard_iface)						\
-		return 0;						\
-									\
-	length = __batadv_store_uint_attr(buff, count, _min, _max,	\
-					  _post_func, attr,		\
-					  &hard_iface->_name, net_dev);	\
-									\
-	batadv_hardif_free_ref(hard_iface);				\
-	return length;							\
-}
-
-#define BATADV_ATTR_HIF_SHOW_UINT(_name)				\
-ssize_t batadv_show_##_name(struct kobject *kobj,			\
-			    struct attribute *attr, char *buff)		\
-{									\
-	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);	\
-	struct batadv_hard_iface *hard_iface;				\
-	ssize_t length;							\
-									\
-	hard_iface = batadv_hardif_get_by_netdev(net_dev);		\
-	if (!hard_iface)						\
-		return 0;						\
-									\
-	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_name));\
-									\
-	batadv_hardif_free_ref(hard_iface);				\
-	return length;							\
-}
-
-/* Use this, if you are going to set [name] in hard_iface to an
- * unsigned integer value
- */
-#define BATADV_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)	\
-	static BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)\
-	static BATADV_ATTR_HIF_SHOW_UINT(_name)				\
-	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
-			   batadv_store_##_name)
-
-
 static int batadv_store_bool_attr(char *buff, size_t count,
 				  struct net_device *net_dev,
 				  const char *attr_name, atomic_t *attr)
-- 
1.7.12.4
