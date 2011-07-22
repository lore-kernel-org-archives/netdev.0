From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] bridge: minor cleanups
Date: Fri, 22 Jul 2011 10:47:10 -0700
Message-ID: <20110722174758.336432594@vyatta.com>
References: <20110722174705.144993799@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davmeloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46803 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab1GVRus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 13:50:48 -0400
Content-Disposition: inline; filename=bridge-deinline.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor cleanups that won't impact code:
  1. Remove inline from non-critical functions; compiler will most
     likely inline them anyway.
  2. Make function args const where possible.
  3. Whitespace cleanup

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/bridge/br_private_stp.h |    3 ++-
 net/bridge/br_stp.c         |   23 +++++++++++------------
 net/bridge/br_stp_bpdu.c    |    4 +---
 3 files changed, 14 insertions(+), 16 deletions(-)

--- a/net/bridge/br_stp.c	2011-07-22 08:23:29.059970391 -0700
+++ b/net/bridge/br_stp.c	2011-07-22 08:32:55.347949086 -0700
@@ -109,7 +109,6 @@ static void br_root_selection(struct net
 	list_for_each_entry(p, &br->port_list, list) {
 		if (br_should_become_root_port(p, root_port))
 			root_port = p->port_no;
-
 	}
 
 	br->root_port = root_port;
@@ -145,7 +144,6 @@ void br_transmit_config(struct net_bridg
 	struct br_config_bpdu bpdu;
 	struct net_bridge *br;
 
-
 	if (timer_pending(&p->hold_timer)) {
 		p->config_pending = 1;
 		return;
@@ -181,8 +179,8 @@ void br_transmit_config(struct net_bridg
 }
 
 /* called under bridge lock */
-static inline void br_record_config_information(struct net_bridge_port *p,
-						const struct br_config_bpdu *bpdu)
+static void br_record_config_information(struct net_bridge_port *p,
+					 const struct br_config_bpdu *bpdu)
 {
 	p->designated_root = bpdu->root;
 	p->designated_cost = bpdu->root_path_cost;
@@ -195,7 +193,7 @@ static inline void br_record_config_info
 }
 
 /* called under bridge lock */
-static inline void br_record_config_timeout_values(struct net_bridge *br,
+static void br_record_config_timeout_values(struct net_bridge *br,
 					    const struct br_config_bpdu *bpdu)
 {
 	br->max_age = bpdu->max_age;
@@ -254,7 +252,8 @@ static void br_designated_port_selection
 }
 
 /* called under bridge lock */
-static int br_supersedes_port_info(struct net_bridge_port *p, struct br_config_bpdu *bpdu)
+static int br_supersedes_port_info(const struct net_bridge_port *p,
+				   const struct br_config_bpdu *bpdu)
 {
 	int t;
 
@@ -285,7 +284,7 @@ static int br_supersedes_port_info(struc
 }
 
 /* called under bridge lock */
-static inline void br_topology_change_acknowledged(struct net_bridge *br)
+static void br_topology_change_acknowledged(struct net_bridge *br)
 {
 	br->topology_change_detected = 0;
 	del_timer(&br->tcn_timer);
@@ -327,7 +326,7 @@ void br_config_bpdu_generation(struct ne
 }
 
 /* called under bridge lock */
-static inline void br_reply(struct net_bridge_port *p)
+static void br_reply(struct net_bridge_port *p)
 {
 	br_transmit_config(p);
 }
@@ -381,8 +380,7 @@ static void br_make_forwarding(struct ne
 		p->state = BR_STATE_FORWARDING;
 		br_topology_change_detection(br);
 		del_timer(&p->forward_delay_timer);
-	}
-	else if (br->stp_enabled == BR_KERNEL_STP)
+	} else if (br->stp_enabled == BR_KERNEL_STP)
 		p->state = BR_STATE_LISTENING;
 	else
 		p->state = BR_STATE_LEARNING;
@@ -433,14 +431,15 @@ void br_port_state_selection(struct net_
 }
 
 /* called under bridge lock */
-static inline void br_topology_change_acknowledge(struct net_bridge_port *p)
+static void br_topology_change_acknowledge(struct net_bridge_port *p)
 {
 	p->topology_change_ack = 1;
 	br_transmit_config(p);
 }
 
 /* called under bridge lock */
-void br_received_config_bpdu(struct net_bridge_port *p, struct br_config_bpdu *bpdu)
+void br_received_config_bpdu(struct net_bridge_port *p,
+			     const struct br_config_bpdu *bpdu)
 {
 	struct net_bridge *br;
 	int was_root;
--- a/net/bridge/br_stp_bpdu.c	2011-07-22 08:23:29.043970390 -0700
+++ b/net/bridge/br_stp_bpdu.c	2011-07-22 08:31:50.571951522 -0700
@@ -222,9 +222,7 @@ void br_stp_rcv(const struct stp_proto *
 		}
 
 		br_received_config_bpdu(p, &bpdu);
-	}
-
-	else if (buf[0] == BPDU_TYPE_TCN) {
+	} else if (buf[0] == BPDU_TYPE_TCN) {
 		br_received_tcn_bpdu(p);
 	}
  out:
--- a/net/bridge/br_private_stp.h	2011-07-22 08:23:29.147970387 -0700
+++ b/net/bridge/br_private_stp.h	2011-07-22 08:33:35.611947572 -0700
@@ -56,7 +56,8 @@ extern void br_become_root_bridge(struct
 extern void br_config_bpdu_generation(struct net_bridge *);
 extern void br_configuration_update(struct net_bridge *);
 extern void br_port_state_selection(struct net_bridge *);
-extern void br_received_config_bpdu(struct net_bridge_port *p, struct br_config_bpdu *bpdu);
+extern void br_received_config_bpdu(struct net_bridge_port *p,
+				    const struct br_config_bpdu *bpdu);
 extern void br_received_tcn_bpdu(struct net_bridge_port *p);
 extern void br_transmit_config(struct net_bridge_port *p);
 extern void br_transmit_tcn(struct net_bridge *br);


