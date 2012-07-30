From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: make port attributes const
Date: Mon, 30 Jul 2012 11:55:49 -0700
Message-ID: <20120730115549.0d53d8cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41959 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206Ab2G3S4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 14:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple table that can be marked const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_sysfs_br.c |  136 +++++++++++++++++++++++------------------------
 net/bridge/br_sysfs_if.c |    6 +-
 3 files changed, 73 insertions(+), 71 deletions(-)

--- a/net/bridge/br_sysfs_if.c	2012-07-19 15:35:29.062250368 -0700
+++ b/net/bridge/br_sysfs_if.c	2012-07-19 15:36:10.843427691 -0700
@@ -27,7 +27,7 @@ struct brport_attribute {
 };
 
 #define BRPORT_ATTR(_name,_mode,_show,_store)		        \
-struct brport_attribute brport_attr_##_name = { 	        \
+const struct brport_attribute brport_attr_##_name = { 	        \
 	.attr = {.name = __stringify(_name), 			\
 		 .mode = _mode },				\
 	.show	= _show,					\
@@ -164,7 +164,7 @@ static BRPORT_ATTR(multicast_router, S_I
 		   store_multicast_router);
 #endif
 
-static struct brport_attribute *brport_attrs[] = {
+static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
 	&brport_attr_port_id,
@@ -241,7 +241,7 @@ const struct sysfs_ops brport_sysfs_ops
 int br_sysfs_addif(struct net_bridge_port *p)
 {
 	struct net_bridge *br = p->br;
-	struct brport_attribute **a;
+	const struct brport_attribute **a;
 	int err;
 
 	err = sysfs_create_link(&p->kobj, &br->dev->dev.kobj,
