From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH 1/2] net: qca_spi: Don't clear IFF_BROADCAST
Date: Tue, 23 Feb 2016 19:23:23 +0000
Message-ID: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently qcaspi_netdev_setup accidentally clears IFF_BROADCAST.
So fix this by keeping the flags from ether_setup.

Reported-by: Michael Heimpold <michael.heimpold@i2se.com>
Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Fixes: 291ab06ecf67 (net: qualcomm: new Ethernet over SPI driver for QCA7000)
---
 drivers/net/ethernet/qualcomm/qca_spi.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 689a4a5..f2ee3e5f 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -811,7 +811,6 @@ qcaspi_netdev_setup(struct net_device *dev)
 	dev->netdev_ops = &qcaspi_netdev_ops;
 	qcaspi_set_ethtool_ops(dev);
 	dev->watchdog_timeo = QCASPI_TX_TIMEOUT;
-	dev->flags = IFF_MULTICAST;
 	dev->tx_queue_len = 100;
 
 	qca = netdev_priv(dev);
-- 
1.7.9.5
