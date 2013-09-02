From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/5] net: sunhme: use platform_{get,set}_drvdata()
Date: Mon, 02 Sep 2013 17:08:44 +0900
Message-ID: <001001cea7b3$a4ae1620$ee0a4260$%han@samsung.com>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jon Mason' <jdmason@kudzu.us>,
	'Francois Romieu' <romieu@fr.zoreil.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:32590 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758161Ab3IBIIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 04:08:46 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH00NY3NYK1AF0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 17:08:44 +0900 (KST)
In-reply-to: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data
using platform_device instead of using dev_{get,set}_drvdata()
with &pdev->dev, so we can directly pass a struct platform_device.
This is a purely cosmetic change.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sunhme.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index c67e683..227c499 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2798,7 +2798,7 @@ static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 		goto err_out_free_coherent;
 	}
 
-	dev_set_drvdata(&op->dev, hp);
+	platform_set_drvdata(op, hp);
 
 	if (qfe_slot != -1)
 		printk(KERN_INFO "%s: Quattro HME slot %d (SBUS) 10/100baseT Ethernet ",
-- 
1.7.10.4
