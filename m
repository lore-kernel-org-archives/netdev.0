From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v3 2/7] net: ucc_geth: use platform_{get,set}_drvdata()
Date: Thu, 15 Aug 2013 21:01:32 +0800
Message-ID: <520CD12C.4010802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>, <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:61092 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3HONBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:01:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &ofdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 3c43dac..533885c 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3911,8 +3911,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)

 static int ucc_geth_remove(struct platform_device* ofdev)
 {
-	struct device *device = &ofdev->dev;
-	struct net_device *dev = dev_get_drvdata(device);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);

 	unregister_netdev(dev);
-- 
1.7.1
