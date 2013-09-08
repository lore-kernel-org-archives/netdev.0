From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [RFC PATCH 3/4] drivers: net: cpsw: use cpsw-phy-sel driver to configure phy mode
Date: Sun, 8 Sep 2013 16:53:57 +0530
Message-ID: <1378639438-27686-4-git-send-email-mugunthanvnm@ti.com>
References: <1378639438-27686-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zonque@gmail.com>, <davem@davemloft.net>, <bcousson@baylibre.com>,
	<tony@atomide.com>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:41035 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab3IHLY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Sep 2013 07:24:29 -0400
In-Reply-To: <1378639438-27686-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phy mode can be configured via the cpsw-phy-sel driver, this patch enabled the
cpsw driver to utilise the api provided by the cpsw-phy-sel driver to configure
the phy mode.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 01c42e1..5efb37b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1021,6 +1021,10 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		dev_info(priv->dev, "phy found : id is : 0x%x\n",
 			 slave->phy->phy_id);
 		phy_start(slave->phy);
+
+		/* Configure GMII_SEL register */
+		cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface,
+			     slave->slave_num);
 	}
 }
 
-- 
1.8.4
