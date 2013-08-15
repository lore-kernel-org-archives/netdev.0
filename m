From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v3 7/7] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Thu, 15 Aug 2013 21:01:50 +0800
Message-ID: <520CD13E.7090802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <bigeasy@linutronix.de>,
	<prabhakar.csengg@gmail.com>, <b-liu@ti.com>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:52264 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801Ab3HONCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:02:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 16ddfc3..01b0cc5 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -421,8 +421,7 @@ bail_out:

 static int davinci_mdio_remove(struct platform_device *pdev)
 {
-	struct device *dev = &pdev->dev;
-	struct davinci_mdio_data *data = dev_get_drvdata(dev);
+	struct davinci_mdio_data *data = platform_get_drvdata(pdev);

 	if (data->bus) {
 		mdiobus_unregister(data->bus);
-- 
1.7.1
