From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH 3/3] net: mv643xx_eth: fix missing device_node for port devices
Date: Wed,  2 Oct 2013 12:57:22 +0200
Message-ID: <1380711442-24735-4-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:36044 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab3JBK5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 06:57:50 -0400
In-Reply-To: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DT-based mv643xx_eth probes and creates platform_devices for the
port devices on its own. To allow fixups for ports based on the
device_node, we need to set .of_node of the corresponding device
with the correct node.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2364707..2c210ec 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2533,6 +2533,7 @@ static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
 	if (!ppdev)
 		return -ENOMEM;
 	ppdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	ppdev->dev.of_node = pnp;
 
 	ret = platform_device_add_resources(ppdev, &res, 1);
 	if (ret)
-- 
1.7.10.4
