From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/36] net: ethernet: amd: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:21:44 +0900
Message-ID: <001701ce4ada$61e226a0$25a673e0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:34134 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757967Ab3EGEVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:21:46 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00BE1URB7RI0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:21:45 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/amd/au1000_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 688aede..ceb45bc 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1301,8 +1301,6 @@ static int au1000_remove(struct platform_device *pdev)
 	int i;
 	struct resource *base, *macen;
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(dev);
 	mdiobus_unregister(aup->mii_bus);
 	mdiobus_free(aup->mii_bus);
-- 
1.7.2.5
