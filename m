From: yegorslists@googlemail.com
Subject: [PATCH] net: cpsw: fix dual_emac VLAN issue
Date: Tue,  8 Apr 2014 16:58:30 +0200
Message-ID: <1396969110-3114-2-git-send-email-yegorslists@googlemail.com>
References: <1396969110-3114-1-git-send-email-yegorslists@googlemail.com>
Cc: mugunthanvnm@ti.com, Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hhlx01.visionsystems.de ([62.145.30.242]:53217 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbaDHO6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 10:58:54 -0400
In-Reply-To: <1396969110-3114-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

CPSW shows following behavior: some stations in LAN don't
answer CPSW's ARP request. Kernel 3.2 could talk to all stations in
the same LAN.

Use the same cpsw_ale_add_vlan procedure as in kernel 3.2.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 drivers/net/ethernet/ti/cpsw.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5d5fec6..aa06370 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1040,11 +1040,13 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 	else
 		slave_write(slave, slave->port_vlan, CPSW2_PORT_VLAN);
 	cpsw_ale_add_vlan(priv->ale, slave->port_vlan, port_mask,
-			  port_mask, port_mask, 0);
+			  0, port_mask, port_mask);
 	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 			   port_mask, ALE_VLAN, slave->port_vlan, 0);
 	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
 		priv->host_port, ALE_VLAN, slave->port_vlan);
+	cpsw_ale_add_vlan(priv->ale, 0, ALE_ALL_PORTS << priv->host_port,
+		ALE_ALL_PORTS << priv->host_port, priv->host_port, 0);
 }
 
 static void soft_reset_slave(struct cpsw_slave *slave)
-- 
1.7.7
