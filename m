From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH RESEND 2/8] net: ucc_geth: use platform_{get,set}_drvdata()
Date: Wed, 14 Aug 2013 11:39:32 +0800
Message-ID: <520AFBF4.1070509@huawei.com>
References: <5208E21A.3020805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>, <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:60923 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759108Ab3HNDju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 23:39:50 -0400
In-Reply-To: <5208E21A.3020805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can use the wrapper functions platform_{get,set}_drvdata() instead of
dev_{get,set}_drvdata() with &ofdev->dev, it is convenient for user.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 3c43dac..5930c39 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3911,14 +3911,12 @@ static int ucc_geth_probe(struct platform_device* ofdev)

 static int ucc_geth_remove(struct platform_device* ofdev)
 {
-	struct device *device = &ofdev->dev;
-	struct net_device *dev = dev_get_drvdata(device);
+	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);

 	unregister_netdev(dev);
 	free_netdev(dev);
 	ucc_geth_memclean(ugeth);
-	dev_set_drvdata(device, NULL);

 	return 0;
 }
-- 
1.7.1
