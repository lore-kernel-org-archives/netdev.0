From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH 4/8] net: fs_enet: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 21:24:50 +0800
Message-ID: <5208E222.60300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: <pantelis.antoniou@gmail.com>, <vbordug@ru.mvista.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19087 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab3HLNZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 09:25:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 8de53a1..7e3de10 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1122,7 +1122,6 @@ static int fs_enet_remove(struct platform_device *ofdev)

 	fep->ops->free_bd(ndev);
 	fep->ops->cleanup_data(ndev);
-	dev_set_drvdata(fep->dev, NULL);
 	of_node_put(fep->fpi->phy_node);
 	free_netdev(ndev);
 	return 0;
-- 
1.7.1
