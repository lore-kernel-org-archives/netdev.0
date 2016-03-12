From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net v2 2/4] net: mvneta: enable change MAC address when interface is up
Date: Sat, 12 Mar 2016 18:44:18 +0100
Message-ID: <1457804660-8463-3-git-send-email-gregory.clement@free-electrons.com>
References: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:54412 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752033AbcCLRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 12:44:37 -0500
In-Reply-To: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitri Epshtein <dima@marvell.com>

Function eth_prepare_mac_addr_change() is called as part of MAC
address change. This function check if interface is running.
To enable change MAC address when interface is running:
IFF_LIVE_ADDR_CHANGE flag must be set to dev->priv_flags field

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP
network unit")
Cc: stable@vger.kernel.org
Signed-off-by: Dmitri Epshtein <dima@marvell.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 8dc7df2edff6..2ee05cebea75 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3721,7 +3721,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
-	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
 	dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
 
 	err = register_netdev(dev);
-- 
2.5.0
