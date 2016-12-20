From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 06/10] net: netcp: ethss: get phy-handle only if link interface is MAC-to-PHY
Date: Tue, 20 Dec 2016 17:09:49 -0500
Message-ID: <1482271793-7671-7-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>, <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:61081 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936202AbcLTWKD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 17:10:03 -0500
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently to parse phy-handle, driver doesn't check if the interface is
MAC to PHY. This patch add this check for all MAC to PHY interface types
supported by the driver.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index cb48f88..9266961 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2956,7 +2956,9 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 	}
 
 	slave->open = false;
-	slave->phy_node = of_parse_phandle(node, "phy-handle", 0);
+	if ((slave->link_interface == SGMII_LINK_MAC_PHY) ||
+	    (slave->link_interface == XGMII_LINK_MAC_PHY))
+		slave->phy_node = of_parse_phandle(node, "phy-handle", 0);
 	slave->port_num = gbe_get_slave_port(gbe_dev, slave->slave_num);
 
 	if (slave->link_interface >= XGMII_LINK_MAC_PHY)
-- 
1.9.1
