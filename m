From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: switchdev: extract struct switchdev_obj_*
Date: Tue, 29 Sep 2015 11:16:52 -0400
Message-ID: <1443539812-2508-1-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1443539054-25997-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443539054-25997-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that switchdev and its drivers directly use specific switchdev_obj_*
structures, move them out of the switchdev_obj union and get rif of this
outer structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/switchdev.h | 53 ++++++++++++++++++++++++-------------------------
 1 file changed, 26 insertions(+), 27 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 230fcfc..8a3bacc 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -64,30 +64,29 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_PORT_FDB,
 };
 
-struct switchdev_obj {
-	enum switchdev_obj_id id;
-	int (*cb)(struct switchdev_obj *obj);
-	union {
-		struct switchdev_obj_vlan {		/* PORT_VLAN */
-			u16 flags;
-			u16 vid_begin;
-			u16 vid_end;
-		} vlan;
-		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
-			u32 dst;
-			int dst_len;
-			struct fib_info *fi;
-			u8 tos;
-			u8 type;
-			u32 nlflags;
-			u32 tb_id;
-		} ipv4_fib;
-		struct switchdev_obj_fdb {		/* PORT_FDB */
-			const unsigned char *addr;
-			u16 vid;
-			u16 ndm_state;
-		} fdb;
-	} u;
+/* SWITCHDEV_OBJ_PORT_VLAN */
+struct switchdev_obj_vlan {
+	u16 flags;
+	u16 vid_begin;
+	u16 vid_end;
+};
+
+/* SWITCHDEV_OBJ_IPV4_FIB */
+struct switchdev_obj_ipv4_fib {
+	u32 dst;
+	int dst_len;
+	struct fib_info *fi;
+	u8 tos;
+	u8 type;
+	u32 nlflags;
+	u32 tb_id;
+};
+
+/* SWITCHDEV_OBJ_PORT_FDB */
+struct switchdev_obj_fdb {
+	const unsigned char *addr;
+	u16 vid;
+	u16 ndm_state;
 };
 
 void switchdev_trans_item_enqueue(struct switchdev_trans *trans,
@@ -102,11 +101,11 @@ void *switchdev_trans_item_dequeue(struct switchdev_trans *trans);
  *
  * @switchdev_port_attr_set: Set a port attribute (see switchdev_attr).
  *
- * @switchdev_port_obj_add: Add an object to port (see switchdev_obj).
+ * @switchdev_port_obj_add: Add an object to port (see switchdev_obj_*).
  *
- * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj).
+ * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj_*).
  *
- * @switchdev_port_obj_dump: Dump port objects (see switchdev_obj).
+ * @switchdev_port_obj_dump: Dump port objects (see switchdev_obj_*).
  */
 struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
-- 
2.5.3
