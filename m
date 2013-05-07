From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 08/36] net: ethernet: broadcom: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:22:34 +0900
Message-ID: <001801ce4ada$7fe05fa0$7fa11ee0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Jonas Gorski' <jogo@openwrt.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:48872 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915Ab3EGEWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:22:36 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME002M0UT9D8A0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:22:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 0b3e23e..e46466c 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1847,7 +1847,6 @@ static int bcm_enet_remove(struct platform_device *pdev)
 	clk_disable_unprepare(priv->mac_clk);
 	clk_put(priv->mac_clk);
 
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	return 0;
 }
-- 
1.7.2.5
