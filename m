From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: rename port_*_bridge routines
Date: Sun, 13 Mar 2016 16:21:32 -0400
Message-ID: <1457900494-10266-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename DSA port_join_bridge and port_leave_bridge routines to
respectively port_bridge_join and port_bridge_leave in order to respect
an implicit Port::Bridge namespace.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/networking/dsa/dsa.txt | 4 ++--
 drivers/net/dsa/bcm_sf2.c            | 4 ++--
 drivers/net/dsa/mv88e6171.c          | 4 ++--
 drivers/net/dsa/mv88e6352.c          | 4 ++--
 include/net/dsa.h                    | 4 ++--
 net/dsa/slave.c                      | 8 ++++----
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 974e9c3..3b196c3 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -521,12 +521,12 @@ See Documentation/hwmon/sysfs-interface for details.
 Bridge layer
 ------------
 
-- port_join_bridge: bridge layer function invoked when a given switch port is
+- port_bridge_join: bridge layer function invoked when a given switch port is
   added to a bridge, this function should be doing the necessary at the switch
   level to permit the joining port from being added to the relevant logical
   domain for it to ingress/egress traffic with other members of the bridge.
 
-- port_leave_bridge: bridge layer function invoked when a given switch port is
+- port_bridge_leave: bridge layer function invoked when a given switch port is
   removed from a bridge, this function should be doing the necessary at the
   switch level to deny the leaving port from ingress/egress traffic from the
   remaining bridge members. When the port leaves the bridge, it should be aged
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 3f62759..4bcc9eb 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1387,8 +1387,8 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_disable		= bcm_sf2_port_disable,
 	.get_eee		= bcm_sf2_sw_get_eee,
 	.set_eee		= bcm_sf2_sw_set_eee,
-	.port_join_bridge	= bcm_sf2_sw_br_join,
-	.port_leave_bridge	= bcm_sf2_sw_br_leave,
+	.port_bridge_join	= bcm_sf2_sw_br_join,
+	.port_bridge_leave	= bcm_sf2_sw_br_leave,
 	.port_stp_update	= bcm_sf2_sw_br_set_stp_state,
 	.port_fdb_prepare	= bcm_sf2_sw_fdb_prepare,
 	.port_fdb_add		= bcm_sf2_sw_fdb_add,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index d72ccbd..c0164b9 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -103,8 +103,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
-	.port_join_bridge	= mv88e6xxx_port_bridge_join,
-	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
+	.port_bridge_join	= mv88e6xxx_port_bridge_join,
+	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update        = mv88e6xxx_port_stp_update,
 	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index a41fa50..5f528ab 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -324,8 +324,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_eeprom		= mv88e6352_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
-	.port_join_bridge	= mv88e6xxx_port_bridge_join,
-	.port_leave_bridge	= mv88e6xxx_port_bridge_leave,
+	.port_bridge_join	= mv88e6xxx_port_bridge_join,
+	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
 	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 26c0a3f..004e034 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -296,9 +296,9 @@ struct dsa_switch_driver {
 	/*
 	 * Bridge integration
 	 */
-	int	(*port_join_bridge)(struct dsa_switch *ds, int port,
+	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
-	int	(*port_leave_bridge)(struct dsa_switch *ds, int port);
+	int	(*port_bridge_leave)(struct dsa_switch *ds, int port);
 	int	(*port_stp_update)(struct dsa_switch *ds, int port,
 				   u8 state);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 27bf03d..b997ee1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -448,8 +448,8 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 
 	p->bridge_dev = br;
 
-	if (ds->drv->port_join_bridge)
-		ret = ds->drv->port_join_bridge(ds, p->port, br);
+	if (ds->drv->port_bridge_join)
+		ret = ds->drv->port_bridge_join(ds, p->port, br);
 
 	return ret;
 }
@@ -461,8 +461,8 @@ static int dsa_slave_bridge_port_leave(struct net_device *dev)
 	int ret = -EOPNOTSUPP;
 
 
-	if (ds->drv->port_leave_bridge)
-		ret = ds->drv->port_leave_bridge(ds, p->port);
+	if (ds->drv->port_bridge_leave)
+		ret = ds->drv->port_bridge_leave(ds, p->port);
 
 	p->bridge_dev = NULL;
 
-- 
2.7.2
