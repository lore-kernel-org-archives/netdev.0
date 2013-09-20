From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 3/4] drivers: net: cpsw: use cpsw-phy-sel driver to configure phy mode
Date: Sat, 21 Sep 2013 00:50:40 +0530
Message-ID: <1379704841-32693-4-git-send-email-mugunthanvnm@ti.com>
References: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zonque@gmail.com>, <davem@davemloft.net>, <bcousson@baylibre.com>,
	<tony@atomide.com>, <devicetree@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:55699 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789Ab3ITTVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 15:21:52 -0400
In-Reply-To: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phy mode can be configured via the cpsw-phy-sel driver, this patch enabled the
cpsw driver to utilise the api provided by the cpsw-phy-sel driver to configure
the phy mode.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Tested-by: Daniel Mack <zonque@gmail.com>
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
