From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH 1/2] net: ethernet: cpsw: Search childs for slave nodes
Date: Fri,  4 Oct 2013 14:44:39 +0200
Message-ID: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Cc: Florian Fainelli <florian@openwrt.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Markus Pargmann <mpa@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34225 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036Ab3JDMpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 08:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation searches the whole DT for nodes named
"slave".

This patch changes it to search only child nodes for slaves.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 79974e3..5df50a9 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1782,7 +1782,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	if (ret)
 		pr_warn("Doesn't have any child node\n");
 
-	for_each_node_by_name(slave_node, "slave") {
+	for_each_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const void *mac_addr = NULL;
 		u32 phyid;
@@ -1791,6 +1791,10 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		struct device_node *mdio_node;
 		struct platform_device *mdio;
 
+		/* This is no slave child node, continue */
+		if (strcmp(slave_node->name, "slave"))
+			continue;
+
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
 			pr_err("Missing slave[%d] phy_id property\n", i);
-- 
1.8.4.rc3
