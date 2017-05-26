From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: b53: remove unused dev argument
Date: Fri, 26 May 2017 18:07:37 -0400
Message-ID: <20170526220737.24579-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The port net device passed to b53_fdb_copy is not used. Remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index fa099ed41652..6a5648a9cb09 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1281,8 +1281,7 @@ static void b53_arl_search_rd(struct b53_device *dev, u8 idx,
 	b53_arl_to_entry(ent, mac_vid, fwd_entry);
 }
 
-static int b53_fdb_copy(struct net_device *dev, int port,
-			const struct b53_arl_entry *ent,
+static int b53_fdb_copy(int port, const struct b53_arl_entry *ent,
 			struct switchdev_obj_port_fdb *fdb,
 			switchdev_obj_dump_cb_t *cb)
 {
@@ -1304,7 +1303,6 @@ int b53_fdb_dump(struct dsa_switch *ds, int port,
 		 switchdev_obj_dump_cb_t *cb)
 {
 	struct b53_device *priv = ds->priv;
-	struct net_device *dev = ds->ports[port].netdev;
 	struct b53_arl_entry results[2];
 	unsigned int count = 0;
 	int ret;
@@ -1320,13 +1318,13 @@ int b53_fdb_dump(struct dsa_switch *ds, int port,
 			return ret;
 
 		b53_arl_search_rd(priv, 0, &results[0]);
-		ret = b53_fdb_copy(dev, port, &results[0], fdb, cb);
+		ret = b53_fdb_copy(port, &results[0], fdb, cb);
 		if (ret)
 			return ret;
 
 		if (priv->num_arl_entries > 2) {
 			b53_arl_search_rd(priv, 1, &results[1]);
-			ret = b53_fdb_copy(dev, port, &results[1], fdb, cb);
+			ret = b53_fdb_copy(port, &results[1], fdb, cb);
 			if (ret)
 				return ret;
 
-- 
2.13.0
