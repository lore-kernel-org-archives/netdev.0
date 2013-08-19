From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v4 6/7] net: xilinx_emaclite: use platform_{get,set}_drvdata()
Date: Mon, 19 Aug 2013 20:00:25 +0800
Message-ID: <521208D9.6000305@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <renner@efe-gmbh.de>,
	Greg KH <gregkh@linuxfoundation.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<monstr@monstr.eu>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25984 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab3HSMBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 08:01:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &of_dev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
Acked-by: Michal Simek <monstr@monstr.eu>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index fd4dbda..7c1ccbc 100644
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

-- 
1.7.1
