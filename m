From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/7] net: dsa: remove name arg from slave create
Date: Fri, 27 Oct 2017 15:55:19 -0400
Message-ID: <20171027195519.5931-8-vivien.didelot@savoirfairelinux.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that slave dsa_port always have their name set, there is no need to
pass it to dsa_slave_create() anymore. Remove this argument.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c     | 3 +--
 net/dsa/dsa_priv.h | 2 +-
 net/dsa/legacy.c   | 2 +-
 net/dsa/slave.c    | 3 ++-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index f32fc0cd1bfe..bf4a39b93fb9 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -257,10 +257,9 @@ static void dsa_cpu_port_unapply(struct dsa_port *port)
 static int dsa_user_port_apply(struct dsa_port *port)
 {
 	struct dsa_switch *ds = port->ds;
-	const char *name = port->name;
 	int err;
 
-	err = dsa_slave_create(port, name);
+	err = dsa_slave_create(port);
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
 			 port->index, err);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1e9914062d0b..6d775a137082 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -162,7 +162,7 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-int dsa_slave_create(struct dsa_port *port, const char *name);
+int dsa_slave_create(struct dsa_port *dp);
 void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 3b50a5da0401..1b5405ff02d5 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -197,7 +197,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		if (dsa_is_user_port(ds, i))
 			continue;
 
-		ret = dsa_slave_create(&ds->ports[i], cd->port_names[i]);
+		ret = dsa_slave_create(&ds->ports[i]);
 		if (ret < 0)
 			netdev_err(master, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, cd->port_names[i], ret);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 808e205227c3..48b954a76b0d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1142,11 +1142,12 @@ static void dsa_slave_notify(struct net_device *dev, unsigned long val)
 	call_dsa_notifiers(val, dev, &rinfo.info);
 }
 
-int dsa_slave_create(struct dsa_port *port, const char *name)
+int dsa_slave_create(struct dsa_port *port)
 {
 	struct dsa_port *cpu_dp = port->cpu_dp;
 	struct net_device *master = cpu_dp->master;
 	struct dsa_switch *ds = port->ds;
+	const char *name = port->name;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
 	int ret;
-- 
2.14.3
