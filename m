From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 22/36] net: ethernet: renesas: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:46:04 +0900
Message-ID: <002701ce4add$c823cba0$586b62e0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	'Yoshihiro Shimoda' <yoshihiro.shimoda.uh@renesas.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:38284 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383Ab3EGEqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:46:06 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME003GHVWPN6L0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:46:05 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..a205222 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2808,7 +2808,6 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
-- 
1.7.2.5
