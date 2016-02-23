From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH 2/2] net: qca_spi: clear IFF_TX_SKB_SHARING
Date: Tue, 23 Feb 2016 19:23:24 +0000
Message-ID: <1456255404-8668-2-git-send-email-stefan.wahren@i2se.com>
References: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Wahren <stefan.wahren@i2se.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ether_setup sets IFF_TX_SKB_SHARING but this is not supported by
qca_spi as it modifies the skb on xmit.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Fixes: 291ab06ecf67 (net: qualcomm: new Ethernet over SPI driver for QCA7000)
---
 drivers/net/ethernet/qualcomm/qca_spi.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index f2ee3e5f..1ef0393 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -811,6 +811,7 @@ qcaspi_netdev_setup(struct net_device *dev)
 	dev->netdev_ops = &qcaspi_netdev_ops;
 	qcaspi_set_ethtool_ops(dev);
 	dev->watchdog_timeo = QCASPI_TX_TIMEOUT;
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->tx_queue_len = 100;
 
 	qca = netdev_priv(dev);
-- 
1.7.9.5
