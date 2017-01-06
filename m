From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 4/8] net: netcp: ethss: get phy-handle only if link interface is MAC-to-PHY
Date: Fri, 6 Jan 2017 15:37:42 -0500
Message-ID: <1483735066-14632-5-git-send-email-m-karicheri2@ti.com>
References: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:11786 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760466AbdAFUhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:37:52 -0500
In-Reply-To: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
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
index 7d9e36f..4a64b3e 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2930,7 +2930,9 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
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
