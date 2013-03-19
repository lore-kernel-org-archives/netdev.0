From: Christophe Aeschlimann <aeschlimann@gmail.com>
Subject: [PATCH] ixp4xx_eth: set the device dma_coherent_mask
Date: Tue, 19 Mar 2013 16:59:25 +0100
Message-ID: <1363708765-20778-1-git-send-email-c.aeschlimann@acn-group.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without the mask it is impossible to take the network interface up
since it returns the following error:

> net eth1: coherent DMA mask is unset
> ifconfig: SIOCSIFFLAGS: Cannot allocate memory

Tested on an out-of-tree ixp425 based board.

Signed-off-by: Christophe Aeschlimann <c.aeschlimann@acn-group.ch>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 6958a5e..ff23c5c 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1398,6 +1398,7 @@ static int eth_init_one(struct platform_device *pdev)
 		return -ENOMEM;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
 	port = netdev_priv(dev);
 	port->netdev = dev;
 	port->id = pdev->id;
-- 
1.7.9
