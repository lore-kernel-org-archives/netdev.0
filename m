From: Walter Lozano <walter@vanguardiasur.com.ar>
Subject: [PATCH net-next 2/2] Altera TSE: Add support for no PHY
Date: Fri,  3 Oct 2014 15:09:01 -0300
Message-ID: <1412359741-8423-3-git-send-email-walter@vanguardiasur.com.ar>
References: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Cc: davem@davemloft.net, tobias.klauser@gmail.com,
	vbridgers2013@gmail.com, f.fainelli@gmail.com,
	nios2-dev@lists.rocketboards.org, ezequiel@vanguardiasur.com.ar,
	guido@vanguardiasur.com.ar,
	Walter Lozano <walter@vanguardiasur.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:48063 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520AbaJCSKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 14:10:14 -0400
Received: by mail-qc0-f176.google.com with SMTP id r5so1381829qcx.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 11:10:13 -0700 (PDT)
In-Reply-To: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch avoids PHY and MDIO probing if no PHY chip is present.
This is the case mainly in optical links where there is no need for
PHY chip, and therefore no need of MDIO. In this scenario Ethernet
MAC is directly connected to an optical module through an external
SFP transceiver.

Signed-off-by: Walter Lozano <walter@vanguardiasur.com.ar>
---
 drivers/net/ethernet/altera/altera_tse_main.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index c85d029..b44a5f7 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -736,6 +736,10 @@ static int altera_tse_phy_get_addr_mdio_create(struct net_device *dev)
 
 	priv->phy_iface = of_get_phy_mode(np);
 
+	/* Avoid get phy addr and create mdio if no phy is present */
+	if (!priv->phy_iface)
+		return 0;
+
 	/* try to get PHY address from device tree, use PHY autodetection if
 	 * no valid address is given
 	 */
@@ -770,6 +774,10 @@ static int init_phy(struct net_device *dev)
 	struct phy_device *phydev;
 	struct device_node *phynode;
 
+	/* Avoid init phy in case of no phy present */
+	if (!priv->phy_iface)
+		return 0;
+
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
-- 
1.7.10.4
