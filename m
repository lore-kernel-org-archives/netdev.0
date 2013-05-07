From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 28/36] net: ethernet: ti: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:53:38 +0900
Message-ID: <002d01ce4ade$d6c7da60$84578f20$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Mugunthan V N' <mugunthanvnm@ti.com>,
	'Sekhar Nori' <nsekhar@ti.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:47465 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758446Ab3EGExk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:53:40 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME007L6W8NT480@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:53:39 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ti/cpsw.c         |    1 -
 drivers/net/ethernet/ti/davinci_emac.c |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 21a5b29..89a4c40 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1940,7 +1940,6 @@ static int cpsw_remove(struct platform_device *pdev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int i;
 
-	platform_set_drvdata(pdev, NULL);
 	if (priv->data.dual_emac)
 		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 860e15d..efb6f65 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2037,8 +2037,6 @@ static int davinci_emac_remove(struct platform_device *pdev)
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
-	platform_set_drvdata(pdev, NULL);
-
 	if (priv->txchan)
 		cpdma_chan_destroy(priv->txchan);
 	if (priv->rxchan)
-- 
1.7.2.5
