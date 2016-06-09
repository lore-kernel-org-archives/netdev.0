From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/8] net: dsa: mv88e6xxx: fix style issues
Date: Wed,  8 Jun 2016 20:44:49 -0400
Message-ID: <20160609004456.5441-2-vivien.didelot@savoirfairelinux.com>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48680 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424875AbcFIAp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 20:45:28 -0400
In-Reply-To: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ee06055..6a2528f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -490,7 +490,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 
 	reg |= PORT_PCS_CTRL_FORCE_LINK;
 	if (phydev->link)
-			reg |= PORT_PCS_CTRL_LINK_UP;
+		reg |= PORT_PCS_CTRL_LINK_UP;
 
 	if (mv88e6xxx_6065_family(ps) && phydev->speed > SPEED_100)
 		goto out;
@@ -1314,9 +1314,9 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
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
@@ -1659,7 +1659,8 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 			continue;
 
 		/* reinit and dump this VLAN obj */
-		vlan->vid_begin = vlan->vid_end = next.vid;
+		vlan->vid_begin = next.vid;
+		vlan->vid_end = next.vid;
 		vlan->flags = 0;
 
 		if (next.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED)
@@ -2093,9 +2094,10 @@ unlock:
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
@@ -2735,7 +2737,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
 		    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
 		    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps)) {
-				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+			reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
 	if (dsa_is_dsa_port(ds, port)) {
-- 
2.8.3
