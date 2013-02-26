From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] drivers: net: ethernet: cpsw: consider number of slaves in interation
Date: Tue, 26 Feb 2013 15:06:20 +0100
Message-ID: <1361887580-1770-1-git-send-email-zonque@gmail.com>
Cc: Daniel Mack <zonque@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56841 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122Ab3BZOQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 09:16:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make cpsw_add_default_vlan() look at the actual number of slaves for its
iteration, so boards with less than 2 slaves don't ooops at boot.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7e93df6..01ffbc4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -731,7 +731,7 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 
 	writel(vlan, &priv->host_port_regs->port_vlan);
 
-	for (i = 0; i < 2; i++)
+	for (i = 0; i < priv->data.slaves; i++)
 		slave_write(priv->slaves + i, vlan, reg);
 
 	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS << port,
-- 
1.8.1.2
