From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH 7/8] net: xilinx_emaclite: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 21:25:00 +0800
Message-ID: <5208E22C.4090101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <renner@efe-gmbh.de>,
	Greg KH <gregkh@linuxfoundation.org>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:43379 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756680Ab3HLNZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 09:25:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index fd4dbda..4c619ea 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1230,8 +1230,7 @@ error:
  */
 static int xemaclite_of_remove(struct platform_device *of_dev)
 {
-	struct device *dev = &of_dev->dev;
-	struct net_device *ndev = dev_get_drvdata(dev);
+	struct net_device *ndev = platform_get_drvdata(of_dev);

 	struct net_local *lp = netdev_priv(ndev);

@@ -1250,7 +1249,6 @@ static int xemaclite_of_remove(struct platform_device *of_dev)
 	lp->phy_node = NULL;

 	xemaclite_remove_ndev(ndev, of_dev);
-	dev_set_drvdata(dev, NULL);

 	return 0;
 }
-- 
1.7.1
