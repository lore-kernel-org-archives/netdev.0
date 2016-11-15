From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: ethernet: mvneta: Implement ethtool::nway_reset
Date: Tue, 15 Nov 2016 11:19:47 -0800
Message-ID: <20161115191949.15361-4-f.fainelli@gmail.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115191949.15361-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement ethtool::nway_reset using phy_ethtool_nway_reset. We are
already using dev->phydev all over the place so this comes for free.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b85819ea8eea..87274d4ab102 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3811,6 +3811,7 @@ static const struct net_device_ops mvneta_netdev_ops = {
 };
 
 const struct ethtool_ops mvneta_eth_tool_ops = {
+	.nway_reset	= phy_ethtool_nway_reset,
 	.get_link       = ethtool_op_get_link,
 	.set_coalesce   = mvneta_ethtool_set_coalesce,
 	.get_coalesce   = mvneta_ethtool_get_coalesce,
-- 
2.9.3
