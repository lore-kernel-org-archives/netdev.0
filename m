From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 29/36] net: ethernet: tundra: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:54:56 +0900
Message-ID: <002e01ce4adf$05478a20$0fd69e60$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Ian Campbell' <Ian.Campbell@citrix.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:39881 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760719Ab3EGEzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:55:00 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00J0KWBLG9N0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:54:57 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 3c69a04..01bdc6c 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1682,7 +1682,6 @@ static int tsi108_ether_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	tsi108_stop_ethernet(dev);
-	platform_set_drvdata(pdev, NULL);
 	iounmap(priv->regs);
 	iounmap(priv->phyregs);
 	free_netdev(dev);
-- 
1.7.2.5
