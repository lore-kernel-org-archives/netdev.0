From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] net: vlan: fix nlmsg size calculation in vlan_get_size()
Date: Mon,  7 Oct 2013 23:19:58 +0200
Message-ID: <1381180798-26654-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60915 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab3JGVUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 17:20:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the calculation of the nlmsg size, by adding the missing
nla_total_size().

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/8021q/vlan_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 3091297..c7e634a 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -171,7 +171,7 @@ static size_t vlan_get_size(const struct net_device *dev)
 
 	return nla_total_size(2) +	/* IFLA_VLAN_PROTOCOL */
 	       nla_total_size(2) +	/* IFLA_VLAN_ID */
-	       sizeof(struct ifla_vlan_flags) + /* IFLA_VLAN_FLAGS */
+	       nla_total_size(sizeof(struct ifla_vlan_flags)) + /* IFLA_VLAN_FLAGS */
 	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
 	       vlan_qos_map_size(vlan->nr_egress_mappings);
 }
-- 
1.8.4.rc3
