From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/2] ethernet: broadcom: remove unnecessary
 platform_set_drvdata()
Date: Thu, 22 Aug 2013 10:57:20 +0900
Message-ID: <001a01ce9eda$efcfdf80$cf6f9e80$%han@samsung.com>
References: <001901ce9eda$a9351310$fb9f3930$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Maxime Bizon' <mbizon@freebox.fr>,
	'Florian Fainelli' <florian@openwrt.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:55811 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898Ab3HVB5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 21:57:22 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MRW008F0TFKM3E0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 22 Aug 2013 10:57:21 +0900 (KST)
In-reply-to: <001901ce9eda$a9351310$fb9f3930$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index b1bcd4b..ca963d4 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2836,7 +2836,6 @@ static int bcm_enetsw_remove(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	return 0;
 }
-- 
1.7.10.4
