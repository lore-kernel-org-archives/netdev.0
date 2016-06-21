From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next] ti_cpsw: Check for disabled child nodes
Date: Tue, 21 Jun 2016 01:16:31 +0100
Message-ID: <1466468191.26723.19.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	CT kernel <linux-kernel@lists.codethink.co.uk>
To: Mugunthan V N <mugunthanvnm@ti.com>, Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:56279 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbcFUARc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 20:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dual MAC devices don't necessarily have both MACs wired up, so ignore
those that are disabled.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2023,7 +2023,7 @@ static int cpsw_probe_dt(struct cpsw_pri
 	if (ret)
 		dev_warn(&pdev->dev, "Doesn't have any child node\n");
 
-	for_each_child_of_node(node, slave_node) {
+	for_each_available_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const void *mac_addr = NULL;
 		int lenp;

-- 
Ben Hutchings
Software Developer, Codethink Ltd.
