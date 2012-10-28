From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 03/16] batman-adv: separate BATADV_ATTR_HIF_UINT sysfs name from hard-iface variable
Date: Sun, 28 Oct 2012 12:17:04 +0100
Message-ID: <1351423037-5292-4-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:55467 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2J1LSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:15 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/sysfs.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 66518c7..fa6c8b1 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -122,7 +122,7 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			   batadv_store_##_name)
 
 
-#define BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
+#define BATADV_ATTR_HIF_STORE_UINT(_name, _var, _min, _max, _post_func)	\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
 			     struct attribute *attr, char *buff,	\
 			     size_t count)				\
@@ -137,13 +137,13 @@ ssize_t batadv_store_##_name(struct kobject *kobj,			\
 									\
 	length = __batadv_store_uint_attr(buff, count, _min, _max,	\
 					  _post_func, attr,		\
-					  &hard_iface->_name, net_dev);	\
+					  &hard_iface->_var, net_dev);	\
 									\
 	batadv_hardif_free_ref(hard_iface);				\
 	return length;							\
 }
 
-#define BATADV_ATTR_HIF_SHOW_UINT(_name)				\
+#define BATADV_ATTR_HIF_SHOW_UINT(_name, _var)				\
 ssize_t batadv_show_##_name(struct kobject *kobj,			\
 			    struct attribute *attr, char *buff)		\
 {									\
@@ -155,7 +155,7 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 	if (!hard_iface)						\
 		return 0;						\
 									\
-	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_name));\
+	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_var));	\
 									\
 	batadv_hardif_free_ref(hard_iface);				\
 	return length;							\
@@ -164,9 +164,10 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 /* Use this, if you are going to set [name] in hard_iface to an
  * unsigned integer value
  */
-#define BATADV_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)	\
-	static BATADV_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)\
-	static BATADV_ATTR_HIF_SHOW_UINT(_name)				\
+#define BATADV_ATTR_HIF_UINT(_name, _var, _mode, _min, _max, _post_func)\
+	static BATADV_ATTR_HIF_STORE_UINT(_name, _var, _min,		\
+					  _max, _post_func)		\
+	static BATADV_ATTR_HIF_SHOW_UINT(_name, _var)			\
 	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
 			   batadv_store_##_name)
 
-- 
1.7.12.4
