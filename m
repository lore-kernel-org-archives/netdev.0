From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/31] net: macb: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:12:21 +0900
Message-ID: <005801cea53f$815de4a0$8419ade0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Nicolas Ferre' <nicolas.ferre@atmel.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:42903 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3H3FM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:12:26 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00FQSVRIPUP0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:12:20 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cadence/macb.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index fe06ab0..20f94d1 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -125,7 +125,7 @@ void macb_get_hwaddr(struct macb *bp)
 	u8 addr[6];
 	int i;
 
-	pdata = bp->pdev->dev.platform_data;
+	pdata = dev_get_platdata(&bp->pdev->dev);
 
 	/* Check all 4 address register for vaild address */
 	for (i = 0; i < 4; i++) {
@@ -335,7 +335,7 @@ int macb_mii_init(struct macb *bp)
 		bp->pdev->name, bp->pdev->id);
 	bp->mii_bus->priv = bp;
 	bp->mii_bus->parent = &bp->dev->dev;
-	pdata = bp->pdev->dev.platform_data;
+	pdata = dev_get_platdata(&bp->pdev->dev);
 
 	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bp->mii_bus->irq) {
@@ -1851,7 +1851,7 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	err = of_get_phy_mode(pdev->dev.of_node);
 	if (err < 0) {
-		pdata = pdev->dev.platform_data;
+		pdata = dev_get_platdata(&pdev->dev);
 		if (pdata && pdata->is_rmii)
 			bp->phy_interface = PHY_INTERFACE_MODE_RMII;
 		else
-- 
1.7.10.4
