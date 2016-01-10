From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/8] switchdev: Adding MDB entry offload
Date: Sun, 10 Jan 2016 21:06:22 +0100
Message-ID: <1452456389-2833-2-git-send-email-jiri@resnulli.us>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37374 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757403AbcAJUGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:06:34 -0500
Received: by mail-wm0-f54.google.com with SMTP id f206so240618644wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:06:33 -0800 (PST)
In-Reply-To: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Define HW multicast entry: MAC and VID.
Using a MAC address simplifies support for both IPV4 and IPv6.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   | 11 +++++++++++
 net/switchdev/switchdev.c |  2 ++
 2 files changed, 13 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 603ae2f..d451122 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -68,6 +68,7 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_PORT_VLAN,
 	SWITCHDEV_OBJ_ID_IPV4_FIB,
 	SWITCHDEV_OBJ_ID_PORT_FDB,
+	SWITCHDEV_OBJ_ID_PORT_MDB,
 };
 
 struct switchdev_obj {
@@ -113,6 +114,16 @@ struct switchdev_obj_port_fdb {
 #define SWITCHDEV_OBJ_PORT_FDB(obj) \
 	container_of(obj, struct switchdev_obj_port_fdb, obj)
 
+/* SWITCHDEV_OBJ_ID_PORT_MDB */
+struct switchdev_obj_port_mdb {
+	struct switchdev_obj obj;
+	unsigned char addr[ETH_ALEN];
+	u16 vid;
+};
+
+#define SWITCHDEV_OBJ_PORT_MDB(obj) \
+	container_of(obj, struct switchdev_obj_port_mdb, obj)
+
 void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
 				  void *data, void (*destructor)(void const *),
 				  struct switchdev_trans_item *tritem);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index df790d3..ebc661d 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -345,6 +345,8 @@ static size_t switchdev_obj_size(const struct switchdev_obj *obj)
 		return sizeof(struct switchdev_obj_ipv4_fib);
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		return sizeof(struct switchdev_obj_port_fdb);
+	case SWITCHDEV_OBJ_ID_PORT_MDB:
+		return sizeof(struct switchdev_obj_port_mdb);
 	default:
 		BUG();
 	}
-- 
1.9.3
