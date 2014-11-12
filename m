From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: pxa168_eth: move SET_NETDEV_DEV a bit earlier
Date: Wed, 12 Nov 2014 19:08:47 +0800
Message-ID: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <davem@davemloft.net>, <antoine.tenart@free-electrons.com>,
	<arnd@arndb.de>, <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to ensure the net_device's dev.parent is set before we used it
in dma_zalloc_coherent() from init_hash_table().

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 21ddece..38f7cee 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1540,8 +1540,8 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	if (err)
 		goto err_free_mdio;
 
-	pxa168_init_hw(pep);
 	SET_NETDEV_DEV(dev, &pdev->dev);
+	pxa168_init_hw(pep);
 	err = register_netdev(dev);
 	if (err)
 		goto err_mdiobus;
-- 
2.1.3
