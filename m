From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 07/24] net: rbridge: Add sysfs for trill_state
Date: Wed, 24 Sep 2014 17:52:03 +0200
Message-ID: <1411573940-14079-8-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:42739 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752968AbaIXP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:09 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in order to activate trill port without need for brctl
add a sysfs for trill_state for net_bridge_port

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_sysfs_if.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index e561cd5..6edc00b 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -137,6 +137,26 @@ static ssize_t show_port_state(struct net_bridge_port *p, char *buf)
 }
 static BRPORT_ATTR(state, S_IRUGO, show_port_state, NULL);
 
+#ifdef CONFIG_TRILL
+static ssize_t show_port_trill_state(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->trill_flag);
+}
+static int store_port_trill_state(struct net_bridge_port *p,  unsigned long v)
+{
+	uint8_t val;
+	if (!ns_capable(dev_net(p->dev)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+	val = (uint8_t) v;
+	if (val > TRILL_FLAG_TRUNK)
+		return -ERANGE;
+	p->trill_flag = val;
+	return 0;
+}
+static BRPORT_ATTR(trill_state, S_IRUGO | S_IWUSR, show_port_trill_state,
+				   store_port_trill_state);
+#endif
+
 static ssize_t show_message_age_timer(struct net_bridge_port *p,
 					    char *buf)
 {
@@ -198,6 +218,9 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_designated_port,
 	&brport_attr_designated_cost,
 	&brport_attr_state,
+#ifdef CONFIG_TRILL
+	&brport_attr_trill_state,
+#endif
 	&brport_attr_change_ack,
 	&brport_attr_config_pending,
 	&brport_attr_message_age_timer,
-- 
1.9.1
