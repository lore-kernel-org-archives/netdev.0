From: yegorslists@googlemail.com
Subject: [PATCH v2] net: cpsw: fix dual_emac VLAN issue
Date: Wed,  9 Apr 2014 14:53:43 +0200
Message-ID: <1397048023-10522-1-git-send-email-yegorslists@googlemail.com>
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hhlx01.visionsystems.de ([62.145.30.242]:50056 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbaDIMyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 08:54:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

dual_emac mode was first introduced in TI's PSP kernel 3.2.
See repository git://arago-project.org/git/projects/linux-am33x.git
commit 6afa003a0b06a0376c941436b38204ba2edc4a98.

Since commit d9ba8f9e6298af71ec1c1fd3d88c3ef68abd0ec3 dual_emac
feature was upstreamed, but with some changes compared to the original
source, that led to following behavior:

Some stations in LAN don't answer CPSW's ARP request. PSP kernel 3.2
could talk to all stations in the same LAN.

Use the same cpsw_ale_add_vlan procedure as in PSP kernel 3.2 to fix
this regression.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
CC: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes:
	v2: make more detailed description

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
