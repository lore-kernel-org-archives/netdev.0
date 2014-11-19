From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH 1/2] bonding: change AD_LINK_SPEED_BITMASK to enum to suport more speed
Date: Wed, 19 Nov 2014 16:48:58 +0800
Message-ID: <1416386939-24591-2-git-send-email-Jianhua.Xie@freescale.com>
References: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jianhua Xie <Jianhua.Xie@freescale.com>,
	Jianhua Xie <jianhua.xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0146.outbound.protection.outlook.com ([207.46.100.146]:38544
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750821AbaKSIuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 03:50:32 -0500
In-Reply-To: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

Port Key was determined as 16 bits according to the link speed,
duplex and user key (which is yet not supported).  In the old
speed field, 5 bits are for speed [1|10|100|1000|10000]Mbps as
below:
--------------------------------------------------------------
Port key :| User key        | Speed         |       Duplex|
--------------------------------------------------------------
    16                  6               1               0
This patch keeps the old layout, but changes AD_LINK_SPEED_BITMASK
from bit type to an enum type.  In this way, the speed field can
expand speed type from 5 to 32.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---
 drivers/net/bonding/bond_3ad.c | 66 ++++++++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 32 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 0a32143..6bc27d9 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -79,15 +79,17 @@
  * --------------------------------------------------------------
  * 16		  6		  1		  0
  */
-#define  AD_DUPLEX_KEY_BITS    0x1
-#define  AD_SPEED_KEY_BITS     0x3E
-#define  AD_USER_KEY_BITS      0xFFC0
-
-#define     AD_LINK_SPEED_BITMASK_1MBPS       0x1
-#define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
-#define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
-#define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
-#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
+#define  AD_DUPLEX_KEY_MASKS    0x1
+#define  AD_SPEED_KEY_MASKS     0x3E
+#define  AD_USER_KEY_MASKS      0xFFC0
+
+enum ad_link_speed_type {
+	AD_LINK_SPEED_1MBPS = 1,
+	AD_LINK_SPEED_10MBPS,
+	AD_LINK_SPEED_100MBPS,
+	AD_LINK_SPEED_1000MBPS,
+	AD_LINK_SPEED_10000MBPS
+};
 
 /* compare MAC addresses */
 #define MAC_ADDRESS_EQUAL(A, B)	\
@@ -240,12 +242,12 @@ static inline int __check_agg_selection_timer(struct port *port)
  * __get_link_speed - get a port's speed
  * @port: the port we're looking at
  *
- * Return @port's speed in 802.3ad bitmask format. i.e. one of:
+ * Return @port's speed in 802.3ad enum format. i.e. one of:
  *     0,
- *     %AD_LINK_SPEED_BITMASK_10MBPS,
- *     %AD_LINK_SPEED_BITMASK_100MBPS,
- *     %AD_LINK_SPEED_BITMASK_1000MBPS,
- *     %AD_LINK_SPEED_BITMASK_10000MBPS
+ *     %AD_LINK_SPEED_10MBPS,
+ *     %AD_LINK_SPEED_100MBPS,
+ *     %AD_LINK_SPEED_1000MBPS,
+ *     %AD_LINK_SPEED_10000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -262,19 +264,19 @@ static u16 __get_link_speed(struct port *port)
 	else {
 		switch (slave->speed) {
 		case SPEED_10:
-			speed = AD_LINK_SPEED_BITMASK_10MBPS;
+			speed = AD_LINK_SPEED_10MBPS;
 			break;
 
 		case SPEED_100:
-			speed = AD_LINK_SPEED_BITMASK_100MBPS;
+			speed = AD_LINK_SPEED_100MBPS;
 			break;
 
 		case SPEED_1000:
-			speed = AD_LINK_SPEED_BITMASK_1000MBPS;
+			speed = AD_LINK_SPEED_1000MBPS;
 			break;
 
 		case SPEED_10000:
-			speed = AD_LINK_SPEED_BITMASK_10000MBPS;
+			speed = AD_LINK_SPEED_10000MBPS;
 			break;
 
 		default:
@@ -625,19 +627,19 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 
 	if (aggregator->num_of_ports) {
 		switch (__get_link_speed(aggregator->lag_ports)) {
-		case AD_LINK_SPEED_BITMASK_1MBPS:
+		case AD_LINK_SPEED_1MBPS:
 			bandwidth = aggregator->num_of_ports;
 			break;
-		case AD_LINK_SPEED_BITMASK_10MBPS:
+		case AD_LINK_SPEED_10MBPS:
 			bandwidth = aggregator->num_of_ports * 10;
 			break;
-		case AD_LINK_SPEED_BITMASK_100MBPS:
+		case AD_LINK_SPEED_100MBPS:
 			bandwidth = aggregator->num_of_ports * 100;
 			break;
-		case AD_LINK_SPEED_BITMASK_1000MBPS:
+		case AD_LINK_SPEED_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
-		case AD_LINK_SPEED_BITMASK_10000MBPS:
+		case AD_LINK_SPEED_10000MBPS:
 			bandwidth = aggregator->num_of_ports * 10000;
 			break;
 		default:
@@ -1011,7 +1013,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			 port->sm_rx_state);
 		switch (port->sm_rx_state) {
 		case AD_RX_INITIALIZE:
-			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
+			if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS))
 				port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 			else
 				port->sm_vars |= AD_PORT_LACP_ENABLED;
@@ -1318,7 +1320,7 @@ static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
 			/* update the new aggregator's parameters
 			 * if port was responsed from the end-user
 			 */
-			if (port->actor_oper_port_key & AD_DUPLEX_KEY_BITS)
+			if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
 				/* if port is full duplex */
 				port->aggregator->is_individual = false;
 			else
@@ -1846,7 +1848,7 @@ void bond_3ad_bind_slave(struct slave *slave)
 		/* if the port is not full duplex, then the port should be not
 		 * lacp Enabled
 		 */
-		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_BITS))
+		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS))
 			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 		/* actor system is the bond's system */
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
@@ -2214,7 +2216,7 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	spin_lock_bh(&slave->bond->mode_lock);
 
-	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
+	port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		(__get_link_speed(port) << 1);
 	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
@@ -2247,7 +2249,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	spin_lock_bh(&slave->bond->mode_lock);
 
-	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
+	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		__get_duplex(port);
 	netdev_dbg(slave->bond->dev, "Port %d changed duplex\n", port->actor_port_number);
@@ -2289,18 +2291,18 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	 */
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
-		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
+		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
 		port->actor_oper_port_key = port->actor_admin_port_key |=
 			__get_duplex(port);
-		port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
+		port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
 		port->actor_oper_port_key = port->actor_admin_port_key |=
 			(__get_link_speed(port) << 1);
 	} else {
 		/* link has failed */
 		port->is_enabled = false;
-		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
+		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
-					     ~AD_SPEED_KEY_BITS);
+					     ~AD_SPEED_KEY_MASKS);
 	}
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
-- 
2.1.0.27.g96db324
