From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: mv643xx_eth: fix DT port device name
Date: Sun,  7 Jul 2013 22:33:51 +0200
Message-ID: <1373229231-8838-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Jonas Gorski <jogo@openwrt.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Device tree support added to Marvell MV643xx ethernet driver registers
port devices from port device nodes found on the corresponding controller
node. The current port device name will cause the second controller to
fail on registration because of two identical device names. This fixes
the issue by taking the device node's name also as port device name.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Reported-by: Jonas Gorski <jogo@openwrt.org>
---
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jonas Gorski <jogo@openwrt.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 6495bea..1f3a03d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2521,7 +2521,7 @@ static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
 		of_property_read_u32(pnp, "duplex", &ppd.duplex);
 	}
 
-	ppdev = platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number);
+	ppdev = platform_device_alloc(pnp->name, ppd.port_number);
 	if (!ppdev)
 		return -ENOMEM;
 	ppdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
-- 
1.7.10.4
