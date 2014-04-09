From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual emac case also
Date: Wed, 9 Apr 2014 11:34:40 +0530
Message-ID: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60688 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbaDIGEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2014 02:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dual EMAC works with VLAN segregation of the ports, so default vlan needs
to be added in dual EMAC case else default vlan will be tagged for all
egress packets and vlan unaware switches/servers will drop packets
from the EVM.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5d5fec6..6133e4a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1201,8 +1201,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	for_each_slave(priv, cpsw_slave_open, priv);
 
 	/* Add default VLAN */
-	if (!priv->data.dual_emac)
-		cpsw_add_default_vlan(priv);
+	cpsw_add_default_vlan(priv);
 
 	if (!cpsw_common_res_usage_state(priv)) {
 		/* setup tx dma to fixed prio and zero offset */
-- 
1.9.0
