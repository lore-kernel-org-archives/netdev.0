From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 12/36] net: ethernet: davicom: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:29:01 +0900
Message-ID: <001c01ce4adb$66469cc0$32d3d640$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Joseph CHANG' <josright123@gmail.com>,
	'Matthew Leach' <matthew@mattleach.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:49943 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932664Ab3EGE3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:29:04 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME001LYV4ATHA0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:29:03 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/davicom/dm9000.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 9105465..1ec8b18 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1673,8 +1673,6 @@ dm9000_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 	dm9000_release_board(pdev, netdev_priv(ndev));
 	free_netdev(ndev);		/* free device structure */
-- 
1.7.2.5
