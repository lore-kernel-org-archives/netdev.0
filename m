From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 21/36] net: ethernet: nxp: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:44:17 +0900
Message-ID: <002601ce4add$888a35b0$999ea110$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Wei Yongjun' <yongjun_wei@trendmicro.com.cn>,
	Eric Dumazet <edumazet@google.com>,
	'Roland Stigge' <stigge@antcom.de>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:62441 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759401Ab3EGEoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:44:19 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00FPFVTUF080@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:44:18 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 55a5548..a061b93 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1483,7 +1483,6 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	return 0;
 
 err_out_unregister_netdev:
-	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 err_out_dma_unmap:
 	if (!use_iram_for_net(&pldat->pdev->dev) ||
@@ -1511,7 +1510,6 @@ static int lpc_eth_drv_remove(struct platform_device *pdev)
 	struct netdata_local *pldat = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	if (!use_iram_for_net(&pldat->pdev->dev) ||
 	    pldat->dma_buff_size > lpc32xx_return_iram_size())
-- 
1.7.2.5
