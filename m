From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 1/6] net: dsa: add port_fdb_dump function
Date: Tue, 20 Oct 2015 12:17:21 -0400
Message-ID: <1445357846-25720-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all switch chips support a Get Next operation to iterate on its FDB.
So add a more simple port_fdb_dump function for them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 4 ++++
 net/dsa/slave.c   | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index e005886..0cfa44a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -198,6 +198,7 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 }
 
 struct switchdev_trans;
+struct switchdev_obj;
 struct switchdev_obj_port_fdb;
 
 struct dsa_switch_driver {
@@ -330,6 +331,9 @@ struct dsa_switch_driver {
 	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
 				    unsigned char *addr, u16 *vid,
 				    bool *is_static);
+	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
+				 struct switchdev_obj_port_fdb *fdb,
+				 int (*cb)(struct switchdev_obj *obj));
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b0b8da0..d76e62b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -382,6 +382,9 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 	u16 vid = 0;
 	int ret;
 
+	if (ds->drv->port_fdb_dump)
+		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
+
 	if (!ds->drv->port_fdb_getnext)
 		return -EOPNOTSUPP;
 
-- 
2.6.1
