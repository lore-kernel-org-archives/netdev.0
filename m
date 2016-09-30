From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net: mvmdio: do not clk_disable_unprepare() NULL clock
Date: Sat,  1 Oct 2016 00:56:37 +0300
Message-ID: <1475272598-6554-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to clk_disable_unprepare(dev->clk)
before it was initialized.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/marvell/mvmdio.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 8982c882af1b..a0d1b084ecec 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -211,8 +211,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	dev->regs = devm_ioremap(&pdev->dev, r->start, resource_size(r));
 	if (!dev->regs) {
 		dev_err(&pdev->dev, "Unable to remap SMI register\n");
-		ret = -ENODEV;
-		goto out_mdio;
+		return -ENODEV;
 	}
 
 	init_waitqueue_head(&dev->smi_busy_wait);
-- 
2.7.4
