From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 04/18] net: mvpp2: move the mii configuration in the ndo_open path
Date: Mon, 24 Jul 2017 15:48:34 +0200
Message-ID: <20170724134848.19330-5-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47341 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753562AbdGXNuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:04 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the mii configuration in the ndo_open path, to allow handling
different mii configurations later and to switch between these
configurations at runtime.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 6ffff929b22a..9d204ffb9b89 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5862,6 +5862,7 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
 	/* Enable interrupts on all CPUs */
 	mvpp2_interrupts_enable(port);
 
+	mvpp2_port_mii_set(port);
 	mvpp2_port_enable(port);
 	phy_start(ndev->phydev);
 	netif_tx_start_all_queues(port->dev);
@@ -6626,7 +6627,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		goto err_free_stats;
 	}
 
-	mvpp2_port_mii_set(port);
 	mvpp2_port_periodic_xon_disable(port);
 
 	if (priv->hw_version == MVPP21)
-- 
2.13.3
