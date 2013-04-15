From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: ethernet: cpsw: get slave VLAN id from slave node instead of cpsw node
Date: Mon, 15 Apr 2013 23:01:28 +0530
Message-ID: <1366047088-7146-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	<mpfj-list@mimc.co.uk>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:53203 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755216Ab3DORbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 13:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dual EMAC slave VLAN id must be got from slave node instead of cpsw node as
VLAN id for each slave will be different.

Reported-by: Mark Jackson <mpfj-list@mimc.co.uk>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 80cad06..4781d3d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1380,7 +1380,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
 		if (data->dual_emac) {
-			if (of_property_read_u32(node, "dual_emac_res_vlan",
+			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
 						 &prop)) {
 				pr_err("Missing dual_emac_res_vlan in DT.\n");
 				slave_data->dual_emac_res_vlan = i+1;
-- 
1.7.9.5
