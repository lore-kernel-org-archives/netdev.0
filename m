From: Libo Chen <libo.chen@huawei.com>
Subject: [PATCH 1/2] net: can: at91_can: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 18:15:03 +0800
Message-ID: <1377080103-33872-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>, <libo.chen@huawei.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_set_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/can/at91_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index dbbe97a..3b1ff61 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1355,7 +1355,7 @@ static int at91_can_probe(struct platform_device *pdev)
 	if (at91_is_sam9263(priv))
 		dev->sysfs_groups[0] = &at91_sysfs_attr_group;
 
-	dev_set_drvdata(&pdev->dev, dev);
+	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_candev(dev);
-- 
1.7.1
