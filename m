From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 5/7] net: mv643xx_eth: resume/suspend PHY on port start/stop
Date: Wed, 20 Nov 2013 21:21:51 +0100
Message-ID: <1384978913-8052-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network PHYs consume a noticable amount of power. This adds phy_resume
on port start and phy_suspend on port stop to save this power if the
port is down anyway. While at it, also properly start/stop the phy.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 00cd36e..55805b2 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2097,6 +2097,8 @@ static void port_start(struct mv643xx_eth_private *mp)
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
 		phy_reset(mp);
+		phy_resume(mp->phy);
+		phy_start(mp->phy);
 		mv643xx_eth_set_settings(mp->dev, &cmd);
 	}
 
@@ -2306,6 +2308,11 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	for (i = 0; i < mp->txq_count; i++)
 		txq_deinit(mp->txq + i);
 
+	if (mp->phy) {
+		phy_stop(mp->phy);
+		phy_suspend(mp->phy);
+	}
+
 	return 0;
 }
 
-- 
1.7.2.5
