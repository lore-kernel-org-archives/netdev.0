From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v2] net: netcp: remove call to netif_carrier_(on/off) for MAC to Phy interface
Date: Mon, 27 Apr 2015 14:12:43 -0400
Message-ID: <1430158363-26870-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently when interface type is MAC to Phy, netif_carrier_(on/off)
is called which is not needed as Phy lib already updates the carrier
status to net stack. This is needed only for other interface types

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 - v2: re-send to apply this on v4.1
 - Fixed comment against initial version
 - Ok to apply this to net-next. So changed subject prefix to reflect the same

 drivers/net/ethernet/ti/netcp_ethss.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 2bef655..9b7e0a3 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1765,7 +1765,9 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
 				     ALE_PORT_STATE,
 				     ALE_PORT_STATE_FORWARD);
 
-		if (ndev && slave->open)
+		if (ndev && slave->open &&
+		    slave->link_interface != SGMII_LINK_MAC_PHY &&
+		    slave->link_interface != XGMII_LINK_MAC_PHY)
 			netif_carrier_on(ndev);
 	} else {
 		writel(mac_control, GBE_REG_ADDR(slave, emac_regs,
@@ -1773,7 +1775,9 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
 		cpsw_ale_control_set(gbe_dev->ale, slave->port_num,
 				     ALE_PORT_STATE,
 				     ALE_PORT_STATE_DISABLE);
-		if (ndev)
+		if (ndev &&
+		    slave->link_interface != SGMII_LINK_MAC_PHY &&
+		    slave->link_interface != XGMII_LINK_MAC_PHY)
 			netif_carrier_off(ndev);
 	}
 
-- 
1.7.9.5
