From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 19/31] net: smc911x: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:02:06 +0900
Message-ID: <004301cea53e$131e20a0$395a61e0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:14946 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621Ab3H3FCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:02:07 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00LH4VBI86L0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:02:06 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smc911x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 345558f..afe01c4 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2067,7 +2067,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	lp->netdev = ndev;
 #ifdef SMC_DYNAMIC_BUS_CONFIG
 	{
-		struct smc911x_platdata *pd = pdev->dev.platform_data;
+		struct smc911x_platdata *pd = dev_get_platdata(&pdev->dev);
 		if (!pd) {
 			ret = -EINVAL;
 			goto release_both;
-- 
1.7.10.4
