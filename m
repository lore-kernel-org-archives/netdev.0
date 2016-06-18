From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 01/14] net: dsa: mv88e6xxx: fix style issues
Date: Fri, 17 Jun 2016 20:07:23 -0400
Message-ID: <20160618000736.5598-2-vivien.didelot@savoirfairelinux.com>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes 5 style problems reported by checkpatch:

    WARNING: suspect code indent for conditional statements (8, 24)
    #492: FILE: drivers/net/dsa/mv88e6xxx.c:492:
    +	if (phydev->link)
    +			reg |= PORT_PCS_CTRL_LINK_UP;

    CHECK: Logical continuations should be on the previous line
    #1318: FILE: drivers/net/dsa/mv88e6xxx.c:1318:
    +		     oldstate == PORT_CONTROL_STATE_FORWARDING)
    +		    && (state == PORT_CONTROL_STATE_DISABLED ||

    CHECK: multiple assignments should be avoided
    #1662: FILE: drivers/net/dsa/mv88e6xxx.c:1662:
    +		vlan->vid_begin = vlan->vid_end = next.vid;

    WARNING: line over 80 characters
    #2097: FILE: drivers/net/dsa/mv88e6xxx.c:2097:
    +				       const struct switchdev_obj_port_vlan *vlan,

    WARNING: suspect code indent for conditional statements (16, 32)
    #2734: FILE: drivers/net/dsa/mv88e6xxx.c:2734:
    +		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
    [...]
    +				reg |= PORT_CONTROL_EGRESS_ADD_TAG;

    total: 0 errors, 3 warnings, 2 checks, 3805 lines checked

It also rebases and integrates changes sent by Ben Dooks [1]:

    The driver has a number of functions that are not exported or
    declared elsewhere, so make them static to avoid the following
    warnings from sparse:

    drivers/net/dsa/mv88e6xxx.c:113:5: warning: symbol 'mv88e6xxx_reg_read' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:167:5: warning: symbol 'mv88e6xxx_reg_write' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:231:5: warning: symbol 'mv88e6xxx_set_addr' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:367:6: warning: symbol 'mv88e6xxx_ppu_state_init' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:3157:5: warning: symbol 'mv88e6xxx_phy_page_read' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:3169:5: warning: symbol 'mv88e6xxx_phy_page_write' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:3583:26: warning: symbol 'mv88e6xxx_switch_driver' was not declared. Should it be static?
    drivers/net/dsa/mv88e6xxx.c:3621:5: warning: symbol 'mv88e6xxx_probe' was not declared. Should it be static?

[1] http://patchwork.ozlabs.org/patch/632708/

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 42 +++++++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ee06055..1972ec5 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -111,7 +111,8 @@ static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
 	return ret;
 }
 
-int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg)
+static int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr,
+			      int reg)
 {
 	int ret;
 
@@ -165,8 +166,8 @@ static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
 	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
 }
 
-int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
-			int reg, u16 val)
+static int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+			       int reg, u16 val)
 {
 	int ret;
 
@@ -229,7 +230,7 @@ static int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 	return 0;
 }
 
-int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
+static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
@@ -370,7 +371,7 @@ static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
 	mutex_unlock(&ps->ppu_mutex);
 }
 
-void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
+static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 {
 	mutex_init(&ps->ppu_mutex);
 	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
@@ -490,7 +491,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 
 	reg |= PORT_PCS_CTRL_FORCE_LINK;
 	if (phydev->link)
-			reg |= PORT_PCS_CTRL_LINK_UP;
+		reg |= PORT_PCS_CTRL_LINK_UP;
 
 	if (mv88e6xxx_6065_family(ps) && phydev->speed > SPEED_100)
 		goto out;
@@ -1314,9 +1315,9 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
 		 * Blocking or Listening state.
 		 */
 		if ((oldstate == PORT_CONTROL_STATE_LEARNING ||
-		     oldstate == PORT_CONTROL_STATE_FORWARDING)
-		    && (state == PORT_CONTROL_STATE_DISABLED ||
-			state == PORT_CONTROL_STATE_BLOCKING)) {
+		     oldstate == PORT_CONTROL_STATE_FORWARDING) &&
+		    (state == PORT_CONTROL_STATE_DISABLED ||
+		     state == PORT_CONTROL_STATE_BLOCKING)) {
 			ret = _mv88e6xxx_atu_remove(ps, 0, port, false);
 			if (ret)
 				return ret;
@@ -1659,7 +1660,8 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 			continue;
 
 		/* reinit and dump this VLAN obj */
-		vlan->vid_begin = vlan->vid_end = next.vid;
+		vlan->vid_begin = next.vid;
+		vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
 		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
@@ -2093,9 +2095,10 @@ unlock:
 	return ret;
 }
 
-static int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
-				       const struct switchdev_obj_port_vlan *vlan,
-				       struct switchdev_trans *trans)
+static int
+mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_vlan *vlan,
+			    struct switchdev_trans *trans)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int err;
@@ -2735,7 +2738,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
 		    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
 		    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps)) {
-				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+			reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
 	if (dsa_is_dsa_port(ds, port)) {
@@ -3158,7 +3161,8 @@ unlock:
 	return err;
 }
 
-int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page, int reg)
+static int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page,
+				    int reg)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -3170,8 +3174,8 @@ int mv88e6xxx_mdio_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	return ret;
 }
 
-int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
-			      int reg, int val)
+static int mv88e6xxx_mdio_page_write(struct dsa_switch *ds, int port, int page,
+				     int reg, int val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
@@ -3650,7 +3654,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	return name;
 }
 
-struct dsa_switch_driver mv88e6xxx_switch_driver = {
+static struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6xxx_drv_probe,
 	.setup			= mv88e6xxx_setup,
@@ -3686,7 +3690,7 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.port_fdb_dump          = mv88e6xxx_port_fdb_dump,
 };
 
-int mv88e6xxx_probe(struct mdio_device *mdiodev)
+static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
-- 
2.8.3
