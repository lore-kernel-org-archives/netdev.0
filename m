From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/3] bonding: convert 3ad to use pr_warn instead of pr_warning
Date: Wed,  8 Jan 2014 16:46:47 +0100
Message-ID: <1389196008-28578-3-git-send-email-vfalico@redhat.com>
References: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756086AbaAHPvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 10:51:06 -0500
In-Reply-To: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 50 +++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 9828209..7118eef 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1318,11 +1318,11 @@ static void ad_port_selection_logic(struct port *port)
 			/* meaning: the port was related to an aggregator
 			 * but was not on the aggregator port list
 			 */
-			pr_warning("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
-				   port->slave->bond->dev->name,
-				   port->actor_port_number,
-				   port->slave->dev->name,
-				   port->aggregator->aggregator_identifier);
+			pr_warn("%s: Warning: Port %d (on %s) was related to aggregator %d but was not on its port list\n",
+				port->slave->bond->dev->name,
+				port->actor_port_number,
+				port->slave->dev->name,
+				port->aggregator->aggregator_identifier);
 		}
 	}
 	/* search on all aggregators for a suitable aggregator for this port */
@@ -1479,9 +1479,9 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 		break;
 
 	default:
-		pr_warning("%s: Impossible agg select mode %d\n",
-			   curr->slave->bond->dev->name,
-			   __get_agg_selection_mode(curr->lag_ports));
+		pr_warn("%s: Impossible agg select mode %d\n",
+			curr->slave->bond->dev->name,
+			__get_agg_selection_mode(curr->lag_ports));
 		break;
 	}
 
@@ -1594,7 +1594,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 
 		/* check if any partner replys */
 		if (best->is_individual) {
-			pr_warning("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
+			pr_warn("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
 				best->slave ?
 				best->slave->bond->dev->name : "NULL");
 		}
@@ -1986,8 +1986,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warning("Warning: %s: Trying to unbind an uninitialized port on %s\n",
-			   slave->bond->dev->name, slave->dev->name);
+		pr_warn("Warning: %s: Trying to unbind an uninitialized port on %s\n",
+			slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
@@ -2064,8 +2064,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				if (select_new_active_agg)
 					ad_agg_selection_logic(__get_first_agg(port));
 			} else {
-				pr_warning("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
-					   slave->bond->dev->name);
+				pr_warn("%s: Warning: unbinding aggregator, and could not find a new aggregator for its ports\n",
+					slave->bond->dev->name);
 			}
 		} else {
 			/* in case that the only port related to this
@@ -2158,8 +2158,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		/* select the active aggregator for the bond */
 		if (port) {
 			if (!port->slave) {
-				pr_warning("%s: Warning: bond's first port is uninitialized\n",
-					   bond->dev->name);
+				pr_warn("%s: Warning: bond's first port is uninitialized\n",
+					bond->dev->name);
 				goto re_arm;
 			}
 
@@ -2173,8 +2173,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (!port->slave) {
-			pr_warning("%s: Warning: Found an uninitialized port\n",
-				   bond->dev->name);
+			pr_warn("%s: Warning: Found an uninitialized port\n",
+				bond->dev->name);
 			goto re_arm;
 		}
 
@@ -2224,8 +2224,8 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 		port = &(SLAVE_AD_INFO(slave).port);
 
 		if (!port->slave) {
-			pr_warning("%s: Warning: port of slave %s is uninitialized\n",
-				   slave->dev->name, slave->bond->dev->name);
+			pr_warn("%s: Warning: port of slave %s is uninitialized\n",
+				slave->dev->name, slave->bond->dev->name);
 			return ret;
 		}
 
@@ -2282,8 +2282,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warning("Warning: %s: speed changed for uninitialized port on %s\n",
-			   slave->bond->dev->name, slave->dev->name);
+		pr_warn("Warning: %s: speed changed for uninitialized port on %s\n",
+			slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
@@ -2315,8 +2315,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warning("%s: Warning: duplex changed for uninitialized port on %s\n",
-			   slave->bond->dev->name, slave->dev->name);
+		pr_warn("%s: Warning: duplex changed for uninitialized port on %s\n",
+			slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
@@ -2349,8 +2349,8 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		pr_warning("Warning: %s: link status changed for uninitialized port on %s\n",
-			   slave->bond->dev->name, slave->dev->name);
+		pr_warn("Warning: %s: link status changed for uninitialized port on %s\n",
+			slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
-- 
1.8.4
